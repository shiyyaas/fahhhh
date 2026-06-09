const express = require("express");

const router = express.Router();

const {
    createSubject,
    getSubjects,
    getSubject,
    updateSubject,
    deleteSubject
} = require("../controllers/subjectController");

router.post("/", createSubject);

router.get("/", getSubjects);

router.get("/:id", getSubject);

router.put("/:id", updateSubject);

router.delete("/:id", deleteSubject);

module.exports = router;