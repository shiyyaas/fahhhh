const Subject = require("../models/Subject");

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
            message: error.message
        });

    }
};

// Get All Subjects
exports.getSubjects = async (req, res) => {
    try {

        const subjects =
            await Subject.find()
                .populate("departments")
                .populate("teachers")
                .sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            subjects
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};

// Get Single Subject
exports.getSubject = async (req, res) => {
    try {

        const subject =
            await Subject.findById(req.params.id)
                .populate("departments")
                .populate("teachers");

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
            message: error.message
        });

    }
};

// Update Subject
exports.updateSubject = async (req, res) => {
    try {

        const subject =
            await Subject.findByIdAndUpdate(
                req.params.id,
                req.body,
                { new: true }
            )
                .populate("departments")
                .populate("teachers");

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
            message: error.message
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
            message: error.message
        });

    }
};