const Student = require("../models/Student");
const Teacher = require("../models/Teacher");
const Department = require("../models/Department");
const Subject = require("../models/Subject");
const Batch = require("../models/Batch");
const Attendance = require("../models/Attendance");
const Timetable = require("../models/Timetable");

// General Dashboard

exports.getDashboardStats = async (req, res) => {
    try {

        const totalStudents =
            await Student.countDocuments();

        const totalTeachers =
            await Teacher.countDocuments();

        const totalDepartments =
            await Department.countDocuments();

        const totalSubjects =
            await Subject.countDocuments();

        const totalBatches =
            await Batch.countDocuments();

        const totalAttendanceRecords =
            await Attendance.countDocuments();

        res.status(200).json({
            success: true,
            stats: {
                totalStudents,
                totalTeachers,
                totalDepartments,
                totalSubjects,
                totalBatches,
                totalAttendanceRecords
            }
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};

// HOD Dashboard

exports.getHodDashboard = async (req, res) => {

    try {

        const totalStudents =
            await Student.countDocuments();

        const totalTeachers =
            await Teacher.countDocuments();

        const totalSubjects =
            await Subject.countDocuments();

        const totalBatches =
            await Batch.countDocuments();

        const students =
            await Student.find();

        let totalDefaulters = 0;

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

            if (
                totalClasses > 0 &&
                percentage < 75
            ) {
                totalDefaulters++;
            }

        }

        res.status(200).json({
            success: true,
            dashboard: {
                totalStudents,
                totalTeachers,
                totalSubjects,
                totalBatches,
                totalDefaulters
            }
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

// Teacher Dashboard

exports.getTeacherDashboard = async (req, res) => {

    try {

        const teacherId =
            req.params.teacherId;

        const teacher =
            await Teacher.findById(
                teacherId
            );

        if (!teacher) {
            return res.status(404).json({
                success: false,
                message: "Teacher not found"
            });
        }

        const subjectsAssigned =
            await Subject.countDocuments({
                teachers: teacherId
            });

        const timetableEntries =
            await Timetable.countDocuments({
                teacher: teacherId
            });

        const totalStudents =
            await Student.countDocuments();

        res.status(200).json({
            success: true,
            dashboard: {
                teacherName:
                    teacher.teacherName,
                subjectsAssigned,
                timetableEntries,
                totalStudents
            }
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

// Student Dashboard

exports.getStudentDashboard = async (req, res) => {

    try {

        const studentId =
            req.params.studentId;

        const student =
            await Student.findById(
                studentId
            ).populate("batchId");

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

        res.status(200).json({
            success: true,
            dashboard: {
                studentName:
                    student.studentName,
                registerNo:
                    student.registerNo,
                batch:
                    student.batchId.batchName,
                currentSemester:
                    student.batchId.currentSemester,
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