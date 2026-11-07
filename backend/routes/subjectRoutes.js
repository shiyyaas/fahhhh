const express = require("express");

const router = express.Router();
const { verifyToken, authorizeRoles } = require("../middleware/authMiddleware");
const { requireHodDepartmentResource } = require("../middleware/ownership");
const Subject = require("../models/Subject");

const {
    createSubject,
    getSubjects,
    getSubject,
    updateSubject,
    deleteSubject
} = require("../controllers/subjectController");

router.post("/", verifyToken, authorizeRoles("HOD"), createSubject);

router.get("/", verifyToken, authorizeRoles("HOD", "TEACHER", "STUDENT"), getSubjects);

router.get("/:id", verifyToken, authorizeRoles("HOD", "TEACHER", "STUDENT"), getSubject);

router.put("/:id", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Subject, "id", "subject"), updateSubject);

router.delete("/:id", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Subject, "id", "subject"), deleteSubject);

module.exports = router;