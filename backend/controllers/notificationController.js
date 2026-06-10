const Notification =
require("../models/Notification");

// Create Notification

exports.createNotification =
async (req, res) => {

    try {

        const notification =
            await Notification.create(
                req.body
            );

        res.status(201).json({
            success: true,
            notification
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
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
            message: error.message
        });

    }

};

// Mark Read

exports.markAsRead =
async (req, res) => {

    try {

        const notification =
            await Notification.findByIdAndUpdate(
                req.params.id,
                {
                    isRead: true
                },
                {
                    new: true
                }
            );

        res.status(200).json({
            success: true,
            notification
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};