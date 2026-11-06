const Student = require("../models/Student");
const bcrypt = require("bcryptjs");
const Batch = require("../models/Batch");
const User = require("../models/User");
const crypto = require("crypto");

exports.createStudent = async (req, res) => {

    try {

        const {
            studentName,
            registerNo,
            email,
            phoneNo,
            apaarId,
            batchId
        } = req.body;
        if (!email || typeof email !== "string" ||
            !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) {
            return res.status(400).json({
                success: false,
                message: "Valid email is required"
            });
        }
        const normalizedEmail = email.trim().toLowerCase();
        const existingStudent =
            await Student.findOne({
                $or: [
                    { email: normalizedEmail },
                    { registerNo }
                ]
            });

        if (existingStudent) {
            return res.status(400).json({
                success: false,
                message: "Student already exists"
            });
        }
        if (await User.findOne({ email: normalizedEmail })) {
            return res.status(409).json({
                success: false,
                message: "An account with this email already exists"
            });
        }
        const batch = await Batch.findById(batchId);

        if (!batch) {
            return res.status(404).json({
                success: false,
                message: "Batch not found"
            });
        }
        const creator = await User.findById(req.user.userId).select("role department");
        if (!creator || creator.role !== "HOD" ||
            !creator.department || batch.department !== creator.department) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }
        const tempPassword = crypto.randomBytes(18).toString("base64url");

        const hashedPassword =
            await bcrypt.hash(tempPassword, 10);

        const student =
            await Student.create({
                studentName,
                registerNo,
                email: normalizedEmail,
                password: hashedPassword,
                phoneNo,
                apaarId,
                batchId,
                department: batch.department
            });

        // Also create matching User for login authentication
        await User.create({
                name: studentName,
                email: email.toLowerCase().trim(),
                password: hashedPassword,
                role: "STUDENT",
                phone: phoneNo,
                department: batch.department || "Computer Science",
            });

        const safeStudent = student.toObject();
        delete safeStudent.password;
        delete safeStudent.aadhaarEncrypted;
        delete safeStudent.apaarId;
        res.status(201).json({
            success: true,
            message: "Student created successfully",
            tempPassword,
            student: safeStudent
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Internal server error"
        });

    }

};

exports.getStudents = async (req, res) => {
    try {

        const user = await User.findById(req.user.userId).select("role department");
        if (!user || user.role !== "HOD" || !user.department) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }
        const students = await Student.find({ department: user.department })
            .populate("batchId")
            .select("-password -aadhaarEncrypted -apaarId")
            .sort({ createdAt: -1 }   
        );

        res.status(200).json({
            success: true,
            students
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Internal server error"
        });

    }
};
exports.getStudent = async (req, res) => {

    try {

        const student = await Student.findById(req.params.id)
            .populate("batchId")
            .select("-password -aadhaarEncrypted -apaarId");

        if (!student) {
            return res.status(404).json({
                success: false,
                message: "Student not found"
            });
        }

        res.status(200).json({
            success: true,
            student
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Internal server error"
        });

    }

};

exports.updateStudent = async (req, res) => {

    try {

        const allowedFields = [
            "studentName",
            "registerNo",
            "email",
            "phoneNo",
            "batchId"
        ];
        const updates = Object.fromEntries(
            allowedFields
                .filter((field) => Object.hasOwn(req.body, field))
                .map((field) => [field, req.body[field]])
        );
        if (Object.hasOwn(updates, "email")) {
            if (typeof updates.email !== "string" ||
                !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(updates.email.trim())) {
                return res.status(400).json({
                    success: false,
                    message: "Valid email is required"
                });
            }
            updates.email = updates.email.trim().toLowerCase();
        }
        const currentStudent = await Student.findById(req.params.id);
        if (!currentStudent) {
            return res.status(404).json({
                success: false,
                message: "Student not found"
            });
        }
        const previousEmail = currentStudent.email;
        if (updates.batchId) {
            const user = await User.findById(req.user.userId).select("role department");
            const newBatch = await Batch.findById(updates.batchId).select("department");
            if (!newBatch) {
                return res.status(404).json({
                    success: false,
                    message: "Batch not found"
                });
            }
            if (!user || user.role !== "HOD" ||
                newBatch.department !== user.department) {
                return res.status(403).json({
                    success: false,
                    message: "Forbidden"
                });
            }
            updates.department = newBatch.department;
        }
        const student =
            await Student.findByIdAndUpdate(
                req.params.id,
                { $set: updates },
                { new: true, runValidators: true }
            );

        if (!student) {
            return res.status(404).json({
                success: false,
                message: "Student not found"
            });
        }

        // Keep User in sync
        const userUpdate = {};
        if (req.body.studentName) userUpdate.name = req.body.studentName;
        if (updates.email) userUpdate.email = updates.email.toLowerCase().trim();
        if (updates.phoneNo) userUpdate.phone = updates.phoneNo;

        if (Object.keys(userUpdate).length > 0) {
            await User.findOneAndUpdate(
                { email: previousEmail.toLowerCase().trim() },
                { $set: userUpdate }
            );
        }

        const safeStudent = student.toObject();
        delete safeStudent.password;
        delete safeStudent.aadhaarEncrypted;
        delete safeStudent.apaarId;
        res.status(200).json({
            success: true,
            student: safeStudent
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Internal server error"
        });

    }

};

exports.deleteStudent = async (req, res) => {

    try {

        const student = await Student.findByIdAndDelete(
            req.params.id
        );

        if (student && student.email) {
            await User.findOneAndDelete({ email: student.email.toLowerCase().trim() });
        }

        res.status(200).json({
            success: true,
            message: "Student deleted"
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Internal server error"
        });

    }

};