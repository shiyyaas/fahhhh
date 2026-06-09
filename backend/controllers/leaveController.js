const Leave = require("../models/Leave");
const Notification = require("../models/Notification");
// Apply Leave

exports.applyLeave = async (req, res) => {

    try {

        const leave =
            await Leave.create(req.body);

        res.status(201).json({
            success: true,
            message: "Leave applied successfully",
            leave
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

// Get All Leaves

exports.getLeaves = async (req, res) => {

    try {

        const leaves =
            await Leave.find()
            .sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            leaves
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

// Teacher Recommendation

exports.recommendLeave = async (req, res) => {

    try {

        const leave =
            await Leave.findById(
                req.params.id
            );

        if (!leave) {

            return res.status(404).json({
                success: false,
                message: "Leave not found"
            });

        }

        leave.teacherApproval = true;
        leave.status = "PENDING_HOD";

        await leave.save();

        res.status(200).json({
            success: true,
            message:
                "Leave recommended to HOD",
            leave
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

// HOD Approval

exports.approveLeave = async (req, res) => {

    try {

        const leave =
            await Leave.findById(
                req.params.id
            );

        if (!leave) {

            return res.status(404).json({
                success: false,
                message: "Leave not found"
            });

        }

        leave.hodApproval = true;
        leave.status = "APPROVED";

        await leave.save();

        

        await Notification.create({

            recipientId:
                leave.applicantId,

            recipientRole:
                leave.applicantType,

            title:
                "Leave Approved",

            message:
                "Your leave request has been approved by HOD."

        });

        res.status(200).json({
            success: true,
            message:
                "Leave approved",
            leave
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};
// Reject Leave

exports.rejectLeave = async (req, res) => {

    try {

        const leave =
            await Leave.findById(
                req.params.id
            );

        if (!leave) {

            return res.status(404).json({
                success: false,
                message: "Leave not found"
            });

        }

        leave.status = "REJECTED";

        await leave.save();

        res.status(200).json({
            success: true,
            message:
                "Leave rejected",
            leave
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};