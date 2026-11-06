const Teacher = require("../models/Teacher");
const Department = require("../models/Department");
const User = require("../models/User");
const Subject = require("../models/Subject");
const bcrypt = require("bcryptjs");
const crypto = require("crypto");

// Create Teacher
exports.createTeacher = async (req, res) => {
    try {

        const {
            teacherName,
            employeeId,
            email,
            phoneNo,
            departments
        } = req.body;
        const creator = await User.findById(req.user.userId)
            .select("role department");
        const ownDepartment = creator && creator.role === "HOD" && creator.department
            ? await Department.findOne({ departmentName: creator.department }).select("_id")
            : null;
      if (!email || typeof email !== "string" || !email.trim()) {
    return res.status(400).json({
        success: false,
        message: "Valid email is required"
    });
}
 
        const normalizedEmail = email.trim().toLowerCase();

        const existingTeacher = await Teacher.findOne({
            $or: [
                {
                    email: {
                        $regex: `^${normalizedEmail.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}$`,
                        $options: "i"
                    }
                },
                { employeeId }
            ]
        });

        if (existingTeacher) {
            return res.status(400).json({
                success: false,
                message: "Teacher already exists"
            });
        }
        if (await User.findOne({ email: normalizedEmail })) {
            return res.status(409).json({
                success: false,
                message: "An account with this email already exists"
            });
        }
        if (!Array.isArray(departments) || departments.length === 0) {
            return res.status(400).json({
                success: false,
                message: "At least one department is required"
            });
        }
        if (!ownDepartment ||
            departments.some((id) => String(id) !== String(ownDepartment._id))) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }

        const departmentCount =
            await Department.countDocuments({
                _id: { $in: departments }
            });

        if (departmentCount !== departments.length) {
            return res.status(404).json({
                success: false,
                message: "One or more departments not found"
            });
        }

        const tempPassword = crypto.randomBytes(18).toString("base64url");

        const hashedPassword =
            await bcrypt.hash(tempPassword, 10);

        const teacher =
            await Teacher.create({
                teacherName,
                employeeId,
                email: normalizedEmail,
                password: hashedPassword,
                phoneNo,
                departments
            });

        // Also create matching User for login authentication
        await User.create(
            {
                name: teacherName,
                email: normalizedEmail,
                password: hashedPassword,
                role: "TEACHER",
                phone: phoneNo,
                department: creator.department,
            }
        );

        const safeTeacher = teacher.toObject();
        delete safeTeacher.password;
        res.status(201).json({
            success: true,
            message: "Teacher created successfully",
            tempPassword,
            teacher: safeTeacher
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Unable to create teacher"
        });

    }
};

// Get All Teachers
exports.getTeachers = async (req, res) => {
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
        const teachers = await Teacher.find({ departments: department._id })
            .populate("departments")
            .select("-password")
            .sort({ createdAt: -1 })
            .lean();

        const teachersWithSubjects = await Promise.all(
            teachers.map(async (teacher) => {
                const subjects = await Subject.find({
                    teachers: teacher._id,
                    isActive: true
                }).select("subjectName subjectCode");

                return {
                    ...teacher,
                    subjects: subjects.map(subject => ({
                        subjectName: subject.subjectName,
                        subjectCode: subject.subjectCode
                    }))
                };
            })
        );

        res.status(200).json({
            success: true,
            teachers: teachersWithSubjects
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

// Get Single Teacher
exports.getTeacher = async (req, res) => {
    try {

        const teacher =
            await Teacher.findById(req.params.id)
                .populate("departments")
                .select("-password");

        if (!teacher) {
            return res.status(404).json({
                success: false,
                message: "Teacher not found"
            });
        }

        
        res.status(200).json({
            success: true,
            teacher
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Internal server error"
        });

    }
};

// Update Teacher
exports.updateTeacher = async (req, res) => {
    try {
        if (Array.isArray(req.body.departments)) {
            if (req.body.departments.length === 0) {
                return res.status(400).json({
                    success: false,
                    message: "At least one department is required"
                });
            }
            const user = await User.findById(req.user.userId)
                .select("role department");
            const department = user && user.role === "HOD" && user.department
                ? await Department.findOne({ departmentName: user.department }).select("_id")
                : null;
            if (!department ||
                req.body.departments.some((id) => String(id) !== String(department._id))) {
                return res.status(403).json({
                    success: false,
                    message: "Forbidden"
                });
            }
        }

        const teacher =
            await Teacher.findByIdAndUpdate(
                req.params.id,
                {
                    $set: Object.fromEntries(
                        ["teacherName", "employeeId", "email", "phoneNo", "departments"]
                            .filter((field) => Object.hasOwn(req.body, field))
                            .map((field) => [field, req.body[field]])
                    )
                },
                { new: true, runValidators: true }
            )
                .populate("departments")
                .select("-password");

        if (!teacher) {
            return res.status(404).json({
                success: false,
                message: "Teacher not found"
            });
        }

        res.status(200).json({
            success: true,
            message: "Teacher updated successfully",
            teacher
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Internal server error"
        });

    }
};

// Delete Teacher
exports.deleteTeacher = async (req, res) => {
    try {

        const teacher =
            await Teacher.findByIdAndDelete(
                req.params.id
            );

        if (!teacher) {
            return res.status(404).json({
                success: false,
                message: "Teacher not found"
            });
        }

        if (teacher.email) {
            await User.findOneAndDelete({ email: teacher.email.toLowerCase().trim() });
        }

        res.status(200).json({
            success: true,
            message: "Teacher deleted successfully"
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Internal server error"
        });

    }
};