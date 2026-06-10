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

// HOD Only

router.post("/",verifyToken, authorizeRoles("HOD"), createStudent);

router.get( "/", verifyToken, authorizeRoles("HOD","TEACHER"), getStudents);

router.get( "/:id", verifyToken, getStudent );

router.put( "/:id", verifyToken, authorizeRoles("HOD"), updateStudent);

router.delete( "/:id", verifyToken, authorizeRoles("HOD"),deleteStudent);

module.exports = router;