// Attendance Routes with authentication and role checks
const express = require("express");
const router = express.Router();

const {
  markAttendance,
  getStudentAttendance,
  getBatchAttendance,
  getSubjectAttendance,
  getAttendancePercentage,
  getDefaulters,
  updateAttendance,
  deleteAttendance,
  getStudentReport
} = require("../controllers/attendanceController");

const { verifyToken, authorizeRoles } = require("../middleware/authMiddleware");

// Teacher routes for managing attendance
router.post("/mark", verifyToken, authorizeRoles("TEACHER"), markAttendance);
router.put("/update/:id", verifyToken, authorizeRoles("TEACHER"), updateAttendance);
router.delete("/delete/:id", verifyToken, authorizeRoles("TEACHER"), deleteAttendance);

// Reporting routes (admin/HOD/teacher/student where appropriate)
router.get("/student/:id", verifyToken, authorizeRoles("ADMIN", "HOD", "STUDENT"), getStudentAttendance);
router.get("/batch/:id", verifyToken, authorizeRoles("ADMIN", "HOD"), getBatchAttendance);
router.get("/subject/:id", verifyToken, authorizeRoles("ADMIN", "HOD", "TEACHER"), getSubjectAttendance);
router.get("/percentage/:studentId", verifyToken, authorizeRoles("ADMIN", "HOD", "STUDENT"), getAttendancePercentage);
router.get("/defaulters", verifyToken, authorizeRoles("ADMIN", "HOD"), getDefaulters);
router.get("/report/student/:id", verifyToken, authorizeRoles("ADMIN", "HOD", "STUDENT"), getStudentReport);

module.exports = router;
