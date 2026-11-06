const Attendance = require("../models/Attendance");
const Student = require("../models/Student");

// Update Attendance
exports.updateAttendance = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, date, teacher, batch, subject, student } = req.body;
    const updated = await Attendance.findByIdAndUpdate(
      id,
      { status, date, teacher, batch, subject, student },
      { new: true }
    );
    if (!updated) {
      return res.status(404).json({ success: false, message: "Attendance record not found" });
    }
    res.status(200).json({ success: true, attendance: updated });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Delete Attendance
exports.deleteAttendance = async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await Attendance.findByIdAndDelete(id);
    if (!deleted) {
      return res.status(404).json({ success: false, message: "Attendance record not found" });
    }
    res.status(200).json({ success: true, message: "Attendance deleted" });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Helper to calculate effective present count based on Late policy
const effectivePresent = (present, late, policy) => {
  if (policy === "present") return present + late; // Late counted as present
  if (policy === "partial") return present + late * 0.5; // Late counts half
  return present; // default: Late ignored (treated as absent)
};

// Get Student Report (aggregated)
exports.getStudentReport = async (req, res) => {
  try {
    const studentId = req.params.id;
    const latePolicy = process.env.LATE_AS || "present"; // present | partial | absent
    const student = await Student.findById(studentId).populate("batchId");
    if (!student) {
      return res.status(404).json({ success: false, message: "Student not found" });
    }
    // Subject-wise aggregation
    const subjectAgg = await Attendance.aggregate([
      { $match: { student: student._id } },
      {
        $group: {
          _id: "$subject",
          totalClasses: { $sum: 1 },
          present: { $sum: { $cond: [{ $eq: ["$status", "Present"] }, 1, 0] } },
          late: { $sum: { $cond: [{ $eq: ["$status", "Late"] }, 1, 0] } },
          absent: { $sum: { $cond: [{ $eq: ["$status", "Absent"] }, 1, 0] } }
        }
      },
      {
        $lookup: {
          from: "subjects",
          localField: "_id",
          foreignField: "_id",
          as: "subjectInfo"
        }
      },
      { $unwind: "$subjectInfo" },
      {
        $project: {
          subjectId: "$_id",
          subjectName: "$subjectInfo.subjectName",
          totalClasses: 1,
          present: 1,
          late: 1,
          absent: 1
        }
      }
    ]);
    // Overall aggregation
    const overallAgg = await Attendance.aggregate([
      { $match: { student: student._id } },
      {
        $group: {
          _id: null,
          totalClasses: { $sum: 1 },
          present: { $sum: { $cond: [{ $eq: ["$status", "Present"] }, 1, 0] } },
          late: { $sum: { $cond: [{ $eq: ["$status", "Late"] }, 1, 0] } },
          absent: { $sum: { $cond: [{ $eq: ["$status", "Absent"] }, 1, 0] } }
        }
      }
    ]);
    const overall = overallAgg[0] || { totalClasses: 0, present: 0, late: 0, absent: 0 };
    const effective = effectivePresent(overall.present, overall.late, latePolicy);
    const overallPercentage = overall.totalClasses === 0 ? 0 : (effective / overall.totalClasses) * 100;

    // Build response
    const subjects = subjectAgg.map((s) => {
      const eff = effectivePresent(s.present, s.late, latePolicy);
      const perc = s.totalClasses === 0 ? 0 : (eff / s.totalClasses) * 100;
      return {
        subjectId: s.subjectId,
        subjectName: s.subjectName,
        totalClasses: s.totalClasses,
        present: s.present,
        late: s.late,
        absent: s.absent,
        attendancePercentage: perc.toFixed(2)
      };
    });

    res.status(200).json({
      success: true,
      student: {
        _id: student._id,
        studentName: student.studentName,
        registerNo: student.registerNo,
        department: student.department,
        batch: student.batchId,
        email: student.email,
        phoneNo: student.phoneNo
      },
      overall: {
        totalClasses: overall.totalClasses,
        present: overall.present,
        late: overall.late,
        absent: overall.absent,
        attendancePercentage: overallPercentage.toFixed(2)
      },
      subjects
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Existing functions ... (unchanged)

// Update Attendance
exports.updateAttendance = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, date, teacher, batch, subject, student } = req.body;

    // Ensure the teacher updating is authorized for the subject/batch – assumed handled by middleware
    const updated = await Attendance.findByIdAndUpdate(
      id,
      { status, date, teacher, batch, subject, student },
      { new: true }
    );
    if (!updated) {
      return res.status(404).json({ success: false, message: "Attendance record not found" });
    }
    res.status(200).json({ success: true, attendance: updated });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Delete Attendance
exports.deleteAttendance = async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await Attendance.findByIdAndDelete(id);
    if (!deleted) {
      return res.status(404).json({ success: false, message: "Attendance record not found" });
    }
    res.status(200).json({ success: true, message: "Attendance deleted" });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Helper to calculate effective present count based on Late policy
const effectivePresent = (present, late, policy) => {
  if (policy === "present") return present + late; // Late counted as present
  if (policy === "partial") return present + late * 0.5; // Late counts half
  return present; // default: Late ignored (treated as absent)
};

// Get Student Report (aggregated)
exports.getStudentReport = async (req, res) => {
  try {
    const studentId = req.params.id;
    const latePolicy = process.env.LATE_AS || "present"; // present | partial | absent

    const student = await Student.findById(studentId).populate("batchId");
    if (!student) {
      return res.status(404).json({ success: false, message: "Student not found" });
    }

    const attendanceAgg = await Attendance.aggregate([
      { $match: { student: student._id } },
      {
        $group: {
          _id: "$subject",
          totalClasses: { $sum: 1 },
          present: { $sum: { $cond: [{ $eq: ["$status", "Present"] }, 1, 0] } },
          late: { $sum: { $cond: [{ $eq: ["$status", "Late"] }, 1, 0] } },
          absent: { $sum: { $cond: [{ $eq: ["$status", "Absent"] }, 1, 0] } },
        },
      },
      {
        $lookup: {
          from: "subjects",
          localField: "_id",
          foreignField: "_id",
          as: "subjectInfo",
        },
      },
      { $unwind: "$subjectInfo" },
      {
        $project: {
          subjectId: "$_id",
          subjectName: "$subjectInfo.subjectName",
          totalClasses: 1,
          present: 1,
          late: 1,
          absent: 1,
          effectivePresent: { $add: ["$present", { $cond: [{ $eq: ["$late", null] }, 0, "$late"] }] },
          attendancePercentage: {
            $cond: [
              { $eq: ["$totalClasses", 0] },
              0,
              {
                $multiply: [
                  {
                    $divide: [
                      effectivePresent: { $add: ["$present", { $cond: [{ $eq: ["$late", null] }, 0, "$late"] }] },
                      "$totalClasses"
                    ]
                  },
                  100
                ]
              }
            ]
          }
        },
      },
    ]);

    // Compute overall stats
    const overall = await Attendance.aggregate([
      { $match: { student: student._id } },
      {
        $group: {
          _id: null,
          totalClasses: { $sum: 1 },
          present: { $sum: { $cond: [{ $eq: ["$status", "Present"] }, 1, 0] } },
          late: { $sum: { $cond: [{ $eq: ["$status", "Late"] }, 1, 0] } },
          absent: { $sum: { $cond: [{ $eq: ["$status", "Absent"] }, 1, 0] } },
        },
      },
    ]);

    const overallStats = overall[0] || { totalClasses: 0, present: 0, late: 0, absent: 0 };
    const effective = effectivePresent(overallStats.present, overallStats.late, latePolicy);
    const overallPercentage = overallStats.totalClasses === 0 ? 0 : (effective / overallStats.totalClasses) * 100;

    res.status(200).json({
      success: true,
      student: {
        _id: student._id,
        studentName: student.studentName,
        registerNo: student.registerNo,
        department: student.department,
        batch: student.batchId,
        email: student.email,
        phoneNo: student.phoneNo,
      },
      overall: {
        totalClasses: overallStats.totalClasses,
        present: overallStats.present,
        late: overallStats.late,
        absent: overallStats.absent,
        attendancePercentage: overallPercentage.toFixed(2),
      },
      subjects: attendanceAgg.map((s) => ({
        subjectId: s.subjectId,
        subjectName: s.subjectName,
        totalClasses: s.totalClasses,
        present: s.present,
        late: s.late,
        absent: s.absent,
        attendancePercentage: ((effectivePresent(s.present, s.late, latePolicy) / s.totalClasses) * 100).toFixed(2),
      })),
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Existing functions ... (unchanged)
exports.markAttendance = async (req, res) => {
    try {

        const {
            student,
            subject,
            teacher,
            batch,
            status,
            date
        } = req.body;

        const targetDate = date ? new Date(date) : new Date();
        const startOfDay = new Date(targetDate);
        startOfDay.setHours(0, 0, 0, 0);
        const endOfDay = new Date(targetDate);
        endOfDay.setHours(23, 59, 59, 999);

        const attendance = await Attendance.findOneAndUpdate(
            {
                student,
                subject,
                batch,
                date: { $gte: startOfDay, $lte: endOfDay }
            },
            {
                student,
                subject,
                teacher,
                batch,
                status,
                date: targetDate
            },
            { new: true, upsert: true, setDefaultsOnInsert: true }
        );

        res.status(200).json({
            success: true,
            message: "Attendance marked successfully",
            attendance
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};

// Get Student Attendance
exports.getStudentAttendance = async (req, res) => {
    try {

        const attendance =
            await Attendance.find({
                student: req.params.id
            })
               .populate({
                    path: "student",
                    select: "-password -aadhaarEncrypted"
                })
                .populate({
                    path: "teacher",
                    select: "-password"
                })
                .populate("subject")
                .populate("batch");

        res.status(200).json({
            success: true,
            attendance
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};
// Get List (<75%) 
exports.getDefaulters = async (req, res) => {
    try {

        const Student = require("../models/Student");

        const students = await Student.find();

        const defaulters = [];

        for (const student of students) {

            const totalClasses =
                await Attendance.countDocuments({
                    student: student._id
                });

            const presentClasses =
                await Attendance.countDocuments({
                    student: student._id,
                    status: "Present"
                });

            const percentage =
                totalClasses === 0
                    ? 0
                    : (presentClasses / totalClasses) * 100;

            if (percentage < 75) {
                defaulters.push({
                    studentId: student._id,
                    studentName: student.studentName,
                    registerNo: student.registerNo,
                    attendancePercentage:
                        percentage.toFixed(2)
                });
            }
        }

        res.status(200).json({
            success: true,
            totalDefaulters: defaulters.length,
            defaulters
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};
// Attendance Percentage
exports.getAttendancePercentage = async (req, res) => {
    try {

        const studentId = req.params.studentId;

        const totalClasses =
            await Attendance.countDocuments({
                student: studentId
            });

        const presentClasses =
            await Attendance.countDocuments({
                student: studentId,
                status: "Present"
            });

        const absentClasses =
            await Attendance.countDocuments({
                student: studentId,
                status: "Absent"
            });

        const attendancePercentage =
            totalClasses === 0
                ? 0
                : ((presentClasses / totalClasses) * 100).toFixed(2);

        res.status(200).json({
            success: true,
            totalClasses,
            presentClasses,
            absentClasses,
            attendancePercentage
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};

//   Batch Attendance
exports.getBatchAttendance = async (req, res) => {
    try {

        const attendance =
            await Attendance.find({
                batch: req.params.id
            })
                .populate("student")
                .populate("subject")
                .populate("teacher")
                .populate("batch");

        res.status(200).json({
            success: true,
            attendance
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};

// Get Subject Attendance
exports.getSubjectAttendance = async (req, res) => {
    try {

        const attendance =
            await Attendance.find({
                subject: req.params.id
            })
                .populate("student")
                .populate("subject")
                .populate("teacher")
                .populate("batch");

        res.status(200).json({
            success: true,
            attendance
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};