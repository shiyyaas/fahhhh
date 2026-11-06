const assert = require("node:assert/strict");
const { after, beforeEach, test } = require("node:test");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const Module = require("node:module");
const path = require("node:path");

process.env.JWT_SECRET = "backend-tests-only-secret";

const ids = {
  user: "000000000000000000000001",
  teacherUser: "000000000000000000000002",
  student: "000000000000000000000011",
  otherStudent: "000000000000000000000012",
  teacher: "000000000000000000000021",
  subject: "000000000000000000000031",
  batch: "000000000000000000000041",
  department: "000000000000000000000051",
  attendance: "000000000000000000000061"
};
const passwordHash = bcrypt.hashSync("correct-password", 4);
const student = {
  _id: ids.student,
  studentName: "Test Student",
  registerNo: "T-001",
  email: "student@example.test",
  department: "Test Department",
  batchId: ids.batch,
  password: "student-hash",
  aadhaarEncrypted: "test-only"
};
const otherStudent = {
  ...student,
  _id: ids.otherStudent,
  studentName: "Other Test Student",
  email: "other.student@example.test"
};
const batch = {
  _id: ids.batch,
  batchName: "Test Batch",
  department: "Test Department",
  program: "BCA",
  currentSemester: 1,
  admissionYear: 2025
};
const subject = {
  _id: ids.subject,
  subjectName: "Test Subject",
  subjectCode: "TST101",
  semester: 1,
  departments: [ids.department],
  teachers: [ids.teacher]
};
const teacher = {
  _id: ids.teacher,
  teacherName: "Test Teacher",
  employeeId: "T-001",
  email: "teacher@example.test",
  departments: [ids.department]
};

let attendanceRecords = [];
let studentCountResults = {};
let reportAggregateCalls = [];
let monthlyAggregatePipeline;
let studentsForReports = [];
let lastFindOneAndUpdate;
let selectedStudentFields;

const clone = (value) => structuredClone(value);
const query = (value) => {
  const state = { value };
  const chain = {
    select(fields) {
      if (typeof fields === "string") selectedStudentFields = fields;
      return chain;
    },
    populate() {
      return chain;
    },
    sort() {
      return chain;
    },
    limit() {
      return chain;
    },
    then(resolve, reject) {
      return Promise.resolve(state.value).then(resolve, reject);
    }
  };
  return chain;
};
const matches = (record, filter) => Object.entries(filter).every(([key, value]) => {
  if (key === "date" && value && value.$gte) {
    const time = new Date(record.date).getTime();
    return time >= value.$gte.getTime() && time <= value.$lte.getTime();
  }
  if (value && typeof value === "object" && "$in" in value) {
    return value.$in.includes(record[key]);
  }
  return String(record[key]) === String(value);
});
const castError = () => Object.assign(new Error("Cast failed"), { name: "CastError" });
const userById = (id) => {
  if (id === ids.user) {
    return { _id: ids.user, email: student.email, name: "Test Student", role: "STUDENT", password: passwordHash };
  }
  if (id === ids.teacherUser) {
    return { _id: ids.teacherUser, email: teacher.email, name: teacher.teacherName, role: "TEACHER", password: passwordHash };
  }
  return null;
};

const mocks = {
  "../models/Attendance": {
    find(filter = {}) {
      const records = attendanceRecords.filter((record) => matches(record, filter)).map(clone);
      return {
        populate() { return this; },
        then(resolve, reject) { return Promise.resolve(records).then(resolve, reject); }
      };
    },
    findById(id) {
      if (!/^[a-f\d]{24}$/i.test(id)) throw castError();
      const record = attendanceRecords.find((item) => item._id === id);
      if (!record) return null;
      const editable = clone(record);
      editable.save = async () => {
        const index = attendanceRecords.findIndex((item) => item._id === id);
        attendanceRecords[index] = { ...editable };
        delete attendanceRecords[index].save;
        return attendanceRecords[index];
      };
      return editable;
    },
    async findByIdAndDelete(id) {
      if (!/^[a-f\d]{24}$/i.test(id)) throw castError();
      const index = attendanceRecords.findIndex((record) => record._id === id);
      if (index < 0) return null;
      return attendanceRecords.splice(index, 1)[0];
    },
    async findOneAndUpdate(filter, update) {
      lastFindOneAndUpdate = { filter, update };
      const existing = attendanceRecords.find((record) => matches(record, filter));
      if (existing) {
        Object.assign(existing, update);
        return clone(existing);
      }
      const created = { _id: ids.attendance, ...update };
      attendanceRecords.push(created);
      return clone(created);
    },
    async countDocuments(filter) {
      if (filter.student && filter.status) {
        return studentCountResults[filter.student]?.[filter.status] || 0;
      }
      return attendanceRecords.filter((record) => matches(record, filter)).length;
    },
    async aggregate(pipeline) {
      reportAggregateCalls.push(pipeline);
      if (pipeline[0].$match.date) {
        monthlyAggregatePipeline = pipeline;
        return [{ _id: ids.student, totalClasses: 3, presentClasses: 2 }];
      }
      const studentId = pipeline[0].$match.student;
      const records = attendanceRecords.filter((record) => record.student === studentId);
      if (pipeline[1].$group._id === null) {
        if (records.length === 0) return [];
        return [{
          totalClasses: records.length,
          present: records.filter((record) => record.status === "Present").length,
          late: records.filter((record) => record.status === "Late").length,
          absent: records.filter((record) => record.status === "Absent").length
        }];
      }
      const bySubject = new Map();
      for (const record of records) {
        const current = bySubject.get(record.subject) || { totalClasses: 0, present: 0, late: 0, absent: 0 };
        current.totalClasses += 1;
        if (record.status === "Present") current.present += 1;
        if (record.status === "Late") current.late += 1;
        if (record.status === "Absent") current.absent += 1;
        bySubject.set(record.subject, current);
      }
      return [...bySubject].map(([subjectId, stats]) => ({
        subjectId,
        subjectName: subject.subjectName,
        ...stats
      }));
    }
  },
  "../models/Student": {
    findById(id) {
      if (!/^[a-f\d]{24}$/i.test(id)) throw castError();
      if (id === ids.student) {
        const result = clone(student);
        result.populate = () => query(result);
        return query(result);
      }
      if (id === ids.otherStudent) return query(clone(otherStudent));
      return query(null);
    },
    find(filter) {
      if (filter && filter.email) {
        const email = filter.email;
        return query([student, otherStudent]
          .filter((record) => email.test(record.email)));
      }
      if (filter && filter.batchId) {
        return query(studentsForReports.filter((record) => record.batchId === filter.batchId));
      }
      return query(studentsForReports);
    }
  },
  "../models/Teacher": {
    find(filter) {
      return query(filter.email.test(teacher.email) ? [{ ...teacher }] : []);
    }
  },
  "../models/User": {
    findOne(filter) {
      if (filter._id && filter.role) {
        return query(userById(filter._id));
      }
      return query(filter.email === "student@example.test"
        ? userById(ids.user)
        : filter.email === "teacher@example.test"
          ? userById(ids.teacherUser)
          : null);
    }
  },
  "../models/Subject": {
    findOne(filter) {
      if (filter.teachers && filter._id === ids.subject && filter.teachers === ids.teacher) {
        return query({ ...subject });
      }
      return query(null);
    },
    findById(id) {
      if (!/^[a-f\d]{24}$/i.test(id)) throw castError();
      return query(id === ids.subject ? { ...subject } : null);
    }
  },
  "../models/Batch": {
    findById(id) {
      if (!/^[a-f\d]{24}$/i.test(id)) throw castError();
      return query(id === ids.batch ? { ...batch } : null);
    },
    find(filter = {}) {
      const result = filter._id && filter._id.$in
        ? [batch].filter((item) => filter._id.$in.includes(item._id))
        : [batch];
      return query(result);
    }
  },
  "../models/Department": {
    async exists() { return true; },
    find() { return query([{ _id: ids.department, departmentName: batch.department }]); }
  }
};

class FakePdfDocument {
  constructor() {
    this.y = 500;
  }
  rect() { return this; }
  stroke() { return this; }
  text() { return this; }
  moveDown() { return this; }
  fontSize() { return this; }
  image() { return this; }
  addPage() { return this; }
  moveTo() { return this; }
  lineTo() { return this; }
  pipe() { return this; }
  end() { return this; }
}

const originalLoad = Module._load;
Module._load = function(request, parent, isMain) {
  if (parent && parent.filename.includes(`${path.sep}controllers${path.sep}`) && mocks[request]) {
    return mocks[request];
  }
  if (request === "pdfkit" && parent && parent.filename.endsWith(`${path.sep}reportController.js`)) {
    return FakePdfDocument;
  }
  return originalLoad.call(this, request, parent, isMain);
};

const attendanceController = require("../controllers/attendanceController");
const authController = require("../controllers/authController");
const reportController = require("../controllers/reportController");
const studentController = require("../controllers/studentController");
after(() => {
  Module._load = originalLoad;
});

const response = () => ({
  statusCode: 200,
  status(code) { this.statusCode = code; return this; },
  json(body) { this.body = body; return this; },
  setHeader(name, value) { (this.headers ||= {})[name] = value; },
  send(body) { this.body = body; }
});
const req = (params = {}, body = {}, extra = {}) => ({
  params,
  body,
  query: {},
  user: { userId: ids.teacherUser, role: "TEACHER" },
  ...extra
});

beforeEach(() => {
  attendanceRecords = [];
  studentCountResults = {};
  reportAggregateCalls = [];
  monthlyAggregatePipeline = undefined;
  studentsForReports = [{ ...student }];
  lastFindOneAndUpdate = undefined;
  selectedStudentFields = undefined;
});

test("login accepts correct credentials and rejects invalid or missing credentials", async () => {
  const success = response();
  await authController.login(
    req({}, { email: " Student@Example.Test ", password: "correct-password" }),
    success
  );
  assert.equal(success.statusCode, 200);
  assert.equal(jwt.verify(success.body.token, process.env.JWT_SECRET).role, "STUDENT");
  assert.equal("password" in success.body.user, false);

  const invalid = response();
  await authController.login(req({}, { email: "student@example.test", password: "wrong" }), invalid);
  assert.equal(invalid.statusCode, 401);

  const missing = response();
  await authController.login(req({}, { email: "student@example.test" }), missing);
  assert.equal(missing.statusCode, 400);
});

test("student profile retrieval excludes password and Aadhaar fields", async () => {
  const res = response();
  await studentController.getStudent(req({ id: ids.student }), res);
  assert.equal(res.statusCode, 200);
  assert.equal(selectedStudentFields, "-password -aadhaarEncrypted");
});

test("mark attendance validates required fields, resources, and same-day upsert", async () => {
  const missing = response();
  await attendanceController.markAttendance(req({}, { student: ids.student }), missing);
  assert.equal(missing.statusCode, 400);

  const absentStudent = response();
  await attendanceController.markAttendance(req({}, {
    student: "000000000000000000000099",
    subject: ids.subject,
    batch: ids.batch,
    status: "Present"
  }), absentStudent);
  assert.equal(absentStudent.statusCode, 404);

  const missingSubject = response();
  await attendanceController.markAttendance(req({}, {
    student: ids.student,
    subject: "000000000000000000000099",
    batch: ids.batch,
    status: "Present"
  }), missingSubject);
  assert.equal(missingSubject.statusCode, 403);

  for (const [status, date] of [
    ["Present", "2026-03-04T09:10:00.000Z"],
    ["Absent", "2026-03-04T17:20:00.000Z"],
    ["Late", "2026-03-04T11:00:00.000Z"]
  ]) {
    const res = response();
    await attendanceController.markAttendance(req({}, {
      student: ids.student,
      subject: ids.subject,
      batch: ids.batch,
      teacher: "untrusted-client-teacher",
      status,
      date
    }), res);
    assert.equal(res.statusCode, 200);
    assert.equal(res.body.attendance.status, status);
    assert.equal(res.body.attendance.teacher, ids.teacher);
    assert.equal(lastFindOneAndUpdate.filter.date.$gte.getHours(), 0);
    assert.equal(lastFindOneAndUpdate.filter.date.$lte.getHours(), 23);
  }

  assert.equal(attendanceRecords.length, 1);
  assert.equal(lastFindOneAndUpdate.update.status, "Late");
});

test("attendance update/delete work, while invalid and missing records return 404", async () => {
  attendanceRecords = [{
    _id: ids.attendance,
    student: ids.student,
    subject: ids.subject,
    batch: ids.batch,
    teacher: ids.teacher,
    status: "Present",
    date: new Date("2026-03-04T09:00:00Z")
  }];
  const updated = response();
  await attendanceController.updateAttendance(req({ id: ids.attendance }, { status: "Absent" }), updated);
  assert.equal(updated.statusCode, 200);
  assert.equal(attendanceRecords[0].status, "Absent");

  const invalidId = response();
  const originalConsoleError = console.error;
  let loggedError;
  console.error = (...args) => { loggedError = args; };
  try {
    await attendanceController.updateAttendance(req({ id: "bad-id" }, {}), invalidId);
  } finally {
    console.error = originalConsoleError;
  }
  assert.equal(invalidId.statusCode, 404);
  assert.equal(loggedError[0], "Attendance API error:");

  const deleted = response();
  await attendanceController.deleteAttendance(req({ id: ids.attendance }), deleted);
  assert.equal(deleted.statusCode, 200);
  assert.equal(attendanceRecords.length, 0);

  const missing = response();
  await attendanceController.deleteAttendance(req({ id: ids.attendance }), missing);
  assert.equal(missing.statusCode, 404);
});

test("percentage and defaulter calculations handle policies, empty and absent-only records", async () => {
  studentCountResults[ids.student] = { Present: 2, Late: 1, Absent: 0 };
  for (const [policy, expected] of [["present", "100.00"], ["partial", "83.33"], ["absent", "66.67"]]) {
    process.env.LATE_AS = policy;
    const res = response();
    await attendanceController.getAttendancePercentage(
      { ...req({ studentId: ids.student }), user: { userId: ids.user, role: "STUDENT" } },
      res
    );
    assert.equal(res.body.attendancePercentage, expected);
    assert.equal(res.body.lateClasses, 1);
  }

  studentCountResults[ids.student] = { Present: 0, Late: 0, Absent: 0 };
  const empty = response();
  await attendanceController.getAttendancePercentage(
    { ...req({ studentId: ids.student }), user: { userId: ids.user, role: "STUDENT" } },
    empty
  );
  assert.equal(empty.body.totalClasses, 0);
  assert.equal(empty.body.attendancePercentage, 0);

  studentCountResults[ids.student] = { Present: 0, Late: 3, Absent: 0 };
  for (const [policy, expected] of [["present", "100.00"], ["partial", "50.00"], ["absent", "0.00"]]) {
    process.env.LATE_AS = policy;
    const lateOnly = response();
    await attendanceController.getAttendancePercentage(
      { ...req({ studentId: ids.student }), user: { userId: ids.user, role: "STUDENT" } },
      lateOnly
    );
    assert.equal(lateOnly.body.attendancePercentage, expected);
  }

  studentCountResults[ids.student] = { Present: 0, Late: 0, Absent: 4 };
  process.env.LATE_AS = "present";
  const defaulters = response();
  await attendanceController.getDefaulters(req(), defaulters);
  assert.equal(defaulters.body.totalDefaulters, 1);
  assert.equal(defaulters.body.defaulters[0].attendancePercentage, "0.00");

  studentCountResults[ids.student] = { Present: 3, Late: 0, Absent: 1 };
  const atThreshold = response();
  await attendanceController.getDefaulters(req(), atThreshold);
  assert.equal(atThreshold.body.totalDefaulters, 0);
});

test("student report, batch report and subject report return summary fields", async () => {
  attendanceRecords = [
    { student: ids.student, subject: ids.subject, batch: ids.batch, status: "Present" },
    { student: ids.student, subject: ids.subject, batch: ids.batch, status: "Late" },
    { student: ids.student, subject: ids.subject, batch: ids.batch, status: "Absent" }
  ];

  const studentReport = response();
  await reportController.getStudentReport(req({ studentId: ids.student }), studentReport);
  assert.equal(studentReport.statusCode, 200);
  assert.equal(studentReport.body.report.totalClasses, 3);

  const batchReport = response();
  await reportController.getBatchReport(req({ batchId: ids.batch }), batchReport);
  assert.equal(batchReport.statusCode, 200);
  assert.equal(batchReport.body.report.batchName, batch.batchName);

  const subjectReport = response();
  await reportController.getSubjectReport(req({ subjectId: ids.subject }), subjectReport);
  assert.equal(subjectReport.statusCode, 200);
  assert.equal(subjectReport.body.report.subjectCode, subject.subjectCode);

  process.env.LATE_AS = "partial";
  const attendanceReport = response();
  await attendanceController.getStudentReport(
    { ...req({ id: ids.student }), user: { userId: ids.user, role: "STUDENT" } },
    attendanceReport
  );
  assert.equal(attendanceReport.body.overall.attendancePercentage, "50.00");
  assert.equal(attendanceReport.body.subjects[0].attendancePercentage, "50.00");
  assert.equal(attendanceReport.body.overall.late, 1);
});

test("monthly report validates month and aggregates only the selected month", async () => {
  const invalid = response();
  await reportController.previewMonthlyBatchReport(
    { ...req({ batchId: ids.batch }), query: { month: "13", year: "2026" } },
    invalid
  );
  assert.equal(invalid.statusCode, 400);

  const monthly = response();
  await reportController.previewMonthlyBatchReport(
    { ...req({ batchId: ids.batch }), query: { month: "2", year: "2026" } },
    monthly
  );
  assert.equal(monthly.statusCode, 200);
  const dateRange = monthlyAggregatePipeline[0].$match.date;
  assert.equal(dateRange.$gte.getFullYear(), 2026);
  assert.equal(dateRange.$gte.getMonth(), 1);
  assert.equal(dateRange.$gte.getDate(), 1);
  assert.equal(dateRange.$lte.getFullYear(), 2026);
  assert.equal(dateRange.$lte.getMonth(), 1);
  assert.equal(dateRange.$lte.getDate(), 28);
  assert.equal(dateRange.$lte.getHours(), 23);
});

test("attendance model validates required fields and allowed statuses without a database", () => {
  const Attendance = require("../models/Attendance");
  const base = {
    student: ids.student,
    subject: ids.subject,
    teacher: ids.teacher,
    batch: ids.batch
  };

  assert.ok(new Attendance({ ...base, status: "Present" }).validateSync() === undefined);
  assert.ok(new Attendance({ ...base, status: "Absent" }).validateSync() === undefined);
  assert.ok(new Attendance({ ...base, status: "Late" }).validateSync() === undefined);
  assert.ok(new Attendance({ ...base, status: "Excused" }).validateSync());
  assert.ok(new Attendance({ status: "Present" }).validateSync());
  assert.ok(Attendance.schema.indexes().some(([keys, options]) =>
    options.unique &&
    keys.student === 1 &&
    keys.subject === 1 &&
    keys.batch === 1 &&
    keys.date === 1
  ));
});
