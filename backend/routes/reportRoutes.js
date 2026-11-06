const express = require("express");

const router = express.Router();

const {
    getStudentReport,
    getBatchReport,
    getSubjectReport,
    downloadStudentReport,
    downloadMonthlyBatchReport,
    previewMonthlyBatchReport
} = require("../controllers/reportController");
const { verifyToken, authorizeRoles } = require("../middleware/authMiddleware");
const { requireStudentOrHod, requireHodDepartmentResource } = require("../middleware/ownership");
const Batch = require("../models/Batch");
const Subject = require("../models/Subject");

router.get("/student/:studentId", verifyToken, authorizeRoles("HOD", "STUDENT"), requireStudentOrHod("studentId"), getStudentReport);
router.get("/batch/:batchId", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Batch, "batchId", "batch"), getBatchReport);
router.get("/subject/:subjectId", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Subject, "subjectId", "subject"), getSubjectReport);
router.get("/student/:studentId/pdf", verifyToken, authorizeRoles("HOD", "STUDENT"), requireStudentOrHod("studentId"), downloadStudentReport);
router.get("/batch/:batchId/monthly-pdf", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Batch, "batchId", "batch"), downloadMonthlyBatchReport);
router.get("/batch/:batchId/monthly-preview", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Batch, "batchId", "batch"), previewMonthlyBatchReport);

module.exports = router;