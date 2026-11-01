const Teacher = require("../models/Teacher");
const Department = require("../models/Department");
const User = require("../models/User");
const bcrypt = require("bcryptjs");

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

        const existingTeacher =
            await Teacher.findOne({
                $or: [
                    { email },
                    { employeeId }
                ]
            });

        if (existingTeacher) {
            return res.status(400).json({
                success: false,
                message: "Teacher already exists"
            });
        }

        // Verify departments exist
        if (departments && departments.length > 0) {

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
        }

        const tempPassword =
            `${employeeId}@123`;

        const hashedPassword =
            await bcrypt.hash(tempPassword, 10);

        const teacher =
            await Teacher.create({
                teacherName,
                employeeId,
                email,
                password: hashedPassword,
                phoneNo,
                departments
            });

        // Also create matching User for login authentication
        await User.findOneAndUpdate(
            { email: email.toLowerCase().trim() },
            {
                name: teacherName,
                email: email.toLowerCase().trim(),
                password: hashedPassword,
                role: "TEACHER",
                phone: phoneNo,
                department: "Computer Science",
            },
            { upsert: true, new: true, setDefaultsOnInsert: true }
        );

        res.status(201).json({
            success: true,
            message: "Teacher created successfully",
            tempPassword,
            teacher
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};

// Get All Teachers
exports.getTeachers = async (req, res) => {
    try {

        const teachers =
            await Teacher.find()
                .populate("departments")
                .select("-password")
                .sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            teachers
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
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

        // Keep User in sync
        const userUpdate = {};
        if (req.body.teacherName) userUpdate.name = req.body.teacherName;
        if (req.body.email) userUpdate.email = req.body.email.toLowerCase().trim();
        if (req.body.phoneNo) userUpdate.phone = req.body.phoneNo;
        if (req.body.avatar) userUpdate.avatar = req.body.avatar;

        if (Object.keys(userUpdate).length > 0) {
            await User.findOneAndUpdate(
                { email: teacher.email.toLowerCase().trim() },
                { $set: userUpdate }
            );
        }

        res.status(200).json({
            success: true,
            teacher
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};

// Update Teacher
exports.updateTeacher = async (req, res) => {
    try {

        const teacher =
            await Teacher.findByIdAndUpdate(
                req.params.id,
                req.body,
                { new: true }
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
            message: error.message
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
            message: error.message
        });

    }
};