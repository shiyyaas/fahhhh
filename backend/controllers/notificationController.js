const Notification =
require("../models/Notification");
const User = require("../models/User");
const Student = require("../models/Student");
const Teacher = require("../models/Teacher");
const Department = require("../models/Department");

// Create Notification

exports.createNotification =
async (req, res) => {

    try {

        const {
            recipientId,
            recipientRole,
            title,
            message
        } = req.body;
        if (!["STUDENT", "TEACHER"].includes(recipientRole)) {
            return res.status(400).json({
                success: false,
                message: "Invalid recipient role"
            });
        }
        const sender = await User.findById(req.user.userId)
            .select("role department");
        const department = sender && sender.role === "HOD"
            ? await Department.findOne({
                departmentName: sender.department
            }).select("_id")
            : null;
        const Recipient = recipientRole === "STUDENT" ? Student : Teacher;
        const recipientFilter = recipientRole === "STUDENT"
            ? { _id: recipientId, department: sender && sender.department }
            : { _id: recipientId, departments: department && department._id };
        const recipient = department
            ? await Recipient.findOne(recipientFilter).select("_id")
            : null;
        if (!recipient) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }
        const notification =
            await Notification.create(
                { recipientId, recipientRole, title, message }
            );

        res.status(201).json({
            success: true,
            notification
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Unable to create notification"
        });

    }

};

// Get User Notifications

exports.getNotifications =
async (req, res) => {

    try {

        const notifications =
            await Notification.find({
                recipientId:
                    req.params.userId
            })
            .sort({
                createdAt: -1
            });

        res.status(200).json({
            success: true,
            notifications
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Unable to retrieve notifications"
        });

    }

};

// Mark Read

exports.markAsRead =
async (req, res) => {

    try {

        const notification =
            await Notification.findOneAndUpdate(
                {
                    _id: req.params.id,
                    recipientId: { $in: req.notificationRecipientIds }
                },
                {
                    isRead: true
                },
                {
                    new: true
                }
            );

        if (!notification) {
            return res.status(404).json({
                success: false,
                message: "Notification not found"
            });
        }
        res.status(200).json({
            success: true,
            notification
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: "Unable to update notification"
        });

    }

};