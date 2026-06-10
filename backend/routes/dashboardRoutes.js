const express = require("express");

const router = express.Router();

const {
    getHodDashboard,
    getTeacherDashboard,
    getStudentDashboard
} = require(
    "../controllers/dashboardController"
);

router.get( "/hod", getHodDashboard ); 
router.get( "/teacher/:teacherId", getTeacherDashboard ); 
router.get( "/student/:studentId", getStudentDashboard );

module.exports = router;