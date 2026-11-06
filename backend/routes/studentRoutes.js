const express = require("express");

const router = express.Router();

const {
    verifyToken,
    authorizeRoles
} = require("../middleware/authMiddleware");

const {
    createStudent,
    getStudents,
    getStudent,
    updateStudent,
    deleteStudent
} = require("../controllers/studentController");
const { requireStudentOrHod } = require("../middleware/ownership");

// HOD Only

router.post("/",verifyToken, authorizeRoles("HOD"), createStudent);

router.get( "/", verifyToken, authorizeRoles("HOD"), getStudents);

router.get( "/:id", verifyToken, authorizeRoles("HOD", "STUDENT"), requireStudentOrHod("id"), getStudent );

router.put( "/:id", verifyToken, authorizeRoles("HOD"), requireStudentOrHod("id"), updateStudent);
router.delete( "/:id", verifyToken, authorizeRoles("HOD"), requireStudentOrHod("id"), deleteStudent);

module.exports = router;