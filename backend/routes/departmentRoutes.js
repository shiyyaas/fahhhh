const express = require("express");

const router = express.Router();
const { verifyToken, authorizeRoles } = require("../middleware/authMiddleware");
const { requireHodDepartmentResource } = require("../middleware/ownership");
const Department = require("../models/Department");

const {
    createDepartment,
    getDepartments,
    getDepartment,
    updateDepartment,
    deleteDepartment
} = require("../controllers/departmentController");

router.post("/", verifyToken, authorizeRoles("HOD"), createDepartment);

router.get("/", verifyToken, authorizeRoles("HOD", "TEACHER", "STUDENT"), getDepartments);

router.get("/:id", verifyToken, authorizeRoles("HOD", "TEACHER", "STUDENT"), getDepartment);

router.put("/:id", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Department, "id", "department"), updateDepartment);

router.delete("/:id", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Department, "id", "department"), deleteDepartment);

module.exports = router;