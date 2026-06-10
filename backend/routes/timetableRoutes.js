const express = require("express");

const router = express.Router();

const {
    createTimetable,
    getTimetable,
    getBatchTimetable,
    getTeacherTimetable,
    deleteTimetable
} = require("../controllers/timetableController");

router.post(
    "/",
    createTimetable
);

router.get(
    "/",
    getTimetable
);

router.get(
    "/batch/:id",
    getBatchTimetable
);

router.get(
    "/teacher/:id",
    getTeacherTimetable
);

router.delete(
    "/:id",
    deleteTimetable
);

module.exports = router;