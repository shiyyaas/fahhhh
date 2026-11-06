const Leave = require("../models/Leave");
const Notification = require("../models/Notification");
const Department = require("../models/Department");
const User = require("../models/User");
const Student = require("../models/Student");
const Teacher = require("../models/Teacher");
// Apply Leave

exports.applyLeave = async (req, res) => {

    try {

        const { reason, fromDate, toDate } = req.body;
        const start = new Date(fromDate);
        const end = new Date(toDate);
        if (!reason || !Number.isFinite(start.getTime()) ||
            !Number.isFinite(end.getTime()) || start > end) {
            return res.status(400).json({
                success: false,
                message: "Valid reason, fromDate, and toDate are required"
            });
        }

        const user = await User.findById(req.user.userId).select("email role");
        const Profile = req.user.role === "STUDENT" ? Student : Teacher;
        const profile = user && user.role === req.user.role
            ? await Profile.findOne({ email: user.email }).select("_id")
            : null;
        if (!profile) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }
        const leave =
            await Leave.create({
                applicantId: profile._id,
                applicantType: req.user.role,
                reason,
                fromDate: start,
                toDate: end
            });

        res.status(201).json({
            success: true,
            message: "Leave applied successfully",
            leave
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Unable to apply for leave"
        });

    }

};

// Get All Leaves

exports.getLeaves = async (req, res) => {

    try {

        let filter = {};
        const user = await User.findById(req.user.userId)
            .select("email role department");
        if (!user || user.role !== req.user.role) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }
        if (req.user.role === "HOD") {
            const department = await Department.findOne({
                departmentName: user.department
            }).select("_id");
            if (!department) {
                return res.status(403).json({
                    success: false,
                    message: "Forbidden"
                });
            }
            const [studentIds, teacherIds] = await Promise.all([
                Student.find({ department: user.department }).distinct("_id"),
                Teacher.find({ departments: department._id }).distinct("_id")
            ]);
            filter = {
                $or: [
                    { applicantType: "STUDENT", applicantId: { $in: studentIds } },
                    { applicantType: "TEACHER", applicantId: { $in: teacherIds } }
                ]
            };
        } else {
            const Profile = req.user.role === "STUDENT" ? Student : Teacher;
            const profile = user
                ? await Profile.findOne({ email: user.email }).select("_id")
                : null;
            if (!profile) {
                return res.status(403).json({
                    success: false,
                    message: "Forbidden"
                });
            }
            filter = { applicantId: profile._id };
        }
        const leaves =
            await Leave.find(filter)
            .sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            leaves
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Unable to retrieve leave requests"
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
            message: "Internal server error"
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
            message: "Internal server error"
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
            message: "Internal server error"
        });

    }

};