require("dotenv").config();

const express = require("express");
const cors = require("cors");

const connectDB = require("./config/db");

const authRoutes = require("./routes/authRoutes");
const studentRoutes = require("./routes/studentRoutes");
const batchRoutes = require("./routes/batchRoutes");
const departmentRoutes = require("./routes/departmentRoutes");
const teacherRoutes = require("./routes/teacherRoutes");
const subjectRoutes = require("./routes/subjectRoutes");
const attendanceRoutes = require("./routes/attendanceRoutes");
const dashboardRoutes = require("./routes/dashboardRoutes");
const reportRoutes = require("./routes/reportRoutes");
const timetableRoutes = require("./routes/timetableRoutes");
const leaveRoutes = require("./routes/leaveRoutes");
const notificationRoutes = require("./routes/notificationRoutes");

const app = express();

connectDB();

app.use(cors());
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/students", studentRoutes);
app.use("/api/batches", batchRoutes);
app.use("/api/departments", departmentRoutes);
app.use("/api/teachers", teacherRoutes);
app.use("/api/subjects", subjectRoutes);
app.use("/api/attendance", attendanceRoutes);
app.use("/api/dashboard", dashboardRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/timetable", timetableRoutes);
app.use("/api/leaves", leaveRoutes);
app.use("/api/notifications", notificationRoutes);

app.get("/", (req, res) => {
    res.send("Attendance ERP API Running");
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Server running on ${PORT}`);
});