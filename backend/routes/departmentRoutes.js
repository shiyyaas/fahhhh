const express = require("express");

const router = express.Router();

const {
    createDepartment,
    getDepartments,
    getDepartment,
    updateDepartment,
    deleteDepartment
} = require("../controllers/departmentController");

router.post("/", createDepartment);

router.get("/", getDepartments);

router.get("/:id", getDepartment);

router.put("/:id", updateDepartment);

router.delete("/:id", deleteDepartment);

module.exports = router;