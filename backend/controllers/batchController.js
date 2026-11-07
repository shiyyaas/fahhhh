const Batch = require("../models/Batch");
const User = require("../models/User");
const { getDepartmentScope } = require("../utils/departmentScope");

exports.createBatch = async (req, res) => {
    try {

        const {
            batchName,
            department,
            startYear,
            endYear
        } = req.body;
        const creator = await User.findById(req.user.userId)
            .select("role department");
        if (!creator || creator.role !== "HOD" ||
            creator.department !== department) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }

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
            message: "Internal server error"
        });

    }
};
exports.getBatches = async (req, res) => {
    try {

        const scope = await getDepartmentScope(req);
        if (!scope) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }
        const filter = scope.batchIds
            ? { _id: { $in: scope.batchIds } }
            : { department: { $in: scope.departmentNames } };
        const batches =
            await Batch.find(filter)
            .sort({ startYear: -1 });

        res.status(200).json({
            success: true,
            batches
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Internal server error"
        });

    }
};
exports.promoteBatch = async (req, res) => {

    try {

        const user = await User.findById(req.user.userId)
            .select("role department");
        const batch = await Batch.findById(
            req.params.id
        );

        if (!batch) {
            return res.status(404).json({
                success: false,
                message: "Batch not found"
            });
        }
        if (!user || user.role !== "HOD" ||
            !user.department || batch.department !== user.department) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
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
            message: "Internal server error"
        });

    }
};