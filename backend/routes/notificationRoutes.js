const express = require("express");
const { verifyToken, authorizeRoles } = require("../middleware/authMiddleware");
const {
    requireOwnNotification,
    requireOwnNotificationRecipient
} = require("../middleware/ownership");

const router = express.Router();

const {
    createNotification,
    getNotifications,
    markAsRead
} = require(
    "../controllers/notificationController"
);

router.post(
    "/",
    verifyToken,
    authorizeRoles("HOD"),
    createNotification
);

router.get(
    "/:userId",
    verifyToken,
    requireOwnNotificationRecipient("userId"),
    getNotifications
);

router.put(
    "/:id/read",
    verifyToken,
    requireOwnNotification,
    markAsRead
);

module.exports = router;