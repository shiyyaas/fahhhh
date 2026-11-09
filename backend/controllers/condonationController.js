const mongoose = require("mongoose");
const Attendance = require("../models/Attendance");
const Student = require("../models/Student");
const Batch = require("../models/Batch");
const User = require("../models/User");
const { formatAttendancePercentage } = require("../utils/attendanceCalculations");
const {
  initPDFResponse,
  drawBorder,
  drawLogo,
  drawHeader,
  drawTitle,
  drawFooter,
  drawSignatures
} = require("../utils/pdfHelpers");

// Helper to compute attendance stats dynamically for an array of student IDs
async function computeAttendanceStats(studentIds) {
  if (!studentIds || studentIds.length === 0) return {};
  try {
    const stats = await Attendance.aggregate([
      { $match: { student: { $in: studentIds } } },
      {
        $group: {
          _id: "$student",
          totalClasses: { $sum: 1 },
          presentClasses: { $sum: { $cond: [{ $eq: ["$status", "Present"] }, 1, 0] } },
          lateClasses: { $sum: { $cond: [{ $eq: ["$status", "Late"] }, 1, 0] } },
          absentClasses: { $sum: { $cond: [{ $eq: ["$status", "Absent"] }, 1, 0] } }
        }
      }
    ]);
    const map = {};
    if (Array.isArray(stats)) {
      stats.forEach((s) => {
        if (s && s._id) {
          map[s._id.toString()] = s;
        }
      });
    }
    return map;
  } catch (_) {
    // Fallback if aggregate is unavailable in mock environment
    const map = {};
    for (const sid of studentIds) {
      const records = await Attendance.find({ student: sid });
      const totalClasses = records.length;
      const presentClasses = records.filter((r) => r.status === "Present").length;
      const lateClasses = records.filter((r) => r.status === "Late").length;
      const absentClasses = records.filter((r) => r.status === "Absent").length;
      map[sid.toString()] = { _id: sid, totalClasses, presentClasses, lateClasses, absentClasses };
    }
    return map;
  }
}

// Helper to determine condonation eligibility based on business rules:
// 1. totalClasses === 0 -> NO_ATTENDANCE_DATA
// 2. totalClasses > 0 and attendance percentage < 75 -> ELIGIBLE
// 3. Attendance percentage >= 75 -> NOT_ELIGIBLE
function calculateEligibility(totalClasses, attendancePercentage) {
  if (!totalClasses || totalClasses === 0) {
    return "NO_ATTENDANCE_DATA";
  }
  return parseFloat(attendancePercentage) < 75.0 ? "ELIGIBLE" : "NOT_ELIGIBLE";
}

// Shared helper to fetch and calculate condonation eligible students for the authenticated HOD
async function getEvaluatedEligibleStudents(req) {
  const user = await User.findById(req.user.userId).select("role department");
  if (!user || user.role !== "HOD" || !user.department) {
    const err = new Error("Forbidden");
    err.status = 403;
    throw err;
  }

  let batchFilter = {};
  let selectedBatch = null;
  if (req.query.batchId) {
    if (!mongoose.Types.ObjectId.isValid(req.query.batchId)) {
      const err = new Error("Invalid batchId");
      err.status = 400;
      throw err;
    }
    selectedBatch = await Batch.findById(req.query.batchId).select("department batchName");
    if (!selectedBatch) {
      const err = new Error("Batch not found");
      err.status = 404;
      throw err;
    }
    if (selectedBatch.department !== user.department) {
      const err = new Error("Forbidden");
      err.status = 403;
      throw err;
    }
    batchFilter.batchId = selectedBatch._id;
  }

  const studentQuery = { department: user.department, ...batchFilter };
  if (req.query.search && req.query.search.trim()) {
    const search = req.query.search.trim().replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    const regex = new RegExp(search, "i");
    studentQuery.$or = [{ studentName: regex }, { registerNo: regex }];
  }

  const students = await Student.find(studentQuery)
    .populate({ path: "batchId", select: "batchName department" })
    .lean();

  const studentIds = students.map((s) => s._id);
  const attendanceMap = await computeAttendanceStats(studentIds);
  const latePolicy = process.env.LATE_AS || "present";

  const evaluated = students.map((s) => {
    const stats = attendanceMap[s._id.toString()] || {
      totalClasses: 0,
      presentClasses: 0,
      lateClasses: 0,
      absentClasses: 0
    };
    const { totalClasses, presentClasses, lateClasses, absentClasses = 0 } = stats;
    const attendancePercentage = formatAttendancePercentage(
      presentClasses,
      lateClasses,
      totalClasses,
      latePolicy
    );
    const eligibility = calculateEligibility(totalClasses, attendancePercentage);

    return {
      studentId: s._id,
      studentName: s.studentName,
      registerNo: s.registerNo,
      batch: s.batchId ? (s.batchId.batchName || s.batchId) : null,
      department: s.department,
      totalClasses,
      presentClasses,
      lateClasses,
      absentClasses,
      attendancePercentage,
      eligibility
    };
  });

  const eligibleStudents = evaluated.filter((s) => s.eligibility === "ELIGIBLE");

  // Sorting
  const sortDirection = req.query.sort === "desc" ? -1 : 1;
  eligibleStudents.sort(
    (a, b) => (parseFloat(a.attendancePercentage) - parseFloat(b.attendancePercentage)) * sortDirection
  );

  return { user, selectedBatch, eligibleStudents };
}

// GET /api/condonation/eligible
exports.getEligibleStudents = async (req, res) => {
  try {
    const { eligibleStudents } = await getEvaluatedEligibleStudents(req);

    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
    const limit = Math.max(parseInt(req.query.limit, 10) || 20, 1);
    const totalEligible = eligibleStudents.length;
    const totalPages = Math.ceil(totalEligible / limit) || 1;
    const paginatedData = eligibleStudents.slice((page - 1) * limit, page * limit);

    return res.status(200).json({
      success: true,
      page,
      limit,
      totalPages,
      totalEligible,
      totalStudents: totalEligible,
      data: paginatedData
    });
  } catch (error) {
    if (error.status) {
      return res.status(error.status).json({ success: false, message: error.message });
    }
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
};

// GET /api/condonation/student/:studentId
exports.getStudentEligibility = async (req, res) => {
  try {
    const studentId = req.params.studentId;
    if (!mongoose.Types.ObjectId.isValid(studentId)) {
      return res.status(400).json({ success: false, message: "Invalid student ID" });
    }

    const student = await Student.findById(studentId).populate({
      path: "batchId",
      select: "batchName department"
    });
    if (!student) {
      return res.status(404).json({ success: false, message: "Student not found" });
    }

    const user = await User.findById(req.user.userId).select("role department email");
    if (!user) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    // Role-specific ownership verification
    if (req.user.role === "HOD") {
      if (!user.department || user.department !== student.department) {
        return res.status(403).json({ success: false, message: "Forbidden" });
      }
    } else if (req.user.role === "STUDENT") {
      if (!user.email || user.email !== student.email) {
        return res.status(403).json({ success: false, message: "Forbidden" });
      }
    } else {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    const statsMap = await computeAttendanceStats([student._id]);
    const s = statsMap[student._id.toString()] || {
      totalClasses: 0,
      presentClasses: 0,
      lateClasses: 0,
      absentClasses: 0
    };
    const latePolicy = process.env.LATE_AS || "present";
    const attendancePercentage = formatAttendancePercentage(
      s.presentClasses,
      s.lateClasses,
      s.totalClasses,
      latePolicy
    );
    const eligibility = calculateEligibility(s.totalClasses, attendancePercentage);

    return res.status(200).json({
      success: true,
      student: {
        studentId: student._id,
        studentName: student.studentName,
        registerNo: student.registerNo,
        batch: student.batchId ? (student.batchId.batchName || student.batchId) : null,
        department: student.department,
        totalClasses: s.totalClasses,
        presentClasses: s.presentClasses,
        lateClasses: s.lateClasses,
        absentClasses: s.absentClasses,
        attendancePercentage,
        eligibility
      }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
};

// GET /api/condonation/eligible/export/csv
exports.exportEligibleCSV = async (req, res) => {
  try {
    const { eligibleStudents } = await getEvaluatedEligibleStudents(req);

    const escapeCSV = (val) => `"${String(val ?? "").replace(/"/g, '""')}"`;
    const headers = [
      "Student ID",
      "Student Name",
      "Register No",
      "Batch",
      "Department",
      "Total Classes",
      "Present Classes",
      "Late Classes",
      "Attendance %",
      "Eligibility Status"
    ];

    const rows = [headers.map(escapeCSV).join(",")];
    for (const s of eligibleStudents) {
      rows.push(
        [
          escapeCSV(s.studentId),
          escapeCSV(s.studentName),
          escapeCSV(s.registerNo),
          escapeCSV(s.batch || ""),
          escapeCSV(s.department),
          escapeCSV(s.totalClasses),
          escapeCSV(s.presentClasses),
          escapeCSV(s.lateClasses),
          escapeCSV(s.attendancePercentage),
          escapeCSV(s.eligibility)
        ].join(",")
      );
    }

    const csvContent = "\uFEFF" + rows.join("\r\n");
    res.setHeader("Content-Type", "text/csv; charset=utf-8");
    res.setHeader("Content-Disposition", 'attachment; filename="condonation-eligible-students.csv"');
    return res.status(200).send(csvContent);
  } catch (error) {
    if (error.status) {
      return res.status(error.status).json({ success: false, message: error.message });
    }
    return res.status(500).json({ success: false, message: "Failed to generate CSV" });
  }
};

// GET /api/condonation/eligible/export/pdf
exports.exportEligiblePDF = async (req, res) => {
  try {
    const { user, selectedBatch, eligibleStudents } = await getEvaluatedEligibleStudents(req);

    const doc = initPDFResponse(res, { filename: "condonation-eligible-report.pdf", inline: false });
    drawBorder(doc);
    drawLogo(doc);
    drawHeader(doc);
    drawTitle(doc, "Condonation Eligibility Report (< 75%)");

    // Header metadata
    doc.fontSize(10);
    const scope = selectedBatch
      ? `Batch: ${selectedBatch.batchName} (${user.department})`
      : `Department: ${user.department}`;
    doc.text(scope, 40, 135);
    doc.text("Threshold: Attendance strictly below 75%", 40, 150);
    doc.text(`Total Eligible Students: ${eligibleStudents.length}`, 340, 135);
    doc.text(`Generated On: ${new Date().toLocaleDateString()}`, 340, 150);

    // Table Header
    let rowY = 175;
    doc.rect(40, rowY, 520, 22).stroke();
    doc.fontSize(9);
    doc.text("#", 45, rowY + 6);
    doc.text("Reg No", 70, rowY + 6);
    doc.text("Student Name", 145, rowY + 6);
    doc.text("Batch", 270, rowY + 6);
    doc.text("Classes (P/L/Tot)", 360, rowY + 6);
    doc.text("Attendance %", 460, rowY + 6);
    doc.text("Status", 525, rowY + 6);
    rowY += 22;

    if (eligibleStudents.length === 0) {
      doc.rect(40, rowY, 520, 25).stroke();
      doc.text("No students found below the 75% attendance threshold", 50, rowY + 8);
      rowY += 25;
    } else {
      for (let i = 0; i < eligibleStudents.length; i++) {
        const s = eligibleStudents[i];
        doc.rect(40, rowY, 520, 20).stroke();
        doc.text(String(i + 1), 45, rowY + 5);
        doc.text(s.registerNo || "-", 70, rowY + 5);
        doc.text(s.studentName || "-", 145, rowY + 5, { width: 120, ellipsis: true });
        doc.text(s.batch || "-", 270, rowY + 5, { width: 85, ellipsis: true });
        doc.text(`${s.presentClasses}/${s.lateClasses}/${s.totalClasses}`, 360, rowY + 5);
        doc.text(`${s.attendancePercentage}%`, 460, rowY + 5);
        doc.text(s.eligibility, 525, rowY + 5);
        rowY += 20;

        if (rowY > 710 && i < eligibleStudents.length - 1) {
          doc.addPage();
          drawBorder(doc);
          drawLogo(doc);
          drawHeader(doc);
          drawTitle(doc, "Condonation Eligibility Report (Continued)");
          rowY = 140;
          doc.rect(40, rowY, 520, 22).stroke();
          doc.fontSize(9);
          doc.text("#", 45, rowY + 6);
          doc.text("Reg No", 70, rowY + 6);
          doc.text("Student Name", 145, rowY + 6);
          doc.text("Batch", 270, rowY + 6);
          doc.text("Classes (P/L/Tot)", 360, rowY + 6);
          doc.text("Attendance %", 460, rowY + 6);
          doc.text("Status", 525, rowY + 6);
          rowY += 22;
        }
      }
    }

    drawFooter(doc);
    drawSignatures(doc, Math.max(rowY + 40, 700));
    doc.end();
  } catch (error) {
    if (error.status) {
      return res.status(error.status).json({ success: false, message: error.message });
    }
    return res.status(500).json({ success: false, message: "Failed to generate PDF" });
  }
};

exports.calculateEligibility = calculateEligibility;
