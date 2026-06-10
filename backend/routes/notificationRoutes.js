const express = require("express");

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
    createNotification
);

router.get(
    "/:userId",
    getNotifications
);

router.put(
    "/:id/read",
    markAsRead
);

module.exports = router;