const express = require("express");

const router = express.Router();

const {
    markAttendance,
    getStudentAttendance,
    getBatchAttendance,
    getSubjectAttendance,
    getAttendancePercentage,
    getDefaulters
} = require("../controllers/attendanceController");

 
router.post("/mark", markAttendance); 
router.get("/student/:id", getStudentAttendance); 
router.get("/batch/:id", getBatchAttendance); 
router.get("/subject/:id", getSubjectAttendance ); 
router.get("/percentage/:studentId", getAttendancePercentage);
router.get("/defaulters", getDefaulters);

module.exports = router;