const express = require("express");
const { verifyToken, authorizeRoles } = require("../middleware/authMiddleware");
const { requireHodLeaveDepartment } = require("../middleware/ownership");

const router = express.Router();

const {
    applyLeave,
    getLeaves,
    recommendLeave,
    approveLeave,
    rejectLeave
} = require("../controllers/leaveController");

router.post("/", verifyToken, authorizeRoles("STUDENT", "TEACHER"), applyLeave);

router.get("/", verifyToken, authorizeRoles("HOD", "STUDENT", "TEACHER"), getLeaves);

router.put(
    "/:id/recommend",
    verifyToken,
    authorizeRoles("HOD"),
    requireHodLeaveDepartment,
    recommendLeave
);

router.put(
    "/:id/approve",
    verifyToken,
    authorizeRoles("HOD"),
    requireHodLeaveDepartment,
    approveLeave
);

router.put(
    "/:id/reject",
    verifyToken,
    authorizeRoles("HOD"),
    requireHodLeaveDepartment,
    rejectLeave
);

module.exports = router;