const express = require("express");
const router = express.Router();

const { verifyToken, authorizeRoles } = require("../middleware/authMiddleware");
const { requireStudentOrHod } = require("../middleware/ownership");
const {
  getEligibleStudents,
  getStudentEligibility,
  exportEligibleCSV,
  exportEligiblePDF
} = require("../controllers/condonationController");

// Department-wide condonation routes: HOD only
router.get("/eligible", verifyToken, authorizeRoles("HOD"), getEligibleStudents);
router.get("/eligible/export/csv", verifyToken, authorizeRoles("HOD"), exportEligibleCSV);
router.get("/eligible/export/pdf", verifyToken, authorizeRoles("HOD"), exportEligiblePDF);

// Student-specific eligibility route: HOD (own dept) and STUDENT (own record only)
router.get(
  "/student/:studentId",
  verifyToken,
  authorizeRoles("HOD", "STUDENT"),
  requireStudentOrHod("studentId"),
  getStudentEligibility
);

module.exports = router;
