const Attendance = require("../models/Attendance");

// Mark Attendance
exports.markAttendance = async (req, res) => {
    try {

        const {
            student,
            subject,
            teacher,
            batch,
            status
        } = req.body;

        const attendance =
            await Attendance.create({
                student,
                subject,
                teacher,
                batch,
                status
            });

        res.status(201).json({
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