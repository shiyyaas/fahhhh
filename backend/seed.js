require("dotenv").config({ path: ".env" });
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

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

const DEFAULT_PASSWORDS = {
  hod: "Hod@123",
  teacher: "Teacher@123",
  student: "Student@123",
};

async function findOrCreate(Model, filter, data) {
  let doc = await Model.findOne(filter);
  if (doc) return doc;

  try {
    doc = await Model.create({ ...data, ...filter });
    return doc;
  } catch (error) {
    // Handles two seed processes attempting to create the same unique record.
    if (error.code === 11000) {
      const existing = await Model.findOne(filter);
      if (existing) return existing;
    }
    throw error;
  }
}

function atLocalMidnight(date) {
  const value = new Date(date);
  value.setHours(0, 0, 0, 0);
  return value;
}

async function seed() {
  try {
    if (!process.env.MONGO_URI) {
      throw new Error("MONGO_URI is missing. Check backend/.env");
    }

    console.log("Connecting to MongoDB...");
    await mongoose.connect(process.env.MONGO_URI);
    console.log("MongoDB connected.");

    const [hodPassword, teacherPassword, studentPassword] = await Promise.all([
      bcrypt.hash(DEFAULT_PASSWORDS.hod, 10),
      bcrypt.hash(DEFAULT_PASSWORDS.teacher, 10),
      bcrypt.hash(DEFAULT_PASSWORDS.student, 10),
    ]);

    // 1. Department: keep existing records; add only missing sample records.
    const departmentSeeds = [
      { departmentName: "Computer Science", departmentCode: "CS", hodName: "Anu Varghese" },
      { departmentName: "Commerce", departmentCode: "COM", hodName: "Anu Varghese" },
      { departmentName: "Electronics", departmentCode: "EL", hodName: "Anu Varghese" },
    ];

    const departments = {};
    for (const item of departmentSeeds) {
      departments[item.departmentCode] = await findOrCreate(
        Department,
        { departmentCode: item.departmentCode },
        { ...item, isActive: true }
      );
    }
    const csDept = departments.CS;

    // 2. Login accounts. Existing accounts are never overwritten.
    const hodUser = await findOrCreate(
      User,
      { email: "anu@mescas.org" },
      {
        name: "Anu Varghese",
        password: hodPassword,
        role: "HOD",
        department: "Computer Science",
        phone: "+91 9876543210",
        isActive: true,
      }
    );

    const teacherSeedData = [
      ["Anu Varghese", "T001", "anu@mescas.org", "+91 9876543210"],
      ["Rijina NM", "T002", "rijina@mescas.org", "+91 9876543211"],
      ["Sheetal", "T003", "sheetal@mescas.org", "+91 9876543212"],
      ["Anju Krishna", "T004", "anju@mescas.org", "+91 9876543214"],
      ["Fathima", "T005", "fathima@mescas.org", "+91 9876543215"],
      ["Naseema", "T006", "naseema@mescas.org", "+91 9876543216"],
      ["Sreelakshmi", "T007", "sreelakshmi@mescas.org", "+91 9876543217"],
      ["Meera", "T008", "meera@mescas.org", "+91 9876543218"],
      ["Arun", "T009", "arun@mescas.org", "+91 9876543219"],
      ["Rahul", "T010", "rahul@mescas.org", "+91 9876543220"],
      ["Nisha", "T011", "nisha@mescas.org", "+91 9876543221"],
      ["Vishnu", "T012", "vishnu@mescas.org", "+91 9876543222"],
    ];

    const teachers = [];
    for (const [teacherName, employeeId, email, phoneNo] of teacherSeedData) {
      await findOrCreate(
        User,
        { email },
        {
          name: teacherName,
          password: teacherPassword,
          role: "TEACHER",
          department: "Computer Science",
          phone: phoneNo,
          isActive: true,
        }
      );

      const teacher = await findOrCreate(
        Teacher,
        { employeeId },
        {
          teacherName,
          email,
          password: teacherPassword,
          phoneNo,
          departments: [csDept._id],
          isActive: true,
        }
      );
      teachers.push(teacher);
    }

    // 3. Batches: preserve the original batch names.
    const batchSeeds = [
      { batchName: "S2 BCA", admissionYear: 2024, currentSemester: 2, startYear: 2024, endYear: 2027 },
      { batchName: "S4 BCA", admissionYear: 2023, currentSemester: 4, startYear: 2023, endYear: 2026 },
      { batchName: "S6 BCA", admissionYear: 2022, currentSemester: 6, startYear: 2022, endYear: 2025 },
    ];

    const batches = [];
    for (const item of batchSeeds) {
      batches.push(
        await findOrCreate(
          Batch,
          { batchName: item.batchName },
          {
            ...item,
            program: "BCA",
            department: "Computer Science",
            isActive: true,
          }
        )
      );
    }

    // 4. Subjects: 8 subjects per semester, 24 total.
    const subjectDefinitions = [
      { semester: 2, items: [
        ["Data Structures", "BCA201", 4], ["Operating Systems", "BCA202", 4],
        ["Web Development", "BCA203", 3], ["C Programming", "BCA204", 4],
        ["English", "BCA205", 3], ["Mathematics", "BCA206", 4],
        ["Database Fundamentals", "BCA207", 3], ["Environmental Studies", "BCA208", 2],
      ]},
      { semester: 4, items: [
        ["Python Programming", "BCA401", 4], ["Software Engineering", "BCA402", 4],
        ["Computer Organization", "BCA403", 4], ["Java Programming", "BCA404", 4],
        ["Professional English", "BCA405", 3], ["Web Technologies", "BCA406", 3],
        ["Data Communication", "BCA407", 3], ["Entrepreneurship", "BCA408", 2],
      ]},
      { semester: 6, items: [
        ["Computer Networks", "BCA601", 4], ["Artificial Intelligence", "BCA602", 4],
        ["Machine Learning", "BCA603", 4], ["Mobile Application Development", "BCA604", 4],
        ["Cloud Computing", "BCA605", 3], ["Cyber Security", "BCA606", 3],
        ["Project", "BCA607", 4], ["Elective", "BCA608", 3],
      ]},
    ];

    const subjectsBySemester = {};
    for (const group of subjectDefinitions) {
      subjectsBySemester[group.semester] = [];
      for (let i = 0; i < group.items.length; i++) {
        const [subjectName, subjectCode, credits] = group.items[i];
        const teacher = teachers[(i + group.semester) % teachers.length];
        const subject = await findOrCreate(
          Subject,
          { subjectCode },
          {
            subjectName,
            departments: [csDept._id],
            teachers: [teacher._id],
            semester: group.semester,
            credits,
            isActive: true,
          }
        );
        subjectsBySemester[group.semester].push(subject);
      }
    }

    // 5. Students: 30 per batch, 90 total. Student and User accounts share email.
    const firstNames = [
      "Abel", "Adithya", "Ananthu", "Shiyas", "Sidharth", "Sneha",
      "Sreehari", "Vinayak", "Akhil", "Amal", "Anjali", "Arjun",
      "Athira", "Devika", "Fathima", "Gokul", "Haris", "Irfan",
      "Jithin", "Kavya", "Midhun", "Nandana", "Nihal", "Riya",
      "Rohit", "Sana", "Shahana", "Surya", "Vishal", "Zara",
    ];
    const lastNames = [
      "Joseph", "K", "Prasad", "P S", "S", "Sunil", "Menon", "Nair",
      "Thomas", "M", "Raj", "Krishnan", "Varma", "Basheer", "Ali",
    ];

    const studentsByBatch = [];
    for (let batchIndex = 0; batchIndex < batches.length; batchIndex++) {
      const batch = batches[batchIndex];
      const batchStudents = [];

      for (let i = 0; i < 30; i++) {
        const serial = batchIndex * 30 + i + 1;
        const first = firstNames[i];
        const last = lastNames[(i + batchIndex) % lastNames.length];
        const studentName = `${first} ${last}`;
        const registerNo = `BCA${batch.admissionYear}${String(i + 1).padStart(3, "0")}`;
        const email = `student${String(serial).padStart(3, "0")}@mescas.org`;
        const phoneNo = `+91 90000${String(10000 + serial).slice(-5)}`;

        await findOrCreate(
          User,
          { email },
          {
            name: studentName,
            password: studentPassword,
            role: "STUDENT",
            department: "Computer Science",
            phone: phoneNo,
            isActive: true,
          }
        );

        const student = await findOrCreate(
          Student,
          { registerNo },
          {
            studentName,
            email,
            password: studentPassword,
            phoneNo,
            apaarId: `APAAR-${registerNo}`,
            batchId: batch._id,
            department: "Computer Science",
            isActive: true,
          }
        );
        batchStudents.push(student);
      }
      studentsByBatch.push(batchStudents);
    }

    // 6. Timetable: 25 entries per batch (75 total), no roomNo field.
    // Each batch has its own teacher allocation at a given time slot.
    const days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
    const periods = [
      { startTime: "09:30", endTime: "10:30" },
      { startTime: "10:30", endTime: "11:30" },
      { startTime: "11:30", endTime: "12:30" },
      { startTime: "13:30", endTime: "14:30" },
      { startTime: "14:30", endTime: "15:30" },
    ];

    for (let b = 0; b < batches.length; b++) {
      const batch = batches[b];
      const semester = batch.currentSemester;
      const semesterSubjects = subjectsBySemester[semester];

      for (let d = 0; d < days.length; d++) {
        for (let p = 0; p < periods.length; p++) {
          const subjectIndex = (d * 2 + p) % semesterSubjects.length;
          const teacherIndex = (b * periods.length + p) % teachers.length;
          const slot = periods[p];

          await findOrCreate(
            Timetable,
            {
              batch: batch._id,
              day: days[d],
              startTime: slot.startTime,
            },
            {
              subject: semesterSubjects[subjectIndex]._id,
              teacher: teachers[teacherIndex]._id,
              endTime: slot.endTime,
              isActive: true,
            }
          );
        }
      }
    }

    // 7. Attendance: 10 sessions per student (900 records total).
    // Selected students intentionally have less than 75% attendance for dashboard testing.
    const attendanceBaseDate = atLocalMidnight(new Date());
    for (let b = 0; b < batches.length; b++) {
      const batch = batches[b];
      const batchStudents = studentsByBatch[b];
      const semesterSubjects = subjectsBySemester[batch.currentSemester];

      for (let session = 1; session <= 10; session++) {
        const sessionDate = new Date(attendanceBaseDate);
        sessionDate.setDate(sessionDate.getDate() - session);

        const subject = semesterSubjects[(session - 1) % semesterSubjects.length];
        const teacher = teachers[(session + b) % teachers.length];

        for (let s = 0; s < batchStudents.length; s++) {
          let status = "Present";
          if (s === 1 && session > 6) status = "Absent"; // 60% attendance
          if (s === 4 && session > 5) status = "Absent"; // 50% attendance
          if (s === 6 && session > 7) status = "Absent"; // 70% attendance

          await findOrCreate(
            Attendance,
            {
              student: batchStudents[s]._id,
              subject: subject._id,
              date: sessionDate,
            },
            {
              teacher: teacher._id,
              batch: batch._id,
              status,
            }
          );
        }
      }
    }

    // 8. Leave requests: 15 sample requests. Existing matching requests are retained.
    const leaveReasons = [
      "Medical appointment", "Family function", "Personal reasons",
      "Fever and rest", "University-related event",
    ];
    const leaveApplicants = [
      ...teachers.slice(1, 6).map((doc) => ({ id: doc._id, type: "TEACHER", name: doc.teacherName })),
      ...studentsByBatch.flatMap((list) => list.slice(0, 10).map((doc) => ({
        id: doc._id, type: "STUDENT", name: doc.studentName,
      }))),
    ];

    for (let i = 0; i < 15; i++) {
      const applicant = leaveApplicants[i];
      const fromDate = atLocalMidnight(new Date());
      fromDate.setDate(fromDate.getDate() + (i % 5));
      const toDate = new Date(fromDate);
      toDate.setDate(toDate.getDate() + (i % 2));

      const status = ["PENDING_TEACHER", "PENDING_HOD", "APPROVED", "REJECTED"][i % 4];
      await findOrCreate(
        Leave,
        {
          applicantId: applicant.id,
          fromDate,
          reason: leaveReasons[i % leaveReasons.length],
        },
        {
          applicantType: applicant.type,
          toDate,
          status,
          teacherApproval: status !== "PENDING_TEACHER",
          hodApproval: status === "APPROVED",
        }
      );
    }

    // 9. Notifications: create sample notifications for HOD, teachers and students.
    const notificationTargets = [
      { id: hodUser._id, role: "HOD", name: "Anu Varghese" },
      ...teachers.slice(1, 6).map((doc) => ({ id: doc._id, role: "TEACHER", name: doc.teacherName })),
      ...studentsByBatch.flatMap((list) => list.slice(0, 8).map((doc) => ({
        id: doc._id, role: "STUDENT", name: doc.studentName,
      }))),
    ];

    for (let i = 0; i < 30; i++) {
      const target = notificationTargets[i % notificationTargets.length];
      const title = [
        "Attendance Reminder",
        "Timetable Update",
        "Leave Request Update",
        "College Announcement",
        "Academic Notification",
      ][i % 5];

      await findOrCreate(
        Notification,
        {
          recipientId: target.id,
          title,
          message: `${title}: Sample notification for ${target.name}.`,
        },
        {
          recipientRole: target.role,
          isRead: i % 3 === 0,
        }
      );
    }

    console.log("\n===========================================");
    console.log("NON-DESTRUCTIVE DATABASE SEED COMPLETED");
    console.log("Existing records were not deleted or overwritten.");
    console.log("Departments: 3 | Batches: 3 | Teachers: 12");
    console.log("Students: 90 | Subjects: 24 | Timetable entries: up to 75");
    console.log("Attendance: up to 900 | Leaves: up to 15 | Notifications: up to 30");
    console.log("===========================================");
  } catch (error) {
    console.error("Seeding failed:", error);
    process.exitCode = 1;
  } finally {
    await mongoose.disconnect().catch(() => {});
  }
}

seed();
