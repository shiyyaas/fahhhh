const PDFDocument = require("pdfkit");
const path = require("path");
const Attendance = require("../models/Attendance");
const { initPDFResponse, drawBorder, drawLogo, drawHeader, drawTitle, drawFooter } = require("../utils/pdfHelpers");

const Student = require("../models/Student");
const Batch = require("../models/Batch");
const Subject = require("../models/Subject");
const Teacher = require("../models/Teacher");
const User = require("../models/User");
const Department = require("../models/Department");
const { effectivePresent, attendancePercentage, formatAttendancePercentage } = require("../utils/attendanceCalculations");

// Student Report
exports.getStudentReport = async (req, res) => {
    try {
        const studentId = req.params.studentId;

        const student = await Student.findById(studentId);

        if (!student) {
            return res.status(404).json({
                success: false,
                message: "Student not found"
            });
        }

        if (req.user && req.user.role === "HOD") {
            const user = await User.findById(req.user.userId).select("role department");
            if (user && user.department && student.department && student.department !== user.department) {
                return res.status(403).json({ success: false, message: "Forbidden" });
            }
        }

        const totalClasses = await Attendance.countDocuments({ student: studentId });
        const presentClasses = await Attendance.countDocuments({ student: studentId, status: "Present" });
        const lateClasses = await Attendance.countDocuments({ student: studentId, status: "Late" });
        const absentClasses = await Attendance.countDocuments({ student: studentId, status: "Absent" });

        const attendancePercentage = formatAttendancePercentage(
            presentClasses,
            lateClasses,
            totalClasses,
            process.env.LATE_AS || "present"
        );

        res.status(200).json({
            success: true,
            report: {
                studentName: student.studentName,
                registerNo: student.registerNo,
                totalClasses,
                presentClasses,
                lateClasses,
                absentClasses,
                attendancePercentage
            }
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

// Batch Report
exports.getBatchReport = async (req, res) => {
    try {
        const batchId = req.params.batchId;

        const batch = await Batch.findById(batchId);

        if (!batch) {
            return res.status(404).json({
                success: false,
                message: "Batch not found"
            });
        }

        const totalAttendance = await Attendance.countDocuments({ batch: batchId });
        const presentAttendance = await Attendance.countDocuments({ batch: batchId, status: "Present" });
        const lateAttendance = await Attendance.countDocuments({ batch: batchId, status: "Late" });

        const attendancePercentage = formatAttendancePercentage(
            presentAttendance,
            lateAttendance,
            totalAttendance,
            process.env.LATE_AS || "present"
        );

        res.status(200).json({
            success: true,
            report: {
                batchName: batch.batchName,
                currentSemester: batch.currentSemester,
                totalAttendance,
                presentAttendance,
                lateAttendance,
                attendancePercentage
            }
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

// Report preview (monthly batch)
exports.previewMonthlyBatchReport = async (req, res) => {
    try {
        const path = require("path");

        // Validate required parameters
        if (!req.params.batchId || !req.query.month || !req.query.year) {
            return res.status(400).json({
                success: false,
                message: "Missing required parameters: batchId, month, year"
            });
        }

        // Declare month, year, and monthNames BEFORE using them
        const month = Number(req.query.month);
        const year = Number(req.query.year);

        if (!Number.isInteger(month) || month < 1 || month > 12 ||
            !Number.isInteger(year) || year < 1) {
            return res.status(400).json({
                success: false,
                message: "Invalid month or year"
            });
        }

        const monthNames = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];

        const monthName = monthNames[month - 1];

        const batch = await Batch.findById(req.params.batchId);

        if (!batch) {
            return res.status(404).json({
                success: false,
                message: "Batch not found"
            });
        }

        if (req.user && req.user.role === "HOD") {
            const user = await User.findById(req.user.userId).select("role department");
            if (user && user.department && batch.department !== user.department) {
                return res.status(403).json({ success: false, message: "Forbidden" });
            }
        }

        const students = await Student.find({
            batchId: batch._id
        }).sort({ registerNo: 1 });

        // Return 200 with empty array (not an error)
        if (students.length === 0) {
            return res.status(200).json({
                success: true,
                message: "No students found in this batch",
                students: []
            });
        }

        // Create date range for the specified month
        const startDate = new Date(year, month - 1, 1);
        const endDate = new Date(year, month, 0, 23, 59, 59, 999);
        const latePolicy = process.env.LATE_AS || "present";

        const doc = new PDFDocument({
            margin: 40,
            size: "A4"
        });

        // Border
        doc.rect(15, 15, 565, 810).stroke();

        // PREVIEW MODE: Display inline in browser instead of downloading
        res.setHeader("Content-Type", "application/pdf");
        res.setHeader(
            "Content-Disposition",
            "inline"
        );

        doc.pipe(res);

        // Logo with error handling
        const logoPath = path.join(__dirname, "../assets/college-logo.png");
        try {
            doc.image(logoPath, 40, 30, { width: 55 });
        } catch (logoError) {
            console.warn("Logo not found, skipping...");
        }

        // Header
        doc.fontSize(18).text("MES M.K. MACKAR PILLAY COLLEGE", 110, 35);
        doc.fontSize(11).text("FOR ADVANCED STUDIES, EDATHALA", 110, 60);
        doc.fontSize(8).text("Affiliated to Mahatma Gandhi University", 110, 80);

        doc.moveDown(4);
        doc.fontSize(16).text("MONTHLY ATTENDANCE REPORT", { align: "center" });
        doc.moveDown();

        // Batch Information
        doc.fontSize(11);
        doc.text(`Program : ${batch.program}`);
        doc.text(`Admission Year : ${batch.admissionYear}`);
        doc.text(`Department : ${batch.department}`);
        doc.text(`Batch : ${batch.batchName}`);
        doc.text(`Semester : ${batch.currentSemester}`);
        doc.text(`Attendance Month : ${monthName} ${year}`);

        // Table Header
        doc.moveDown(2);
        let y = doc.y;

        doc.rect(40, y, 520, 25).stroke();
        doc.text("Sl No", 45, y + 8);
        doc.text("Reg No", 90, y + 8);
        doc.text("Student Name", 180, y + 8);
        doc.text("Effective", 350, y + 8);
        doc.text("Total", 430, y + 8);
        doc.text("%", 500, y + 8);

        // Table Rows - Optimized with bulk query
        let rowY = y + 25;
        let totalEffectivePresent = 0;
        let totalAttendance = 0;

        // Get all student IDs
        const studentIds = students.map(s => s._id);

        // Bulk query for attendance (much more efficient than N+1 queries)
        const attendanceStats = await Attendance.aggregate([
            {
                $match: {
                    student: { $in: studentIds },
                    date: { $gte: startDate, $lte: endDate }
                }
            },
            {
                $group: {
                    _id: "$student",
                    totalClasses: { $sum: 1 },
                    presentClasses: {
                        $sum: { $cond: [{ $eq: ["$status", "Present"] }, 1, 0] }
                    },
                    lateClasses: {
                        $sum: { $cond: [{ $eq: ["$status", "Late"] }, 1, 0] }
                    }
                }
            }
        ]);

        // Create a map for quick lookup
        const attendanceMap = {};
        attendanceStats.forEach(stat => {
            attendanceMap[stat._id.toString()] = stat;
        });

        for (let i = 0; i < students.length; i++) {
            const student = students[i];
            const studentIdStr = student._id.toString();

            // Get attendance from map or default to 0
            const stats = attendanceMap[studentIdStr] || {
                totalClasses: 0,
                presentClasses: 0,
                lateClasses: 0
            };

            const totalClasses = stats.totalClasses;
            const presentClasses = stats.presentClasses;
            const lateClasses = stats.lateClasses;
            const effectiveClasses = effectivePresent(presentClasses, lateClasses, latePolicy);

            totalEffectivePresent += effectiveClasses;
            totalAttendance += totalClasses;

            const percentage = formatAttendancePercentage(
                presentClasses,
                lateClasses,
                totalClasses,
                latePolicy
            );

            // Row border
            doc.rect(40, rowY, 520, 25).stroke();

            // Row data
            doc.text(String(i + 1), 45, rowY + 8);
            doc.text(student.registerNo, 90, rowY + 8);
            doc.text(student.studentName, 180, rowY + 8, { width: 150 });
            doc.text(String(effectiveClasses), 350, rowY + 8);
            doc.text(String(totalClasses), 430, rowY + 8);
            doc.text(`${percentage}%`, 500, rowY + 8);

            rowY += 25;

            // New Page Header - Repeat table header on each new page
            if (rowY > 750) {
                doc.addPage();
                rowY = 50;

                // Redraw table header on new page
                doc.rect(40, rowY, 520, 25).stroke();
                doc.text("Sl No", 45, rowY + 8);
                doc.text("Reg No", 90, rowY + 8);
                doc.text("Student Name", 180, rowY + 8);
                doc.text("Effective", 350, rowY + 8);
                doc.text("Total", 430, rowY + 8);
                doc.text("%", 500, rowY + 8);

                rowY += 25;
            }
        }

        // Summary Statistics
        const averageAttendance = totalAttendance === 0
            ? "0.00"
            : ((totalEffectivePresent / totalAttendance) * 100).toFixed(2);

        rowY += 20;
        doc.fontSize(10);
        doc.text(`Total Students : ${students.length}`, 40, rowY);
        doc.text(`Average Attendance : ${averageAttendance}%`, 250, rowY);

        // Signature Section
        rowY += 70;

        doc.moveTo(60, rowY).lineTo(180, rowY).stroke();
        doc.moveTo(380, rowY).lineTo(500, rowY).stroke();

        doc.text("Class In-Charge", 60, rowY + 5);
        doc.text("Head of Department", 380, rowY + 5);

        // Footer section before doc.end()
        doc.fontSize(8);
        doc.text(
            `Generated On : ${new Date().toLocaleString()}`,
            40,
            780
        );
        doc.text(
            "Generated from College ERP System",
            40,
            795
        );

        doc.end();

    } catch (error) {
        console.error("PDF preview generation failed");
        res.status(500).json({
            success: false,
            message: "Failed to generate report preview",
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

// Student PDF Report (download)
exports.downloadMonthlyBatchReport = async (req, res) => {
    try {
        const path = require("path");

        // Validate required parameters
        if (!req.params.batchId || !req.query.month || !req.query.year) {
            return res.status(400).json({
                success: false,
                message: "Missing required parameters: batchId, month, year"
            });
        }

        // Declare month, year, and monthNames BEFORE using them
        const month = Number(req.query.month);
        const year = Number(req.query.year);

        if (!Number.isInteger(month) || month < 1 || month > 12 ||
            !Number.isInteger(year) || year < 1) {
            return res.status(400).json({
                success: false,
                message: "Invalid month or year"
            });
        }

        const monthNames = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];

        const monthName = monthNames[month - 1];

        const batch = await Batch.findById(req.params.batchId);

        if (!batch) {
            return res.status(404).json({
                success: false,
                message: "Batch not found"
            });
        }

        if (req.user && req.user.role === "HOD") {
            const user = await User.findById(req.user.userId).select("role department");
            if (user && user.department && batch.department !== user.department) {
                return res.status(403).json({ success: false, message: "Forbidden" });
            }
        }

        const students = await Student.find({
            batchId: batch._id
        }).sort({ registerNo: 1 });

        if (students.length === 0) {
            return res.status(200).json({
                success: true,
                message: "No students found in this batch",
                students: []
            });
        }

        const startDate = new Date(year, month - 1, 1);
        const endDate = new Date(year, month, 0, 23, 59, 59, 999);
        const latePolicy = process.env.LATE_AS || "present";

        const doc = new PDFDocument({
            margin: 40,
            size: "A4"
        });

        // Border
        doc.rect(15, 15, 565, 810).stroke();

        // Now safe to use monthNames since it's declared above
        res.setHeader("Content-Type", "application/pdf");
        res.setHeader(
            "Content-Disposition",
            `attachment; filename=${batch.batchName}-attendance-report-${monthName}-${year}.pdf`
        );

        doc.pipe(res);

        // Logo with error handling
        const logoPath = path.join(__dirname, "../assets/college-logo.png");
        try {
            doc.image(logoPath, 40, 30, { width: 55 });
        } catch (logoError) {
            console.warn("Logo not found, skipping...");
        }

        // Header
        doc.fontSize(18).text("MES M.K. MACKAR PILLAY COLLEGE", 110, 35);
        doc.fontSize(11).text("FOR ADVANCED STUDIES, EDATHALA", 110, 60);
        doc.fontSize(8).text("Affiliated to Mahatma Gandhi University", 110, 80);

        doc.moveDown(4);
        doc.fontSize(16).text("MONTHLY ATTENDANCE REPORT", { align: "center" });
        doc.moveDown();

        // Batch Information
        doc.fontSize(11);
        doc.text(`Program : ${batch.program}`);
        doc.text(`Admission Year : ${batch.admissionYear}`);
        doc.text(`Department : ${batch.department}`);
        doc.text(`Batch : ${batch.batchName}`);
        doc.text(`Semester : ${batch.currentSemester}`);
        doc.text(`Attendance Month : ${monthName} ${year}`);

        // Table Header
        doc.moveDown(2);
        let y = doc.y;

        doc.rect(40, y, 520, 25).stroke();
        doc.text("Sl No", 45, y + 8);
        doc.text("Reg No", 90, y + 8);
        doc.text("Student Name", 180, y + 8);
        doc.text("Effective", 350, y + 8);
        doc.text("Total", 430, y + 8);
        doc.text("%", 500, y + 8);

        // Table Rows - Optimized with bulk query
        let rowY = y + 25;
        let totalEffectivePresent = 0;
        let totalAttendance = 0;

        const studentIds = students.map(s => s._id);

        const attendanceStats = await Attendance.aggregate([
            {
                $match: {
                    student: { $in: studentIds },
                    date: { $gte: startDate, $lte: endDate }
                }
            },
            {
                $group: {
                    _id: "$student",
                    totalClasses: { $sum: 1 },
                    presentClasses: {
                        $sum: { $cond: [{ $eq: ["$status", "Present"] }, 1, 0] }
                    },
                    lateClasses: {
                        $sum: { $cond: [{ $eq: ["$status", "Late"] }, 1, 0] }
                    }
                }
            }
        ]);

        const attendanceMap = {};
        attendanceStats.forEach(stat => {
            attendanceMap[stat._id.toString()] = stat;
        });

        for (let i = 0; i < students.length; i++) {
            const student = students[i];
            const studentIdStr = student._id.toString();

            const stats = attendanceMap[studentIdStr] || {
                totalClasses: 0,
                presentClasses: 0,
                lateClasses: 0
            };

            const totalClasses = stats.totalClasses;
            const presentClasses = stats.presentClasses;
            const lateClasses = stats.lateClasses;
            const effectiveClasses = effectivePresent(presentClasses, lateClasses, latePolicy);

            totalEffectivePresent += effectiveClasses;
            totalAttendance += totalClasses;

            const percentage = formatAttendancePercentage(
                presentClasses,
                lateClasses,
                totalClasses,
                latePolicy
            );

            // Row border
            doc.rect(40, rowY, 520, 25).stroke();

            // Row data
            doc.text(String(i + 1), 45, rowY + 8);
            doc.text(student.registerNo, 90, rowY + 8);
            doc.text(student.studentName, 180, rowY + 8, { width: 150 });
            doc.text(String(effectiveClasses), 350, rowY + 8);
            doc.text(String(totalClasses), 430, rowY + 8);
            doc.text(`${percentage}%`, 500, rowY + 8);

            rowY += 25;

            if (rowY > 750) {
                doc.addPage();
                rowY = 50;

                doc.rect(40, rowY, 520, 25).stroke();
                doc.text("Sl No", 45, rowY + 8);
                doc.text("Reg No", 90, rowY + 8);
                doc.text("Student Name", 180, rowY + 8);
                doc.text("Effective", 350, rowY + 8);
                doc.text("Total", 430, rowY + 8);
                doc.text("%", 500, rowY + 8);

                rowY += 25;
            }
        }

        const averageAttendance = totalAttendance === 0
            ? "0.00"
            : ((totalEffectivePresent / totalAttendance) * 100).toFixed(2);

        rowY += 20;
        doc.fontSize(10);
        doc.text(`Total Students : ${students.length}`, 40, rowY);
        doc.text(`Average Attendance : ${averageAttendance}%`, 250, rowY);

        // Signature Section
        rowY += 70;

        doc.moveTo(60, rowY).lineTo(180, rowY).stroke();
        doc.moveTo(380, rowY).lineTo(500, rowY).stroke();

        doc.text("Class In-Charge", 60, rowY + 5);
        doc.text("Head of Department", 380, rowY + 5);

        // Footer
        doc.fontSize(8);
        doc.text(
            `Generated On : ${new Date().toLocaleString()}`,
            40,
            780
        );
        doc.text(
            "Generated from College ERP System",
            40,
            795
        );

        doc.end();

    } catch (error) {
        console.error("PDF download generation failed");
        res.status(500).json({
            success: false,
            message: "Failed to generate PDF report",
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

// Student Overall Attendance PDF Report
exports.downloadStudentReport = async (req, res) => {
    try {
        const studentId = req.params.studentId;
        const student = await Student.findById(studentId);
        if (!student) {
            return res.status(404).json({
                success: false,
                message: "Student not found"
            });
        }

        if (req.user && req.user.role === "HOD") {
            const user = await User.findById(req.user.userId).select("role department");
            if (user && user.department && student.department && student.department !== user.department) {
                return res.status(403).json({ success: false, message: "Forbidden" });
            }
        }

        const totalClasses = await Attendance.countDocuments({
            student: studentId
        });
        const presentClasses = await Attendance.countDocuments({
            student: studentId,
            status: "Present"
        });
        const lateClasses = await Attendance.countDocuments({
            student: studentId,
            status: "Late"
        });
        const absentClasses = await Attendance.countDocuments({
            student: studentId,
            status: "Absent"
        });

        const attendancePct = formatAttendancePercentage(
            presentClasses,
            lateClasses,
            totalClasses,
            process.env.LATE_AS || "present"
        );

        const doc = new PDFDocument({ margin: 40, size: "A4" });

        res.setHeader("Content-Type", "application/pdf");
        res.setHeader(
            "Content-Disposition",
            `attachment; filename=${student.registerNo}.pdf`
        );

        doc.pipe(res);

        // Border and Header
        doc.rect(15, 15, 565, 810).stroke();
        const logoPath = path.join(__dirname, "../assets/college-logo.png");
        try {
            doc.image(logoPath, 40, 30, { width: 55 });
        } catch (_) {}

        doc.fontSize(18).text("MES M.K. MACKAR PILLAY COLLEGE", 110, 35);
        doc.fontSize(11).text("FOR ADVANCED STUDIES, EDATHALA", 110, 60);
        doc.fontSize(8).text("Affiliated to Mahatma Gandhi University", 110, 80);

        doc.fontSize(16).text("Student Attendance Report", { align: "center" });
        doc.moveDown();

        doc.fontSize(10);
        doc.text(`Student Name: ${student.studentName}`);
        doc.text(`Register No: ${student.registerNo}`);
        doc.text(`Total Classes: ${totalClasses}`);
        doc.text(`Present Classes: ${presentClasses}`);
        doc.text(`Late Classes: ${lateClasses}`);
        doc.text(`Absent Classes: ${absentClasses}`);
        doc.text(`Attendance: ${attendancePct}%`);

        // Signatures
        let rowY = 700;
        doc.moveTo(60, rowY).lineTo(180, rowY).stroke();
        doc.moveTo(380, rowY).lineTo(500, rowY).stroke();
        doc.text("Class In-Charge", 60, rowY + 5);
        doc.text("Head of Department", 380, rowY + 5);

        // Footer
        doc.fontSize(8);
        doc.text(`Generated On : ${new Date().toLocaleString()}`, 40, 780);
        doc.text("Generated from College ERP System", 40, 795);

        doc.end();
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

// Subject Report (JSON)
exports.getSubjectReport = async (req, res) => {
    try {
        const subjectId = req.params.subjectId;
        const subject = await Subject.findById(subjectId);
        if (!subject) {
            return res.status(404).json({
                success: false,
                message: "Subject not found"
            });
        }

        const totalAttendance = await Attendance.countDocuments({
            subject: subjectId
        });
        const presentAttendance = await Attendance.countDocuments({
            subject: subjectId,
            status: "Present"
        });
        const lateAttendance = await Attendance.countDocuments({
            subject: subjectId,
            status: "Late"
        });

        const attendancePct = formatAttendancePercentage(
            presentAttendance,
            lateAttendance,
            totalAttendance,
            process.env.LATE_AS || "present"
        );

        res.status(200).json({
            success: true,
            report: {
                subjectName: subject.subjectName,
                subjectCode: subject.subjectCode,
                totalAttendance,
                presentAttendance,
                lateAttendance,
                attendancePercentage: attendancePct
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

// Student Subject-Wise Attendance PDF Report
exports.downloadStudentSubjectReport = async (req, res) => {
    try {
        const studentId = req.params.studentId;
        const student = await Student.findById(studentId);
        if (!student) {
            return res.status(404).json({
                success: false,
                message: "Student not found"
            });
        }

        if (req.user && req.user.role === "HOD") {
            const user = await User.findById(req.user.userId).select("role department");
            if (user && user.department && student.department && student.department !== user.department) {
                return res.status(403).json({ success: false, message: "Forbidden" });
            }
        }

        const latePolicy = process.env.LATE_AS || "present";

        // Query subject-wise attendance aggregation
        let subjects = [];
        try {
            subjects = await Attendance.aggregate([
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
                        subjectCode: "$subjectInfo.subjectCode",
                        totalClasses: 1,
                        present: 1,
                        late: 1,
                        absent: 1
                    }
                }
            ]);
        } catch (_) {}

        // Fallback for mock environments / simple query
        if (!subjects || subjects.length === 0) {
            const records = await Attendance.find({ student: student._id }).populate("subject");
            const bySubject = new Map();
            for (const rec of records) {
                const subId = rec.subject?._id?.toString() || rec.subject?.toString() || "unknown";
                const subName = rec.subject?.subjectName || "Subject";
                const subCode = rec.subject?.subjectCode || "SUB";
                const current = bySubject.get(subId) || {
                    subjectId: subId,
                    subjectName: subName,
                    subjectCode: subCode,
                    totalClasses: 0,
                    present: 0,
                    late: 0,
                    absent: 0
                };
                current.totalClasses += 1;
                if (rec.status === "Present") current.present += 1;
                if (rec.status === "Late") current.late += 1;
                if (rec.status === "Absent") current.absent += 1;
                bySubject.set(subId, current);
            }
            subjects = Array.from(bySubject.values());
        }

        const doc = new PDFDocument({ margin: 40, size: "A4" });
        res.setHeader("Content-Type", "application/pdf");
        res.setHeader(
            "Content-Disposition",
            `attachment; filename=${student.registerNo}-subject-attendance.pdf`
        );
        doc.pipe(res);

        // Border and Header
        doc.rect(15, 15, 565, 810).stroke();
        const logoPath = path.join(__dirname, "../assets/college-logo.png");
        try {
            doc.image(logoPath, 40, 30, { width: 55 });
        } catch (_) {}

        doc.fontSize(18).text("MES M.K. MACKAR PILLAY COLLEGE", 110, 35);
        doc.fontSize(11).text("FOR ADVANCED STUDIES, EDATHALA", 110, 60);
        doc.fontSize(8).text("Affiliated to Mahatma Gandhi University", 110, 80);

        doc.fontSize(15).text("Student Subject-Wise Attendance Report", 40, 105, { align: "center" });

        doc.fontSize(10);
        doc.text(`Student Name: ${student.studentName}`, 40, 135);
        doc.text(`Register No: ${student.registerNo}`, 40, 150);
        doc.text(`Department: ${student.department || "N/A"}`, 320, 135);

        // Table Header
        let rowY = 175;
        doc.rect(40, rowY, 520, 22).stroke();
        doc.fontSize(9);
        doc.text("Sl", 45, rowY + 6);
        doc.text("Subject Code", 70, rowY + 6);
        doc.text("Subject Name", 160, rowY + 6);
        doc.text("Present", 330, rowY + 6);
        doc.text("Late", 380, rowY + 6);
        doc.text("Absent", 425, rowY + 6);
        doc.text("Total", 475, rowY + 6);
        doc.text("%", 520, rowY + 6);
        rowY += 22;

        let totalClassesAll = 0;
        let totalPresentAll = 0;
        let totalLateAll = 0;
        let totalAbsentAll = 0;

        for (let i = 0; i < subjects.length; i++) {
            const subj = subjects[i];
            const pres = subj.present || 0;
            const late = subj.late || 0;
            const abs = subj.absent || 0;
            const tot = subj.totalClasses || (pres + late + abs);
            const pct = formatAttendancePercentage(pres, late, tot, latePolicy);

            totalClassesAll += tot;
            totalPresentAll += pres;
            totalLateAll += late;
            totalAbsentAll += abs;

            doc.rect(40, rowY, 520, 20).stroke();
            doc.text(String(i + 1), 45, rowY + 5);
            doc.text(subj.subjectCode || "-", 70, rowY + 5);
            doc.text(subj.subjectName || "Subject", 160, rowY + 5, { width: 160 });
            doc.text(String(pres), 330, rowY + 5);
            doc.text(String(late), 380, rowY + 5);
            doc.text(String(abs), 425, rowY + 5);
            doc.text(String(tot), 475, rowY + 5);
            doc.text(`${pct}%`, 520, rowY + 5);

            rowY += 20;

            if (rowY > 730) {
                doc.addPage();
                doc.rect(15, 15, 565, 810).stroke();
                rowY = 40;
                doc.rect(40, rowY, 520, 22).stroke();
                doc.text("Sl", 45, rowY + 6);
                doc.text("Subject Code", 70, rowY + 6);
                doc.text("Subject Name", 160, rowY + 6);
                doc.text("Present", 330, rowY + 6);
                doc.text("Late", 380, rowY + 6);
                doc.text("Absent", 425, rowY + 6);
                doc.text("Total", 475, rowY + 6);
                doc.text("%", 520, rowY + 6);
                rowY += 22;
            }
        }

        if (subjects.length === 0) {
            doc.rect(40, rowY, 520, 25).stroke();
            doc.text("No subject attendance records found", 50, rowY + 8);
            rowY += 25;
        }

        const overallPct = formatAttendancePercentage(
            totalPresentAll,
            totalLateAll,
            totalClassesAll,
            latePolicy
        );

        rowY += 15;
        doc.fontSize(10);
        doc.text(`Total Subjects: ${subjects.length}`, 40, rowY);
        doc.text(`Total Classes: ${totalClassesAll}`, 160, rowY);
        doc.text(`Overall Attendance: ${overallPct}%`, 360, rowY);

        // Signatures
        const sigY = Math.max(rowY + 60, 700);
        doc.moveTo(60, sigY).lineTo(180, sigY).stroke();
        doc.moveTo(380, sigY).lineTo(500, sigY).stroke();
        doc.text("Class In-Charge", 60, sigY + 5);
        doc.text("Head of Department", 380, sigY + 5);

        // Footer
        doc.fontSize(8);
        doc.text(`Generated On : ${new Date().toLocaleString()}`, 40, 780);
        doc.text("Generated from College ERP System", 40, 795);

        doc.end();
    } catch (error) {
        console.error("Student subject report download failed", error);
        res.status(500).json({
            success: false,
            message: "Failed to generate subject attendance report"
        });
    }
};

// Subject Overall Attendance PDF Report
exports.downloadSubjectReport = async (req, res) => {
    try {
        const subjectId = req.params.subjectId;
        const subject = await Subject.findById(subjectId);
        if (!subject) {
            return res.status(404).json({
                success: false,
                message: "Subject not found"
            });
        }

        if (req.user && req.user.role === "HOD") {
            const user = await User.findById(req.user.userId).select("role department");
            if (!user || !user.department) {
                return res.status(403).json({ success: false, message: "Forbidden" });
            }
            const dept = await Department.findOne({ departmentName: user.department }).select("_id");
            if (!dept || (subject.departments && subject.departments.length > 0 &&
                !subject.departments.some(d => String(d) === String(dept._id)))) {
                return res.status(403).json({ success: false, message: "Forbidden" });
            }
        }

        const latePolicy = process.env.LATE_AS || "present";
        const totalAttendance = await Attendance.countDocuments({ subject: subjectId });
        const presentAttendance = await Attendance.countDocuments({ subject: subjectId, status: "Present" });
        const lateAttendance = await Attendance.countDocuments({ subject: subjectId, status: "Late" });
        const absentAttendance = await Attendance.countDocuments({ subject: subjectId, status: "Absent" });

        const attendancePct = formatAttendancePercentage(
            presentAttendance,
            lateAttendance,
            totalAttendance,
            latePolicy
        );

        const doc = new PDFDocument({ margin: 40, size: "A4" });
        res.setHeader("Content-Type", "application/pdf");
        res.setHeader(
            "Content-Disposition",
            `attachment; filename=${subject.subjectCode}-attendance-report.pdf`
        );
        doc.pipe(res);

        // Border and Header
        doc.rect(15, 15, 565, 810).stroke();
        const logoPath = path.join(__dirname, "../assets/college-logo.png");
        try {
            doc.image(logoPath, 40, 30, { width: 55 });
        } catch (_) {}

        doc.fontSize(18).text("MES M.K. MACKAR PILLAY COLLEGE", 110, 35);
        doc.fontSize(11).text("FOR ADVANCED STUDIES, EDATHALA", 110, 60);
        doc.fontSize(8).text("Affiliated to Mahatma Gandhi University", 110, 80);

        doc.fontSize(15).text("Subject Overall Attendance Report", 40, 110, { align: "center" });

        doc.fontSize(10);
        doc.text(`Subject Name : ${subject.subjectName}`, 50, 145);
        doc.text(`Subject Code : ${subject.subjectCode}`, 50, 165);
        doc.text(`Semester     : Semester ${subject.semester || "N/A"}`, 320, 145);
        doc.text(`Credits      : ${subject.credits || 4}`, 320, 165);

        // Summary Statistics Box
        let boxY = 200;
        doc.rect(40, boxY, 520, 140).stroke();
        doc.fontSize(12).text("Attendance Summary", 50, boxY + 12);

        doc.fontSize(10);
        doc.text(`Total Attendance Sessions / Records : ${totalAttendance}`, 60, boxY + 40);
        doc.text(`Present Classes                      : ${presentAttendance}`, 60, boxY + 60);
        doc.text(`Late Classes                         : ${lateAttendance}`, 60, boxY + 80);
        doc.text(`Absent Classes                       : ${absentAttendance}`, 60, boxY + 100);
        doc.fontSize(11).text(`Overall Attendance Percentage       : ${attendancePct}%`, 60, boxY + 120);

        // Signatures
        let sigY = 700;
        doc.moveTo(60, sigY).lineTo(180, sigY).stroke();
        doc.moveTo(380, sigY).lineTo(500, sigY).stroke();
        doc.fontSize(10);
        doc.text("Subject Teacher", 60, sigY + 5);
        doc.text("Head of Department", 380, sigY + 5);

        // Footer
        doc.fontSize(8);
        doc.text(`Generated On : ${new Date().toLocaleString()}`, 40, 780);
        doc.text("Generated from College ERP System", 40, 795);

        doc.end();
    } catch (error) {
        console.error("Subject report download failed", error);
        res.status(500).json({
            success: false,
            message: "Failed to generate subject report"
        });
    }
};

// Full Batch Attendance PDF Report (All-Time)
exports.downloadFullBatchReport = async (req, res) => {
    try {
        const batchId = req.params.batchId;
        const batch = await Batch.findById(batchId);
        if (!batch) {
            return res.status(404).json({
                success: false,
                message: "Batch not found"
            });
        }

        if (req.user && req.user.role === "HOD") {
            const user = await User.findById(req.user.userId).select("role department");
            if (user && user.department && batch.department !== user.department) {
                return res.status(403).json({ success: false, message: "Forbidden" });
            }
        }

        const latePolicy = process.env.LATE_AS || "present";
        const students = await Student.find({ batchId: batch._id });

        const doc = new PDFDocument({ margin: 40, size: "A4" });
        res.setHeader("Content-Type", "application/pdf");
        res.setHeader(
            "Content-Disposition",
            `attachment; filename=${batch.batchName}-full-attendance-report.pdf`
        );
        doc.pipe(res);

        // Border and Header
        doc.rect(15, 15, 565, 810).stroke();
        const logoPath = path.join(__dirname, "../assets/college-logo.png");
        try {
            doc.image(logoPath, 40, 30, { width: 55 });
        } catch (_) {}

        doc.fontSize(18).text("MES M.K. MACKAR PILLAY COLLEGE", 110, 35);
        doc.fontSize(11).text("FOR ADVANCED STUDIES, EDATHALA", 110, 60);
        doc.fontSize(8).text("Affiliated to Mahatma Gandhi University", 110, 80);

        doc.fontSize(15).text("Batch Full Attendance Report", 40, 105, { align: "center" });

        doc.fontSize(10);
        doc.text(`Batch: ${batch.batchName}`, 40, 135);
        doc.text(`Department: ${batch.department}`, 40, 150);
        doc.text(`Program: ${batch.program || "BCA"}`, 320, 135);
        doc.text(`Semester: ${batch.currentSemester || 1}`, 320, 150);

        // Table Header
        let rowY = 175;
        doc.rect(40, rowY, 520, 25).stroke();
        doc.fontSize(9);
        doc.text("Sl No", 45, rowY + 8);
        doc.text("Reg No", 90, rowY + 8);
        doc.text("Student Name", 180, rowY + 8);
        doc.text("Effective", 350, rowY + 8);
        doc.text("Total", 430, rowY + 8);
        doc.text("%", 500, rowY + 8);
        rowY += 25;

        let totalEffectivePresent = 0;
        let totalAttendance = 0;

        for (let i = 0; i < students.length; i++) {
            const student = students[i];
            const presentClasses = await Attendance.countDocuments({
                student: student._id,
                status: "Present"
            });
            const lateClasses = await Attendance.countDocuments({
                student: student._id,
                status: "Late"
            });
            const absentClasses = await Attendance.countDocuments({
                student: student._id,
                status: "Absent"
            });
            const totalClasses = presentClasses + lateClasses + absentClasses;
            const effectiveClasses = effectivePresent(presentClasses, lateClasses, latePolicy);

            totalEffectivePresent += effectiveClasses;
            totalAttendance += totalClasses;

            const percentage = formatAttendancePercentage(
                presentClasses,
                lateClasses,
                totalClasses,
                latePolicy
            );

            doc.rect(40, rowY, 520, 22).stroke();
            doc.text(String(i + 1), 45, rowY + 6);
            doc.text(student.registerNo, 90, rowY + 6);
            doc.text(student.studentName, 180, rowY + 6, { width: 160 });
            doc.text(String(effectiveClasses), 350, rowY + 6);
            doc.text(String(totalClasses), 430, rowY + 6);
            doc.text(`${percentage}%`, 500, rowY + 6);

            rowY += 22;

            if (rowY > 730) {
                doc.addPage();
                doc.rect(15, 15, 565, 810).stroke();
                rowY = 40;
                doc.rect(40, rowY, 520, 25).stroke();
                doc.text("Sl No", 45, rowY + 8);
                doc.text("Reg No", 90, rowY + 8);
                doc.text("Student Name", 180, rowY + 8);
                doc.text("Effective", 350, rowY + 8);
                doc.text("Total", 430, rowY + 8);
                doc.text("%", 500, rowY + 8);
                rowY += 25;
            }
        }

        const averageAttendance = totalAttendance === 0
            ? "0.00"
            : ((totalEffectivePresent / totalAttendance) * 100).toFixed(2);

        rowY += 20;
        doc.fontSize(10);
        doc.text(`Total Students : ${students.length}`, 40, rowY);
        doc.text(`Average Attendance : ${averageAttendance}%`, 250, rowY);

        // Signatures
        const sigY = Math.max(rowY + 60, 700);
        doc.moveTo(60, sigY).lineTo(180, sigY).stroke();
        doc.moveTo(380, sigY).lineTo(500, sigY).stroke();
        doc.text("Class In-Charge", 60, sigY + 5);
        doc.text("Head of Department", 380, sigY + 5);

        // Footer
        doc.fontSize(8);
        doc.text(`Generated On : ${new Date().toLocaleString()}`, 40, 780);
        doc.text("Generated from College ERP System", 40, 795);

        doc.end();
    } catch (error) {
        console.error("Full batch report download failed", error);
        res.status(500).json({
            success: false,
            message: "Failed to generate full batch report"
        });
    }
};

// Department Attendance PDF Report
exports.downloadDepartmentReport = async (req, res) => {
    try {
        let department;
        const user = req.user && req.user.userId
            ? await User.findById(req.user.userId).select("role department")
            : null;

        if (req.params.departmentId) {
            department = await Department.findById(req.params.departmentId);
            if (department && user && user.role === "HOD" && user.department && department.departmentName !== user.department) {
                return res.status(403).json({ success: false, message: "Forbidden" });
            }
        } else {
            if (user && user.department) {
                department = await Department.findOne({ departmentName: user.department });
            }
        }

        if (!department) {
            return res.status(404).json({
                success: false,
                message: "Department not found"
            });
        }

        const latePolicy = process.env.LATE_AS || "present";
        const batches = await Batch.find({ department: department.departmentName });
        const students = await Student.find({ department: department.departmentName });

        const doc = new PDFDocument({ margin: 40, size: "A4" });
        res.setHeader("Content-Type", "application/pdf");
        res.setHeader(
            "Content-Disposition",
            `attachment; filename=${department.departmentCode || "department"}-attendance-report.pdf`
        );
        doc.pipe(res);

        // Border and Header
        doc.rect(15, 15, 565, 810).stroke();
        const logoPath = path.join(__dirname, "../assets/college-logo.png");
        try {
            doc.image(logoPath, 40, 30, { width: 55 });
        } catch (_) {}

        doc.fontSize(18).text("MES M.K. MACKAR PILLAY COLLEGE", 110, 35);
        doc.fontSize(11).text("FOR ADVANCED STUDIES, EDATHALA", 110, 60);
        doc.fontSize(8).text("Affiliated to Mahatma Gandhi University", 110, 80);

        doc.fontSize(15).text("Department Attendance Report", 40, 105, { align: "center" });

        doc.fontSize(10);
        doc.text(`Department : ${department.departmentName}`, 40, 135);
        doc.text(`Code       : ${department.departmentCode || "N/A"}`, 40, 150);
        doc.text(`HOD        : ${department.hodName || "Head of Department"}`, 320, 135);
        doc.text(`Total Classes/Batches : ${batches.length}`, 320, 150);

        // Table Header
        let rowY = 175;
        doc.rect(40, rowY, 520, 22).stroke();
        doc.fontSize(9);
        doc.text("Sl", 45, rowY + 6);
        doc.text("Batch Name", 70, rowY + 6);
        doc.text("Semester", 220, rowY + 6);
        doc.text("Students", 280, rowY + 6);
        doc.text("Classes", 350, rowY + 6);
        doc.text("Avg %", 420, rowY + 6);
        doc.text("Defaulters", 480, rowY + 6);
        rowY += 22;

        let totalDeptEffective = 0;
        let totalDeptClasses = 0;
        let totalDeptDefaulters = 0;

        for (let i = 0; i < batches.length; i++) {
            const batch = batches[i];
            const batchStudents = students.filter(
                (s) => String(s.batchId) === String(batch._id)
            );

            let bEffective = 0;
            let bTotal = 0;
            let bDefaulters = 0;

            for (const st of batchStudents) {
                const pres = await Attendance.countDocuments({ student: st._id, status: "Present" });
                const late = await Attendance.countDocuments({ student: st._id, status: "Late" });
                const abs = await Attendance.countDocuments({ student: st._id, status: "Absent" });
                const tot = pres + late + abs;
                const eff = effectivePresent(pres, late, latePolicy);
                const pct = tot === 0 ? 0 : attendancePercentage(pres, late, tot, latePolicy);
                if (pct < 75) bDefaulters++;

                bEffective += eff;
                bTotal += tot;
            }

            totalDeptEffective += bEffective;
            totalDeptClasses += bTotal;
            totalDeptDefaulters += bDefaulters;

            const bAvgPct = bTotal === 0 ? "0.00" : ((bEffective / bTotal) * 100).toFixed(2);

            doc.rect(40, rowY, 520, 20).stroke();
            doc.text(String(i + 1), 45, rowY + 5);
            doc.text(batch.batchName, 70, rowY + 5, { width: 140 });
            doc.text(`Sem ${batch.currentSemester || 1}`, 220, rowY + 5);
            doc.text(String(batchStudents.length), 280, rowY + 5);
            doc.text(String(bTotal), 350, rowY + 5);
            doc.text(`${bAvgPct}%`, 420, rowY + 5);
            doc.text(String(bDefaulters), 480, rowY + 5);

            rowY += 20;

            if (rowY > 730) {
                doc.addPage();
                doc.rect(15, 15, 565, 810).stroke();
                rowY = 40;
                doc.rect(40, rowY, 520, 22).stroke();
                doc.text("Sl", 45, rowY + 6);
                doc.text("Batch Name", 70, rowY + 6);
                doc.text("Semester", 220, rowY + 6);
                doc.text("Students", 280, rowY + 6);
                doc.text("Classes", 350, rowY + 6);
                doc.text("Avg %", 420, rowY + 6);
                doc.text("Defaulters", 480, rowY + 6);
                rowY += 22;
            }
        }

        const deptAvgPct = totalDeptClasses === 0
            ? "0.00"
            : ((totalDeptEffective / totalDeptClasses) * 100).toFixed(2);

        rowY += 15;
        doc.fontSize(10);
        doc.text(`Total Students: ${students.length}`, 40, rowY);
        doc.text(`Total Defaulters (< 75%): ${totalDeptDefaulters}`, 180, rowY);
        doc.text(`Department Attendance: ${deptAvgPct}%`, 360, rowY);

        // Signatures
        const sigY = Math.max(rowY + 60, 700);
        doc.moveTo(60, sigY).lineTo(180, sigY).stroke();
        doc.moveTo(380, sigY).lineTo(500, sigY).stroke();
        doc.text("Verified By", 60, sigY + 5);
        doc.text("Head of Department", 380, sigY + 5);

        // Footer
        doc.fontSize(8);
        doc.text(`Generated On : ${new Date().toLocaleString()}`, 40, 780);
        doc.text("Generated from College ERP System", 40, 795);

        doc.end();
    } catch (error) {
        console.error("Department report download failed", error);
        res.status(500).json({
            success: false,
            message: "Failed to generate department attendance report"
        });
    }
};

// Defaulter Attendance PDF Report (< 75%)
exports.downloadDefaultersReport = async (req, res) => {
    try {
        const user = await User.findById(req.user.userId).select("role department");
        if (!user || user.role !== "HOD" || !user.department) {
            return res.status(403).json({ success: false, message: "Forbidden" });
        }

        let students = [];
        let scopeTitle = "";

        const batchId = req.params.batchId || req.query.batchId;
        if (batchId) {
            const batch = await Batch.findById(batchId);
            if (!batch) {
                return res.status(404).json({
                    success: false,
                    message: "Batch not found"
                });
            }
            if (batch.department !== user.department) {
                return res.status(403).json({ success: false, message: "Forbidden" });
            }
            scopeTitle = `Batch: ${batch.batchName} (${batch.department})`;
            students = await Student.find({ batchId: batch._id, department: user.department });
        } else {
            scopeTitle = `Department: ${user.department}`;
            students = await Student.find({ department: user.department });
        }

        const latePolicy = process.env.LATE_AS || "present";
        const defaulters = [];

        for (const student of students) {
            const presentClasses = await Attendance.countDocuments({
                student: student._id,
                status: "Present"
            });
            const lateClasses = await Attendance.countDocuments({
                student: student._id,
                status: "Late"
            });
            const absentClasses = await Attendance.countDocuments({
                student: student._id,
                status: "Absent"
            });
            const totalClasses = presentClasses + lateClasses + absentClasses;
            const percentage = totalClasses === 0
                ? 0
                : attendancePercentage(presentClasses, lateClasses, totalClasses, latePolicy);

            if (percentage < 75) {
                defaulters.push({
                    studentId: student._id,
                    studentName: student.studentName,
                    registerNo: student.registerNo,
                    presentClasses,
                    lateClasses,
                    absentClasses,
                    totalClasses,
                    attendancePercentage: percentage.toFixed(2)
                });
            }
        }

        const doc = new PDFDocument({ margin: 40, size: "A4" });
        res.setHeader("Content-Type", "application/pdf");
        res.setHeader(
            "Content-Disposition",
            `attachment; filename=defaulters-report.pdf`
        );
        doc.pipe(res);

        // Border and Header
        doc.rect(15, 15, 565, 810).stroke();
        const logoPath = path.join(__dirname, "../assets/college-logo.png");
        try {
            doc.image(logoPath, 40, 30, { width: 55 });
        } catch (_) {}

        doc.fontSize(18).text("MES M.K. MACKAR PILLAY COLLEGE", 110, 35);
        doc.fontSize(11).text("FOR ADVANCED STUDIES, EDATHALA", 110, 60);
        doc.fontSize(8).text("Affiliated to Mahatma Gandhi University", 110, 80);

        doc.fontSize(15).text("Defaulter Attendance Report (< 75%)", 40, 105, { align: "center" });

        doc.fontSize(10);
        doc.text(scopeTitle, 40, 135);
        doc.text("Threshold: Attendance below 75%", 40, 150);
        doc.text(`Total Students Evaluated: ${students.length}`, 320, 135);
        doc.text(`Total Defaulters: ${defaulters.length}`, 320, 150);

        // Table Header
        let rowY = 175;
        doc.rect(40, rowY, 520, 22).stroke();
        doc.fontSize(9);
        doc.text("Sl", 45, rowY + 6);
        doc.text("Reg No", 75, rowY + 6);
        doc.text("Student Name", 170, rowY + 6);
        doc.text("Present", 330, rowY + 6);
        doc.text("Late", 380, rowY + 6);
        doc.text("Absent", 425, rowY + 6);
        doc.text("Total", 475, rowY + 6);
        doc.text("%", 520, rowY + 6);
        rowY += 22;

        for (let i = 0; i < defaulters.length; i++) {
            const def = defaulters[i];
            doc.rect(40, rowY, 520, 20).stroke();
            doc.text(String(i + 1), 45, rowY + 5);
            doc.text(def.registerNo, 75, rowY + 5);
            doc.text(def.studentName, 170, rowY + 5, { width: 155 });
            doc.text(String(def.presentClasses), 330, rowY + 5);
            doc.text(String(def.lateClasses), 380, rowY + 5);
            doc.text(String(def.absentClasses), 425, rowY + 5);
            doc.text(String(def.totalClasses), 475, rowY + 5);
            doc.text(`${def.attendancePercentage}%`, 520, rowY + 5);

            rowY += 20;

            if (rowY > 730) {
                doc.addPage();
                doc.rect(15, 15, 565, 810).stroke();
                rowY = 40;
                doc.rect(40, rowY, 520, 22).stroke();
                doc.text("Sl", 45, rowY + 6);
                doc.text("Reg No", 75, rowY + 6);
                doc.text("Student Name", 170, rowY + 6);
                doc.text("Present", 330, rowY + 6);
                doc.text("Late", 380, rowY + 6);
                doc.text("Absent", 425, rowY + 6);
                doc.text("Total", 475, rowY + 6);
                doc.text("%", 520, rowY + 6);
                rowY += 22;
            }
        }

        if (defaulters.length === 0) {
            doc.rect(40, rowY, 520, 25).stroke();
            doc.text("No students found below the 75% attendance threshold", 50, rowY + 8);
            rowY += 25;
        }

        // Signatures
        const sigY = Math.max(rowY + 60, 700);
        doc.moveTo(60, sigY).lineTo(180, sigY).stroke();
        doc.moveTo(380, sigY).lineTo(500, sigY).stroke();
        doc.text("Class In-Charge", 60, sigY + 5);
        doc.text("Head of Department", 380, sigY + 5);

        // Footer
        doc.fontSize(8);
        doc.text(`Generated On : ${new Date().toLocaleString()}`, 40, 780);
        doc.text("Generated from College ERP System", 40, 795);

        doc.end();
    } catch (error) {
        console.error("Defaulters report download failed", error);
        res.status(500).json({
            success: false,
            message: "Failed to generate defaulters report"
        });
    }
};

exports.downloadBatchDefaultersReport = exports.downloadDefaultersReport;
