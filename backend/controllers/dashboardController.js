const Student = require("../models/Student");
const Teacher = require("../models/Teacher");
const Department = require("../models/Department");
const Subject = require("../models/Subject");
const Batch = require("../models/Batch");
const Attendance = require("../models/Attendance");
const User = require("../models/User");
const Timetable = require("../models/Timetable");
const {
    attendancePercentage,
    formatAttendancePercentage
} = require("../utils/attendanceCalculations");

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
            message: "Internal server error"
        });

    }
};

// HOD Dashboard

exports.getHodDashboard = async (req, res) => {

    try {

        const user = await User.findById(req.user.userId)
            .select("role department");
        const department = user && user.role === "HOD" && user.department
            ? await Department.findOne({ departmentName: user.department }).select("_id")
            : null;
        if (!department) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }
        const totalStudents =
            await Student.countDocuments({ department: user.department });

        const totalTeachers =
            await Teacher.countDocuments({ departments: department._id });

        const totalSubjects =
            await Subject.countDocuments({ departments: department._id });

        const totalBatches =
            await Batch.countDocuments({ department: user.department });

        const students =
            await Student.find({ department: user.department });

        let totalDefaulters = 0;

        for (const student of students) {

            const presentClasses =
                await Attendance.countDocuments({
                    student: student._id,
                    status: "Present"
                });

            const lateClasses =
                await Attendance.countDocuments({
                    student: student._id,
                    status: "Late"
                });

            const absentClasses =
                await Attendance.countDocuments({
                    student: student._id,
                    status: "Absent"
                });

            const totalClasses = presentClasses + lateClasses + absentClasses;
            const percentage = attendancePercentage(
                presentClasses,
                lateClasses,
                totalClasses,
                process.env.LATE_AS || "present"
            );

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
            message: "Internal server error"
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
                teachers: teacher._id
            });

        const timetableEntries =
            await Timetable.countDocuments({
                teacher: teacherId
            });

        const departments = await Department.find({
            _id: { $in: teacher.departments }
        }).select("departmentName");
        const departmentNames = departments.map((department) => department.departmentName);
        const totalStudents = departmentNames.length
            ? await Student.countDocuments({
                department: { $in: departmentNames }
            })
            : 0;

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
            message: "Internal server error"
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

        const lateClasses =
            await Attendance.countDocuments({
            student: studentId,
            status: "Late"
            });

        const absentClasses =
            await Attendance.countDocuments({
                student: studentId,
                status: "Absent"
            });

        const attendancePercentage = formatAttendancePercentage(
            presentClasses,
            lateClasses,
            totalClasses,
            process.env.LATE_AS || "present"
        );

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