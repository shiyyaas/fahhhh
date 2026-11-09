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
const {
  downloadStudentReport,
  downloadStudentSubjectReport,
  downloadDefaultersReport
} = require("../controllers/reportController");

const { verifyToken, authorizeRoles } = require("../middleware/authMiddleware");
const {
  requireHodDepartmentResource,
  requireStudentOrHod
} = require("../middleware/ownership");
const Batch = require("../models/Batch");
const Subject = require("../models/Subject");

const requireHodSubjectScope = (req, res, next) => {
  if (req.user.role !== "HOD") return next();
  return requireHodDepartmentResource(Subject, "id", "subject")(req, res, next);
};

// Teacher routes for managing attendance
router.post("/mark", verifyToken, authorizeRoles("TEACHER"), markAttendance);
router.put("/update/:id", verifyToken, authorizeRoles("TEACHER"), updateAttendance);
router.delete("/delete/:id", verifyToken, authorizeRoles("TEACHER"), deleteAttendance);

// Reporting routes (admin/HOD/teacher/student where appropriate)
router.get("/student/:id", verifyToken, authorizeRoles("HOD", "STUDENT"), requireStudentOrHod("id"), getStudentAttendance);
router.get("/batch/:id", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Batch, "id", "batch"), getBatchAttendance);
router.get("/subject/:id", verifyToken, authorizeRoles("HOD", "TEACHER"), requireHodSubjectScope, getSubjectAttendance);
router.get("/percentage/:studentId", verifyToken, authorizeRoles("HOD", "STUDENT"), requireStudentOrHod("studentId"), getAttendancePercentage);
router.get("/defaulters", verifyToken, authorizeRoles("HOD"), getDefaulters);
router.get("/defaulters/pdf", verifyToken, authorizeRoles("HOD"), downloadDefaultersReport);
router.get("/report/student/:id", verifyToken, authorizeRoles("HOD", "STUDENT"), requireStudentOrHod("id"), getStudentReport);
router.get("/report/student/:id/pdf", verifyToken, authorizeRoles("HOD", "STUDENT"), requireStudentOrHod("id"), downloadStudentReport);
router.get("/report/student/:id/subject-wise-pdf", verifyToken, authorizeRoles("HOD", "STUDENT"), requireStudentOrHod("id"), downloadStudentSubjectReport);

module.exports = router;
