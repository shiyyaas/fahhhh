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

router.get( "/student/:studentId", getStudentReport);
router.get( "/batch/:batchId", getBatchReport);
router.get("/subject/:subjectId", getSubjectReport);
router.get("/student/:studentId/pdf", downloadStudentReport);
router.get("/batch/:batchId/monthly-pdf", downloadMonthlyBatchReport);
router.get("/batch/:batchId/monthly-preview", previewMonthlyBatchReport);

module.exports = router;