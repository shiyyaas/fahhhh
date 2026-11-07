const express = require("express");

const router = express.Router();
const { verifyToken, authorizeRoles } = require("../middleware/authMiddleware");
const { requireTeacherOrHod } = require("../middleware/ownership");

const {
    createTeacher,
    getTeachers,
    getTeacher,
    updateTeacher,
    deleteTeacher
} = require("../controllers/teacherController");

router.post("/", verifyToken, authorizeRoles("HOD"), createTeacher);

router.get("/", verifyToken, authorizeRoles("HOD"), getTeachers);

router.get("/:id", verifyToken, authorizeRoles("HOD"), requireTeacherOrHod("id"), getTeacher);

router.put("/:id", verifyToken, authorizeRoles("HOD"), requireTeacherOrHod("id"), updateTeacher);

router.delete("/:id", verifyToken, authorizeRoles("HOD"), requireTeacherOrHod("id"), deleteTeacher);

module.exports = router;