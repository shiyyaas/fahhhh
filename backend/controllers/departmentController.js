const Department = require("../models/Department");

// Create Department
exports.createDepartment = async (req, res) => {
    try {

        const {
            departmentName,
            departmentCode,
            hodName
        } = req.body;

        const existingDepartment =
            await Department.findOne({
                $or: [
                    { departmentName },
                    { departmentCode }
                ]
            });

        if (existingDepartment) {
            return res.status(400).json({
                success: false,
                message: "Department already exists"
            });
        }

        const department =
            await Department.create({
                departmentName,
                departmentCode,
                hodName
            });

        res.status(201).json({
            success: true,
            message: "Department created successfully",
            department
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};

// Get All Departments
exports.getDepartments = async (req, res) => {
    try {

        const departments =
            await Department.find()
            .sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            departments
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};

// Get Single Department
exports.getDepartment = async (req, res) => {
    try {

        const department =
            await Department.findById(
                req.params.id
            );

        if (!department) {
            return res.status(404).json({
                success: false,
                message: "Department not found"
            });
        }

        res.status(200).json({
            success: true,
            department
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};

// Update Department
exports.updateDepartment = async (req, res) => {
    try {

        const department =
            await Department.findByIdAndUpdate(
                req.params.id,
                req.body,
                { new: true }
            );

        if (!department) {
            return res.status(404).json({
                success: false,
                message: "Department not found"
            });
        }

        res.status(200).json({
            success: true,
            message: "Department updated successfully",
            department
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};

// Delete Department
exports.deleteDepartment = async (req, res) => {
    try {

        const department =
            await Department.findByIdAndDelete(
                req.params.id
            );

        if (!department) {
            return res.status(404).json({
                success: false,
                message: "Department not found"
            });
        }

        res.status(200).json({
            success: true,
            message: "Department deleted successfully"
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }
};