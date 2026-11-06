const Subject = require("../models/Subject");
const User = require("../models/User");
const Department = require("../models/Department");
const Teacher = require("../models/Teacher");
const { getDepartmentScope } = require("../utils/departmentScope");
const mongoose = require("mongoose");

const validateHodSubjectAssignments = async (req, departments, teachers) => {
    const user = await User.findById(req.user.userId)
        .select("role department");
    const department = user && user.role === "HOD" && user.department
        ? await Department.findOne({ departmentName: user.department }).select("_id")
        : null;
    if (!department || !Array.isArray(departments) ||
        !departments.some((id) => String(id) === String(department._id)) ||
        departments.some((id) => String(id) !== String(department._id))) {
        return false;
    }
    if (teachers && teachers.length > 0) {
        const teacherCount = await Teacher.countDocuments({
            _id: { $in: teachers },
            departments: department._id
        });
        if (teacherCount !== teachers.length) return false;
    }
    return true;
};

// Create Subject
exports.createSubject = async (req, res) => {
    try {

        const {
            subjectName,
            subjectCode,
            departments,
            teachers,
            semester,
            credits
        } = req.body;
        if (!await validateHodSubjectAssignments(req, departments, teachers)) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }

        const existingSubject =
            await Subject.findOne({
                subjectCode
            });

        if (existingSubject) {
            return res.status(400).json({
                success: false,
                message: "Subject already exists"
            });
        }

        const subject =
            await Subject.create({
                subjectName,
                subjectCode,
                departments,
                teachers,
                semester,
                credits
            });

        res.status(201).json({
            success: true,
            message: "Subject created successfully",
            subject
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Internal server error"
        });

    }
};

// Get All Subjects
exports.getSubjects = async (req, res) => {
    try {

        const scope = await getDepartmentScope(req);
        if (!scope) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }
        const subjects =
            await Subject.find({ departments: { $in: scope.departmentIds } })
                .populate("departments")
                .populate({
                    path: "teachers",
                    select: "teacherName avatar"
                })
                .sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            subjects
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Internal server error"
        });

    }
};

// Get Single Subject
exports.getSubject = async (req, res) => {
    try {

        if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
            return res.status(400).json({
                success: false,
                message: "Invalid subject ID"
            });
        }
        const scope = await getDepartmentScope(req);
        if (!scope) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }
        const subject =
            await Subject.findOne({
                _id: req.params.id,
                departments: { $in: scope.departmentIds }
            })
                .populate("departments")
                .populate({
                    path: "teachers",
                    select: "teacherName avatar"
                });

        if (!subject) {
            return res.status(404).json({
                success: false,
                message: "Subject not found"
            });
        }

        res.status(200).json({
            success: true,
            subject
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Internal server error"
        });

    }
};

// Update Subject
exports.updateSubject = async (req, res) => {
    try {
        if (Object.hasOwn(req.body, "departments") ||
            Object.hasOwn(req.body, "teachers")) {
            const current = await Subject.findById(req.params.id)
                .select("departments teachers");
            if (!current) {
                return res.status(404).json({
                    success: false,
                    message: "Subject not found"
                });
            }
            const departments = Object.hasOwn(req.body, "departments")
                ? req.body.departments
                : current.departments;
            const teachers = Object.hasOwn(req.body, "teachers")
                ? req.body.teachers
                : current.teachers;
            if (!await validateHodSubjectAssignments(req, departments, teachers)) {
                return res.status(403).json({
                    success: false,
                    message: "Forbidden"
                });
            }
        }

        const subject =
            await Subject.findByIdAndUpdate(
                req.params.id,
                {
                    $set: Object.fromEntries(
                        ["subjectName", "subjectCode", "departments", "teachers", "semester", "credits"]
                            .filter((field) => Object.hasOwn(req.body, field))
                            .map((field) => [field, req.body[field]])
                    )
                },
                { new: true, runValidators: true }
            )
                .populate("departments")
                .populate({
                    path: "teachers",
                    select: "teacherName avatar"
                });

        if (!subject) {
            return res.status(404).json({
                success: false,
                message: "Subject not found"
            });
        }

        res.status(200).json({
            success: true,
            message: "Subject updated successfully",
            subject
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Internal server error"
        });

    }
};

// Delete Subject
exports.deleteSubject = async (req, res) => {
    try {

        const subject =
            await Subject.findByIdAndDelete(
                req.params.id
            );

        if (!subject) {
            return res.status(404).json({
                success: false,
                message: "Subject not found"
            });
        }

        res.status(200).json({
            success: true,
            message: "Subject deleted successfully"
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Internal server error"
        });

    }
};