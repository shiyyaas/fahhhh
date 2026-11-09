const express = require("express");

const router = express.Router();

const {
    getStudentReport,
    getBatchReport,
    getSubjectReport,
    downloadStudentReport,
    downloadStudentSubjectReport,
    downloadSubjectReport,
    downloadFullBatchReport,
    downloadMonthlyBatchReport,
    previewMonthlyBatchReport,
    downloadDepartmentReport,
    downloadDefaultersReport,
    downloadBatchDefaultersReport
} = require("../controllers/reportController");
const { verifyToken, authorizeRoles } = require("../middleware/authMiddleware");
const { requireStudentOrHod, requireHodDepartmentResource } = require("../middleware/ownership");
const Batch = require("../models/Batch");
const Subject = require("../models/Subject");
const Department = require("../models/Department");

// JSON report endpoints
router.get("/student/:studentId", verifyToken, authorizeRoles("HOD", "STUDENT"), requireStudentOrHod("studentId"), getStudentReport);
router.get("/batch/:batchId", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Batch, "batchId", "batch"), getBatchReport);
router.get("/subject/:subjectId", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Subject, "subjectId", "subject"), getSubjectReport);

// 1. Student overall attendance PDF
router.get("/student/:studentId/pdf", verifyToken, authorizeRoles("HOD", "STUDENT"), requireStudentOrHod("studentId"), downloadStudentReport);
router.get("/student/:studentId/overall-pdf", verifyToken, authorizeRoles("HOD", "STUDENT"), requireStudentOrHod("studentId"), downloadStudentReport);

// 2. Student subject-wise attendance PDF
router.get("/student/:studentId/subject-wise-pdf", verifyToken, authorizeRoles("HOD", "STUDENT"), requireStudentOrHod("studentId"), downloadStudentSubjectReport);
router.get("/student/:studentId/subjects-pdf", verifyToken, authorizeRoles("HOD", "STUDENT"), requireStudentOrHod("studentId"), downloadStudentSubjectReport);

// 3. Subject overall attendance PDF
router.get("/subject/:subjectId/pdf", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Subject, "subjectId", "subject"), downloadSubjectReport);
router.get("/subject/:subjectId/overall-pdf", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Subject, "subjectId", "subject"), downloadSubjectReport);

// 4. Full batch attendance PDF
router.get("/batch/:batchId/pdf", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Batch, "batchId", "batch"), downloadFullBatchReport);
router.get("/batch/:batchId/full-pdf", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Batch, "batchId", "batch"), downloadFullBatchReport);

// 5. Monthly batch attendance PDF & Preview
router.get("/batch/:batchId/monthly-pdf", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Batch, "batchId", "batch"), downloadMonthlyBatchReport);
router.get("/batch/:batchId/monthly-preview", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Batch, "batchId", "batch"), previewMonthlyBatchReport);

// 6. Department attendance PDF
router.get("/department/:departmentId/pdf", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Department, "departmentId", "department"), downloadDepartmentReport);
router.get("/department/pdf", verifyToken, authorizeRoles("HOD"), downloadDepartmentReport);

// 7. Defaulter report PDF (< 75%)
router.get("/defaulters/pdf", verifyToken, authorizeRoles("HOD"), downloadDefaultersReport);
router.get("/defaulters-pdf", verifyToken, authorizeRoles("HOD"), downloadDefaultersReport);
router.get("/batch/:batchId/defaulters-pdf", verifyToken, authorizeRoles("HOD"), requireHodDepartmentResource(Batch, "batchId", "batch"), downloadBatchDefaultersReport);

module.exports = router;
