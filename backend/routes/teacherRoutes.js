const express = require("express");

const router = express.Router();

const {
    createTeacher,
    getTeachers,
    getTeacher,
    updateTeacher,
    deleteTeacher
} = require("../controllers/teacherController");

router.post("/", createTeacher);

router.get("/", getTeachers);

router.get("/:id", getTeacher);

router.put("/:id", updateTeacher);

router.delete("/:id", deleteTeacher);

module.exports = router;