const express = require("express");

const router = express.Router();

const {
    applyLeave,
    getLeaves,
    recommendLeave,
    approveLeave,
    rejectLeave
} = require("../controllers/leaveController");

router.post("/", applyLeave);

router.get("/", getLeaves);

router.put(
    "/:id/recommend",
    recommendLeave
);

router.put(
    "/:id/approve",
    approveLeave
);

router.put(
    "/:id/reject",
    rejectLeave
);

module.exports = router;