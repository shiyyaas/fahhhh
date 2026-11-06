
const express = require("express");
const router = express.Router();
const { verifyToken, authorizeRoles } = require("../middleware/authMiddleware");
const {
    requireOwnStudentBatchOrHod,
    requireTeacherOrHod
} = require("../middleware/ownership");

const {
    createTimetable,
    getTimetable,
    getBatchTimetable,
    getTeacherTimetable,
    updateTimetable,
    deleteTimetable
} = require("../controllers/timetableController");

router.post("/", verifyToken, authorizeRoles("HOD"), createTimetable);
router.get("/", verifyToken, authorizeRoles("HOD"), getTimetable);
router.get("/batch/:id", verifyToken, authorizeRoles("HOD", "STUDENT"), requireOwnStudentBatchOrHod("id"), getBatchTimetable);
router.get("/teacher/:id", verifyToken, authorizeRoles("HOD", "TEACHER"), requireTeacherOrHod("id"), getTeacherTimetable);
router.patch("/:id", verifyToken, authorizeRoles("HOD"), updateTimetable);
router.delete("/:id", verifyToken, authorizeRoles("HOD"), deleteTimetable);

module.exports = router;
