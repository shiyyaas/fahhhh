const Department = require("../models/Department");
const User = require("../models/User");

// Create Department
exports.createDepartment = async (req, res) => {
    try {

        const {
            departmentName,
            departmentCode,
            hodName
        } = req.body;
        const creator = await User.findById(req.user.userId)
            .select("role department");
        if (!creator || creator.role !== "HOD" ||
            creator.department !== departmentName) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }

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
            message: "Internal server error"
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
            message: "Internal server error"
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
            message: "Internal server error"
        });

    }
};

// Update Department
exports.updateDepartment = async (req, res) => {
    try {

        const user = await User.findById(req.user.userId)
            .select("role department");
        if (!user || user.role !== "HOD" ||
            (req.body.departmentName &&
                req.body.departmentName !== user.department)) {
            return res.status(403).json({
                success: false,
                message: "Department name cannot be changed by this account"
            });
        }

        const department =
            await Department.findByIdAndUpdate(
                req.params.id,
                {
                    $set: Object.fromEntries(
                        ["departmentName", "departmentCode", "hodName"]
                            .filter((field) => Object.hasOwn(req.body, field))
                            .map((field) => [field, req.body[field]])
                    )
                },
                { new: true, runValidators: true }
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
            message: "Internal server error"
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
            message: "Internal server error"
        });

    }
};