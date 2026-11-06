const express = require("express");

const router = express.Router();
const { verifyToken, authorizeRoles } = require("../middleware/authMiddleware");
const { requireHodDepartmentResource } = require("../middleware/ownership");
const Batch = require("../models/Batch");

const {
    createBatch,
    getBatches,
    promoteBatch
} = require("../controllers/batchController");

router.post("/", verifyToken, authorizeRoles("HOD"), createBatch);

router.get("/", verifyToken, authorizeRoles("HOD", "TEACHER", "STUDENT"), getBatches);

router.put("/:id/promote", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Batch, "id", "batch"), promoteBatch);

module.exports = router;