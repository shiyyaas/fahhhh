
const express = require("express");
const router = express.Router();

const {
    createTimetable,
    getTimetable,
    getBatchTimetable,
    getTeacherTimetable,
    updateTimetable,
    deleteTimetable
} = require("../controllers/timetableController");

router.post("/", createTimetable);
router.get("/", getTimetable);
router.get("/batch/:id", getBatchTimetable);
router.get("/teacher/:id", getTeacherTimetable);
router.patch("/:id", updateTimetable);
router.delete("/:id", deleteTimetable);

module.exports = router;
