const express = require("express");

const router = express.Router();

const {
    getHodDashboard,
    getTeacherDashboard,
    getStudentDashboard
} = require(
    "../controllers/dashboardController"
);
const { verifyToken, authorizeRoles } = require("../middleware/authMiddleware");
const {
    requireStudentOrHod,
    requireTeacherOrHod
} = require("../middleware/ownership");

router.get("/hod", verifyToken, authorizeRoles("HOD"), getHodDashboard);
router.get("/teacher/:teacherId", verifyToken, authorizeRoles("HOD", "TEACHER"), requireTeacherOrHod("teacherId"), getTeacherDashboard);
router.get("/student/:studentId", verifyToken, authorizeRoles("HOD", "STUDENT"), requireStudentOrHod("studentId"), getStudentDashboard);

module.exports = router;