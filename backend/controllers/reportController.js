const PDFDocument = require("pdfkit");
const Attendance = require("../models/Attendance");
const Student = require("../models/Student");
const Batch = require("../models/Batch");
const Subject = require("../models/Subject");

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
            report: {
                studentName: student.studentName,
                registerNo: student.registerNo,
                totalClasses,
                presentClasses,
                absentClasses,
                attendancePercentage
            }
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
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

        const totalAttendance =
            await Attendance.countDocuments({
                batch: batchId
            });

        const presentAttendance =
            await Attendance.countDocuments({
                batch: batchId,
                status: "Present"
            });

        const attendancePercentage =
            totalAttendance === 0
                ? 0
                : ((presentAttendance / totalAttendance) * 100).toFixed(2);

        res.status(200).json({
            success: true,
            report: {
                batchName: batch.batchName,
                currentSemester: batch.currentSemester,
                totalAttendance,
                presentAttendance,
                attendancePercentage
            }
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};
// report preview
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
        const month = parseInt(req.query.month);
        const year = parseInt(req.query.year);

        if (month < 1 || month > 12) {
            return res.status(400).json({
                success: false,
                message: "Invalid month. Must be between 1-12"
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
        const endDate = new Date(year, month, 0, 23, 59, 59); // Last day of month

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
        doc.text("Present", 350, y + 8);
        doc.text("Total", 430, y + 8);
        doc.text("%", 500, y + 8);

        // Table Rows - Optimized with bulk query
        let rowY = y + 25;
        let totalPresent = 0;
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
                presentClasses: 0 
            };

            const totalClasses = stats.totalClasses;
            const presentClasses = stats.presentClasses;

            totalPresent += presentClasses;
            totalAttendance += totalClasses;

            const percentage = totalClasses === 0 
                ? 0 
                : ((presentClasses / totalClasses) * 100).toFixed(2);

            // Row border
            doc.rect(40, rowY, 520, 25).stroke();

            // Row data
            doc.text(String(i + 1), 45, rowY + 8);
            doc.text(student.registerNo, 90, rowY + 8);
            doc.text(student.studentName, 180, rowY + 8, { width: 150 });
            doc.text(String(presentClasses), 350, rowY + 8);
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
                doc.text("Present", 350, rowY + 8);
                doc.text("Total", 430, rowY + 8);
                doc.text("%", 500, rowY + 8);

                rowY += 25;
            }
        }

        // Summary Statistics
        const averageAttendance = totalAttendance === 0 
            ? 0 
            : ((totalPresent / totalAttendance) * 100).toFixed(2);

        rowY += 20;
        doc.fontSize(10);
        doc.text(`Total Students : ${students.length}`, 40, rowY);
        doc.text(`Average Attendance : ${averageAttendance}%`, 250, rowY);

        // Signature Section
        rowY += 70;
        
        doc.moveTo(60, rowY).lineTo(180, rowY).stroke();
        doc.moveTo(380, rowY).lineTo(500, rowY).stroke();
        
        doc.text("Class In-Charge", 60, rowY + 5);
        doc.text(
            "Head of Department",
            380,
            rowY + 5
        );

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
        console.error("Error generating PDF preview:", error);
        res.status(500).json({
            success: false,
            message: "Failed to generate report preview",
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};
// Student PDF Report
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

        // Fix 1: Declare month, year, and monthNames BEFORE using them
        const month = parseInt(req.query.month);
        const year = parseInt(req.query.year);

        if (month < 1 || month > 12) {
            return res.status(400).json({
                success: false,
                message: "Invalid month. Must be between 1-12"
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

        const students = await Student.find({
            batchId: batch._id
        }).sort({ registerNo: 1 });

        // Fix 5: Return 200 with empty array (not an error)
        if (students.length === 0) {
            return res.status(200).json({
                success: true,
                message: "No students found in this batch",
                students: []
            });
        }

        // Create date range for the specified month
        const startDate = new Date(year, month - 1, 1);
        const endDate = new Date(year, month, 0, 23, 59, 59); // Last day of month

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
        doc.text("Present", 350, y + 8);
        doc.text("Total", 430, y + 8);
        doc.text("%", 500, y + 8);

        // Table Rows - Optimized with bulk query
        let rowY = y + 25;
        let totalPresent = 0;
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
                presentClasses: 0 
            };

            const totalClasses = stats.totalClasses;
            const presentClasses = stats.presentClasses;

            totalPresent += presentClasses;
            totalAttendance += totalClasses;

            const percentage = totalClasses === 0 
                ? 0 
                : ((presentClasses / totalClasses) * 100).toFixed(2);

            // Row border
            doc.rect(40, rowY, 520, 25).stroke();

            // Row data
            doc.text(String(i + 1), 45, rowY + 8);
            doc.text(student.registerNo, 90, rowY + 8);
            doc.text(student.studentName, 180, rowY + 8, { width: 150 });
            doc.text(String(presentClasses), 350, rowY + 8);
            doc.text(String(totalClasses), 430, rowY + 8);
            doc.text(`${percentage}%`, 500, rowY + 8);

            rowY += 25;

            // Fix 4: New Page Header - Repeat table header on each new page
            if (rowY > 750) {
                doc.addPage();
                rowY = 50;

                // Redraw table header on new page
                doc.rect(40, rowY, 520, 25).stroke();
                doc.text("Sl No", 45, rowY + 8);
                doc.text("Reg No", 90, rowY + 8);
                doc.text("Student Name", 180, rowY + 8);
                doc.text("Present", 350, rowY + 8);
                doc.text("Total", 430, rowY + 8);
                doc.text("%", 500, rowY + 8);

                rowY += 25;
            }
        }

        // Summary Statistics
        const averageAttendance = totalAttendance === 0 
            ? 0 
            : ((totalPresent / totalAttendance) * 100).toFixed(2);

        rowY += 20;
        doc.fontSize(10);
        doc.text(`Total Students : ${students.length}`, 40, rowY);
        doc.text(`Average Attendance : ${averageAttendance}%`, 250, rowY);

        // Signature Section
        rowY += 70;
        
        doc.moveTo(60, rowY).lineTo(180, rowY).stroke();
        doc.moveTo(380, rowY).lineTo(500, rowY).stroke();
        
        doc.text("Class In-Charge", 60, rowY + 5);
        
        // Fix 2: Corrected HoD text alignment and label
        doc.text(
            "Head of Department",
            380,
            rowY + 5
        );

        // Fix 3: Footer section before doc.end()
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
        console.error("Error generating PDF report:", error);
        res.status(500).json({
            success: false,
            message: "Failed to generate report",
            error: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
    }
};

exports.downloadStudentReport = async (req, res) => {

    try {

        const studentId =
            req.params.studentId;

        const student =
            await Student.findById(
                studentId
            );

        if (!student) {

            return res.status(404).json({
                success: false,
                message: "Student not found"
            });

        }

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
                : (
                    (presentClasses /
                        totalClasses) * 100
                ).toFixed(2);

        const doc =
            new PDFDocument();

        res.setHeader(
            "Content-Type",
            "application/pdf"
        );

        res.setHeader(
            "Content-Disposition",
            `attachment; filename=${student.registerNo}.pdf`
        );

        doc.pipe(res);

        doc.fontSize(20)
            .text(
                "Student Attendance Report",
                {
                    align: "center"
                }
            );

        doc.moveDown();

        doc.text(
            `Student Name: ${student.studentName}`
        );

        doc.text(
            `Register No: ${student.registerNo}`
        );

        doc.text(
            `Total Classes: ${totalClasses}`
        );

        doc.text(
            `Present Classes: ${presentClasses}`
        );

        doc.text(
            `Absent Classes: ${absentClasses}`
        );

        doc.text(
            `Attendance: ${attendancePercentage}%`
        );

        doc.end();

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};
// Subject Report
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

        const totalAttendance =
            await Attendance.countDocuments({
                subject: subjectId
            });

        const presentAttendance =
            await Attendance.countDocuments({
                subject: subjectId,
                status: "Present"
            });

        const attendancePercentage =
            totalAttendance === 0
                ? 0
                : ((presentAttendance / totalAttendance) * 100).toFixed(2);

        res.status(200).json({
            success: true,
            report: {
                subjectName: subject.subjectName,
                subjectCode: subject.subjectCode,
                totalAttendance,
                presentAttendance,
                attendancePercentage
            }
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};