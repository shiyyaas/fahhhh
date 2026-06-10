const Batch = require("../models/Batch");

exports.createBatch = async (req, res) => {
    try {

        const {
            batchName,
            department,
            startYear,
            endYear
        } = req.body;

        const existingBatch =
            await Batch.findOne({ batchName });

        if (existingBatch) {
            return res.status(400).json({
                success: false,
                message: "Batch already exists"
            });
        }

        const batch = await Batch.create({
            batchName,
            department,
            startYear,
            endYear
        });

        res.status(201).json({
            success: true,
            batch
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};
exports.getBatches = async (req, res) => {
    try {

        const batches =
            await Batch.find()
            .sort({ startYear: -1 });

        res.status(200).json({
            success: true,
            batches
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};
exports.promoteBatch = async (req, res) => {

    try {

        const batch = await Batch.findById(
            req.params.id
        );

        if (!batch) {
            return res.status(404).json({
                success: false,
                message: "Batch not found"
            });
        }

        if (batch.currentSemester >= 6) {
            return res.status(400).json({
                success: false,
                message: "Batch already completed"
            });
        }

        batch.currentSemester += 1;

        await batch.save();

        res.status(200).json({
            success: true,
            message: "Semester promoted",
            batch
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};