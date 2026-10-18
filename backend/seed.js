require("dotenv").config({ path: ".env" });
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

// Models from backend
const User = require("./models/User");
const Department = require("./models/Department");
const Batch = require("./models/Batch");
const Teacher = require("./models/Teacher");
const Student = require("./models/Student");
const Subject = require("./models/Subject");
const Timetable = require("./models/Timetable");
const Attendance = require("./models/Attendance");
const Leave = require("./models/Leave");
const Notification = require("./models/Notification");

async function seed() {
  try {
    console.log("Connecting to MongoDB Atlas...");
    await mongoose.connect(process.env.MONGO_URI);
    console.log("MongoDB Connected successfully.");

    // Clear existing collections except User (or reset User safely)
    await Promise.all([
      Department.deleteMany({}),
      Batch.deleteMany({}),
      Teacher.deleteMany({}),
      Student.deleteMany({}),
      Subject.deleteMany({}),
      Timetable.deleteMany({}),
      Attendance.deleteMany({}),
      Leave.deleteMany({}),
      Notification.deleteMany({}),
      User.deleteMany({}),
    ]);
    console.log("Cleared existing data.");

    // 1. Department
    const csDept = await Department.create({
      departmentName: "Computer Science",
      departmentCode: "CS",
      hodName: "Anu Varghese",
      isActive: true,
    });
    console.log("Department created:", csDept.departmentName);

    // 2. Users (HOD, Teachers, Student)
    const hodPass = await bcrypt.hash("Hod@123", 10);
    const teacherPass = await bcrypt.hash("Teacher@123", 10);
    const studentPass = await bcrypt.hash("Student@123", 10);

    const hodUser = await User.create({
      name: "Anu Varghese",
      email: "anu@mescas.org",
      password: hodPass,
      role: "HOD",
      department: "Computer Science",
      phone: "+91 9876543210",
    });

    const teacherUser1 = await User.create({
      name: "Rijina NM",
      email: "rijina@mescas.org",
      password: teacherPass,
      role: "TEACHER",
      department: "Computer Science",
      phone: "+91 9876543211",
    });

    const teacherUser2 = await User.create({
      name: "Sheetal",
      email: "sheetal@mescas.org",
      password: teacherPass,
      role: "TEACHER",
      department: "Computer Science",
      phone: "+91 9876543212",
    });

    const studentUser1 = await User.create({
      name: "Shiyas ps",
      email: "shiyasps@mescas.org",
      password: studentPass,
      role: "STUDENT",
      department: "Computer Science",
      phone: "+91 9876543213",
    });

    const studentUser2 = await User.create({
      name: "real Student",
      email: "shiyasps33@gmail.com",
      password: studentPass,
      role: "STUDENT",
      department: "Computer Science",
      phone: "+91 9876543214",
    });
    console.log("Users created for HOD, Teachers, and Student.");

    // 3. Teachers in Teacher collection
    const teacherAnu = await Teacher.create({
      teacherName: "Anu Varghese",
      employeeId: "T001",
      email: "anu@mescas.org",
      password: hodPass,
      phoneNo: "+91 9876543210",
      departments: [csDept._id],
    });

    const teacherRijina = await Teacher.create({
      teacherName: "Rijina NM",
      employeeId: "T002",
      email: "rijina@mescas.org",
      password: teacherPass,
      phoneNo: "+91 9876543211",
      departments: [csDept._id],
    });

    const teacherSheetal = await Teacher.create({
      teacherName: "Sheetal",
      employeeId: "T003",
      email: "sheetal@mescas.org",
      password: teacherPass,
      phoneNo: "+91 9876543212",
      departments: [csDept._id],
    });

    const teacherAnju = await Teacher.create({
      teacherName: "Anju Krishna",
      employeeId: "T004",
      email: "anju@mescas.org",
      password: teacherPass,
      phoneNo: "+91 9876543214",
      departments: [csDept._id],
    });
    console.log("Teachers created in Teacher collection.");

    // 4. Batches
    const s2Batch = await Batch.create({
      batchName: "S2 BCA",
      program: "BCA",
      department: "Computer Science",
      currentSemester: 2,
      admissionYear: 2024,
      startYear: 2024,
      endYear: 2027,
    });

    const s4Batch = await Batch.create({
      batchName: "S4 BCA",
      program: "BCA",
      department: "Computer Science",
      currentSemester: 4,
      admissionYear: 2023,
      startYear: 2023,
      endYear: 2026,
    });

    const s6Batch = await Batch.create({
      batchName: "S6 BCA",
      program: "BCA",
      department: "Computer Science",
      currentSemester: 6,
      admissionYear: 2022,
      startYear: 2022,
      endYear: 2025,
    });
    console.log("Batches created (S2 BCA, S4 BCA, S6 BCA).");

    // 5. Students in S2 BCA
    const studentNames = [
      { name: "Abel Joseph", reg: "21/BCA/01", email: "abel@mescas.org", aadhaar: "123456781001" },
      { name: "Adithya K", reg: "21/BCA/02", email: "adithya@mescas.org", aadhaar: "123456781002" },
      { name: "Ananthu Prasad", reg: "21/BCA/03", email: "ananthu@mescas.org", aadhaar: "123456781003" },
      { name: "Shiyas ps", reg: "21/BCA/04", email: "shiyas@mescas.org", aadhaar: "123456781004" },
      { name: "Sidharth S", reg: "21/BCA/05", email: "sidharth@mescas.org", aadhaar: "123456781005" },
      { name: "Sneha Sunil", reg: "21/BCA/06", email: "sneha@mescas.org", aadhaar: "123456781006" },
      { name: "Sreehari S", reg: "21/BCA/07", email: "sreehari@mescas.org", aadhaar: "123456781007" },
      { name: "Vinayak S", reg: "21/BCA/08", email: "vinayak@mescas.org", aadhaar: "123456781008" },
    ];

    const studentDocs = [];
    for (const s of studentNames) {
      const doc = await Student.create({
        studentName: s.name,
        registerNo: s.reg,
        email: s.email,
        password: studentPass,
        phoneNo: "+91 9000000000",
        apaarId: `APAAR-${s.reg.replace(/\//g, "-")}`,
        aadhaarEncrypted: s.aadhaar,
        batchId: s2Batch._id,
        department: "Computer Science",
      });
      studentDocs.push(doc);
    }
    console.log(`Created ${studentDocs.length} students in S2 BCA.`);

    // 6. Subjects (Max semester = 6)
    const subDS = await Subject.create({
      subjectName: "Data Structures",
      subjectCode: "BCA201",
      departments: [csDept._id],
      teachers: [teacherAnu._id],
      semester: 2,
      credits: 4,
    });

    const subOS = await Subject.create({
      subjectName: "Operating Systems",
      subjectCode: "BCA202",
      departments: [csDept._id],
      teachers: [teacherSheetal._id],
      semester: 2,
      credits: 4,
    });

    const subWeb = await Subject.create({
      subjectName: "Web Development",
      subjectCode: "BCA203",
      departments: [csDept._id],
      teachers: [teacherAnu._id],
      semester: 2,
      credits: 3,
    });

    const subC = await Subject.create({
      subjectName: "C Programming",
      subjectCode: "BCA204",
      departments: [csDept._id],
      teachers: [teacherRijina._id],
      semester: 2,
      credits: 4,
    });

    const subEng = await Subject.create({
      subjectName: "English",
      subjectCode: "BCA205",
      departments: [csDept._id],
      teachers: [teacherRijina._id],
      semester: 2,
      credits: 3,
    });

    const subPython = await Subject.create({
      subjectName: "Python",
      subjectCode: "BCA401",
      departments: [csDept._id],
      teachers: [teacherAnu._id],
      semester: 4,
      credits: 4,
    });

    const subSE = await Subject.create({
      subjectName: "Software Engineering",
      subjectCode: "BCA402",
      departments: [csDept._id],
      teachers: [teacherSheetal._id],
      semester: 4,
      credits: 4,
    });

    const subNetworks = await Subject.create({
      subjectName: "Computer Networks",
      subjectCode: "BCA601",
      departments: [csDept._id],
      teachers: [teacherRijina._id],
      semester: 6,
      credits: 4,
    });

    console.log("Subjects created for S2, S4, S6 BCA.");

    // 7. Timetable entries for S2 BCA
    const days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
    const periods = [
      { start: "09:30", end: "10:30", room: "Room 101" },
      { start: "10:30", end: "11:30", room: "Room 101" },
      { start: "11:30", end: "12:30", room: "Room 101" },
      { start: "13:30", end: "14:30", room: "Lab 1" },
      { start: "14:30", end: "15:30", room: "Lab 1" },
    ];

    const s2Subjects = [subDS, subOS, subWeb, subC, subEng];
    const s2Teachers = [teacherAnu, teacherSheetal, teacherAnu, teacherRijina, teacherRijina];

    for (let d = 0; d < days.length; d++) {
      for (let p = 0; p < periods.length; p++) {
        const subIndex = (d * 2 + p) % s2Subjects.length;
        await Timetable.create({
          batch: s2Batch._id,
          subject: s2Subjects[subIndex]._id,
          teacher: s2Teachers[subIndex]._id,
          day: days[d],
          startTime: periods[p].start,
          endTime: periods[p].end,
          roomNo: periods[p].room,
          isActive: true,
        });
      }
    }
    console.log("Timetable created: 25 periods populated for S2 BCA.");

    // 8. Attendance Records (10 sessions with realistic Present/Absent distribution)
    // To generate defaulters (< 75%), let student 2 & 5 have lower attendance:
    for (let session = 1; session <= 10; session++) {
      const sessionDate = new Date();
      sessionDate.setDate(sessionDate.getDate() - session);

      for (let sIdx = 0; sIdx < studentDocs.length; sIdx++) {
        const st = studentDocs[sIdx];
        // Students 2 & 5 will have low attendance (60% and 50%)
        let status = "Present";
        if (sIdx === 1 && session > 6) status = "Absent"; // 60%
        if (sIdx === 4 && session > 5) status = "Absent"; // 50%
        if (sIdx === 6 && session > 7) status = "Absent"; // 70%

        await Attendance.create({
          student: st._id,
          subject: subDS._id,
          teacher: teacherAnu._id,
          batch: s2Batch._id,
          date: sessionDate,
          status: status,
        });
      }
    }
    console.log("Historical attendance records created (defaulters generated).");

    // 9. Leave Requests & Notifications
    const leave = await Leave.create({
      applicantId: teacherRijina._id,
      applicantType: "TEACHER",
      reason: "Medical leave for 2 days",
      fromDate: new Date(),
      toDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000),
      status: "PENDING_HOD",
      teacherApproval: true,
      hodApproval: false,
    });

    await Notification.create({
      recipientId: hodUser._id,
      recipientRole: "HOD",
      title: "Leave Request",
      message: "Rijina NM applied for Medical leave (2 days).",
      isRead: false,
    });

    console.log("Leave and Notification entries created.");

    console.log("\n===========================================");
    console.log("DATABASE SEEDING COMPLETED SUCCESSFULLY!");
    console.log("===========================================");
    process.exit(0);
  } catch (err) {
    console.error("Seeding error:", err);
    process.exit(1);
  }
}

seed();