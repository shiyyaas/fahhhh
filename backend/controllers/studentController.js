const Student = require("../models/Student");
const bcrypt = require("bcryptjs");

exports.createStudent = async (req, res) => {

    try {

        const {
            studentName,
            registerNo,
            email,
            phoneNo,
            apaarId,
            aadhaarNo,
            batchId
        } = req.body;
        const existingStudent =
            await Student.findOne({
                $or: [
                    { email },
                    { registerNo }
                ]
            });

        if (existingStudent) {
            return res.status(400).json({
                success: false,
                message: "Student already exists"
            });
        }

        // Temporary password = last 5 digits of Aadhaar

        const tempPassword =
            aadhaarNo.slice(-5);

        const hashedPassword =
            await bcrypt.hash(tempPassword, 10);

        const student =
            await Student.create({
                studentName,
                registerNo,
                email,
                password: hashedPassword,
                phoneNo,
                apaarId,
                aadhaarEncrypted: aadhaarNo,
                batchId
            });

        res.status(201).json({
            success: true,
            message: "Student created successfully",
            tempPassword,
            student
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

exports.getStudents = async (req, res) => {
    try {

        const students = await Student.find()
            .populate("batchId")
            .select("-password -aadhaarEncrypted")
            .sort({ createdAt: -1 }   
        );

        res.status(200).json({
            success: true,
            students
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};
exports.getStudent = async (req, res) => {

    try {

        const student = await Student.findById(req.params.id)
            .populate("batchId")
            .select("-password -aadhaarEncrypted");

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
            message: error.message
        });

    }

};

exports.updateStudent = async (req, res) => {

    try {

        const student =
            await Student.findByIdAndUpdate(
                req.params.id,
                req.body,
                { new: true }
            );

        res.status(200).json({
            success: true,
            student
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

exports.deleteStudent = async (req, res) => {

    try {

        await Student.findByIdAndDelete(
            req.params.id
        );

        res.status(200).json({
            success: true,
            message: "Student deleted"
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};