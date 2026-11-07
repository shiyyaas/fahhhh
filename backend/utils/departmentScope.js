const User = require("../models/User");
const Department = require("../models/Department");
const Student = require("../models/Student");
const Teacher = require("../models/Teacher");
const Batch = require("../models/Batch");

exports.getDepartmentScope = async (req) => {
    const user = await User.findById(req.user.userId).select("email role department");
    if (!user || user.role !== req.user.role) return null;

    if (user.role === "HOD") {
        if (!user.department) return null;
        const department = await Department.findOne({
            departmentName: user.department
        }).select("_id departmentName");
        return department
            ? {
                departmentIds: [department._id],
                departmentNames: [department.departmentName],
                batchIds: null
            }
            : null;
    }

    if (user.role === "TEACHER") {
        const teacher = await Teacher.findOne({ email: user.email }).select("departments");
        if (!teacher || !Array.isArray(teacher.departments) ||
            teacher.departments.length === 0) return null;
        const departments = await Department.find({
            _id: { $in: teacher.departments }
        }).select("_id departmentName");
        if (departments.length !== teacher.departments.length) return null;
        return {
            departmentIds: departments.map((department) => department._id),
            departmentNames: departments.map((department) => department.departmentName),
            batchIds: null,
            teacherId: teacher._id
        };
    }

    if (user.role === "STUDENT") {
        const student = await Student.findOne({ email: user.email })
            .select("department batchId");
        if (!student || typeof student.department !== "string" ||
            !student.department.trim() || !student.batchId) return null;
        const department = await Department.findOne({
            departmentName: student.department
        }).select("_id departmentName");
        if (!department) return null;
        const batch = await Batch.findOne({
            _id: student.batchId,
            department: student.department
        }).select("_id");
        if (!batch) return null;
        return {
            departmentIds: [department._id],
            departmentNames: [department.departmentName],
            batchIds: [batch._id]
        };
    }

    return null;
};
