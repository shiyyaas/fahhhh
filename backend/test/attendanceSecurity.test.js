const assert = require("node:assert/strict");
const { after, before, test } = require("node:test");
const express = require("express");
const jwt = require("jsonwebtoken");
const Module = require("node:module");
const http = require("node:http");
const path = require("node:path");

process.env.JWT_SECRET = "attendance-security-test-secret";

const ids = {
  studentUser: "111111111111111111111111",
  teacherUser: "222222222222222222222222",
  student: "333333333333333333333333",
  otherStudent: "444444444444444444444444",
  teacher: "555555555555555555555555",
  otherTeacher: "666666666666666666666666",
  subject: "777777777777777777777777",
  batch: "888888888888888888888888",
  department: "999999999999999999999999",
  attendance: "aaaaaaaaaaaaaaaaaaaaaaaa",
  hodUser: "bbbbbbbbbbbbbbbbbbbbbbbb"
};

const profileEmail = {
  [ids.student]: "student@example.test",
  [ids.teacher]: "teacher@example.test"
};
const populated = {
  student: {
    _id: ids.student,
    studentName: "Test Student",
    registerNo: "TEST-001",
    department: "Test Department",
    password: "student-hash",
    aadhaarEncrypted: "sensitive",
    apaarId: "sensitive"
  },
  teacher: {
    _id: ids.teacher,
    teacherName: "Test Teacher",
    employeeId: "TEST-T1",
    password: "teacher-hash",
    email: "private@example.test"
  },
  subject: { _id: ids.subject, subjectName: "Test Subject", subjectCode: "TEST101" },
  batch: { _id: ids.batch, batchName: "Test Batch", department: "Test Department" }
};

let storedAttendance = {
  _id: ids.attendance,
  student: ids.student,
  subject: ids.subject,
  batch: ids.batch,
  teacher: ids.otherTeacher,
  status: "Present",
  date: new Date("2026-01-01T10:00:00Z")
};
const populateSelections = [];

const query = (value) => {
  const result = {
    select: () => result,
    limit: () => result,
    populate: () => result,
    then: (resolve, reject) => Promise.resolve(value).then(resolve, reject)
  };
  return result;
};

const mocks = {
  "../models/Attendance": {
    find: () => {
      let result = [{ ...storedAttendance }];
      const chain = {
        populate(options) {
          populateSelections.push(options);
          const value = populated[options.path];
          const fields = options.select.split(/\s+/);
          const safeValue = Object.fromEntries(
            Object.entries(value).filter(([field]) => fields.includes(field))
          );
          result = result.map((record) => ({ ...record, [options.path]: safeValue }));
          return chain;
        },
        then(resolve, reject) {
          return Promise.resolve(result).then(resolve, reject);
        }
      };
      return chain;
    },
    findById: async () => ({ ...storedAttendance }),
    findByIdAndDelete: async () => {
      const deleted = { ...storedAttendance };
      storedAttendance = null;
      return deleted;
    },
    findOneAndUpdate: async (filter, update) => ({ ...filter, ...update }),
    countDocuments: async () => 0,
    aggregate: async () => []
  },
  "../models/Student": {
    modelName: "Student",
    find: (filter) => {
      const emailPattern = filter.email;
      if (!emailPattern) return query([]);
      const id = Object.keys(profileEmail).find((key) => emailPattern.test(profileEmail[key]));
      return query(id ? [{ _id: id }] : []);
    },
    findById: (id) => query(
      id === ids.student
        ? { _id: ids.student, batchId: ids.batch, department: "Test Department" }
        : id === ids.otherStudent
          ? { _id: ids.otherStudent, batchId: ids.batch, department: "Other Department" }
          : null
    ),
    findOne: (filter) => query(
      filter.email === "student@example.test"
        ? { _id: ids.student, batchId: ids.batch, department: "Test Department" }
        : null
    )
  },
  "../models/Teacher": {
    modelName: "Teacher",
    find: (filter) => query(
      filter.email.test(profileEmail[ids.teacher])
        ? [{ _id: ids.teacher, departments: [ids.department] }]
        : []
    ),
    findOne: (filter) => query(
      filter.email === "teacher@example.test"
        ? { _id: ids.teacher, departments: [ids.department] }
        : null
    )
  },
  "../models/User": {
    findOne: (filter) => query({
      _id: filter._id,
      role: filter.role,
      email: filter.role === "STUDENT" ? profileEmail[ids.student] : profileEmail[ids.teacher]
    }),
    findById: (id) => query(
      id === ids.studentUser
        ? { _id: ids.studentUser, role: "STUDENT", email: profileEmail[ids.student], isActive: true }
        : id === ids.teacherUser
          ? { _id: ids.teacherUser, role: "TEACHER", email: profileEmail[ids.teacher], isActive: true }
          : { _id: ids.hodUser, role: "HOD", department: "Test Department", isActive: true }
    )
  },
  "../models/Subject": {
    modelName: "Subject",
    findOne: (filter) => query(
      filter._id === ids.subject && filter.teachers === ids.teacher
        ? { _id: ids.subject, departments: [ids.department] }
        : null
    ),
    findById: () => query({ _id: ids.subject, departments: [ids.department] })
  },
  "../models/Batch": {
    modelName: "Batch",
    findById: () => query({ _id: ids.batch, department: "Test Department" }),
    find: () => query([{ _id: ids.batch }])
  },
  "../models/Department": {
    modelName: "Department",
    exists: async () => true,
    find: () => query([{ departmentName: "Test Department" }]),
    findOne: () => query({ _id: ids.department, departmentName: "Test Department" })
  }
};

const originalLoad = Module._load;
Module._load = function(request, parent, isMain) {
  if (
    parent &&
    (parent.filename.endsWith(`${path.sep}controllers${path.sep}attendanceController.js`) ||
      parent.filename.endsWith(`${path.sep}middleware${path.sep}ownership.js`) ||
    parent.filename.endsWith(`${path.sep}middleware${path.sep}authMiddleware.js`) ||
    parent.filename.endsWith(`${path.sep}routes${path.sep}attendanceRoutes.js`)) &&
    mocks[request]
  ) {
    return mocks[request];
  }
  return originalLoad.call(this, request, parent, isMain);
};

const attendanceRoutes = require("../routes/attendanceRoutes");
Module._load = originalLoad;

const app = express();
app.use(express.json());
app.use("/api/attendance", attendanceRoutes);
let server;
let baseUrl;

const token = (userId, role) =>
  jwt.sign({ userId, role }, process.env.JWT_SECRET, { expiresIn: "1m" });

const request = (path, role, userId, options = {}) =>
  fetch(`${baseUrl}/api/attendance${path}`, {
    ...options,
    headers: {
      ...(options.body ? { "content-type": "application/json" } : {}),
      ...(role ? { authorization: `Bearer ${token(userId, role)}` } : {}),
      ...options.headers
    }
  });

before(async () => {
  server = http.createServer(app);
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  await new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
});

test("attendance endpoints reject missing and invalid JWTs", async () => {
  const missing = await fetch(`${baseUrl}/api/attendance/student/${ids.student}`);
  assert.equal(missing.status, 401);

  const invalid = await fetch(`${baseUrl}/api/attendance/student/${ids.student}`, {
    headers: { authorization: "Bearer not-a-valid-token" }
  });
  assert.equal(invalid.status, 401);
});

test("student can access only their own attendance, percentage, and report", async () => {
  const own = await request(`/student/${ids.student}`, "STUDENT", ids.studentUser);
  assert.equal(own.status, 200);

  const ownPercentage = await request(`/percentage/${ids.student}`, "STUDENT", ids.studentUser);
  assert.equal(ownPercentage.status, 200);

  const ownReport = await request(`/report/student/${ids.student}`, "STUDENT", ids.studentUser);
  assert.equal(ownReport.status, 200);

  for (const endpoint of [
    `/student/${ids.otherStudent}`,
    `/percentage/${ids.otherStudent}`,
    `/report/student/${ids.otherStudent}`
  ]) {
    const other = await request(endpoint, "STUDENT", ids.studentUser);
    assert.equal(other.status, 403);
  }
});

test("student role cannot modify or delete attendance", async () => {
  const update = await request(`/update/${ids.attendance}`, "STUDENT", ids.studentUser, {
    method: "PUT",
    body: JSON.stringify({ status: "Absent" })
  });
  assert.equal(update.status, 403);

  const remove = await request(`/delete/${ids.attendance}`, "STUDENT", ids.studentUser, {
    method: "DELETE"
  });
  assert.equal(remove.status, 403);
});

test("teacher cannot mark attendance for an unassigned subject", async () => {
  const result = await request("/mark", "TEACHER", ids.teacherUser, {
    method: "POST",
    body: JSON.stringify({
      student: ids.student,
      subject: "unassigned-subject",
      batch: ids.batch,
      status: "Present",
      teacher: ids.otherTeacher
    })
  });
  assert.equal(result.status, 403);
});

test("authorized teacher mark uses the authenticated teacher profile", async () => {
  const result = await request("/mark", "TEACHER", ids.teacherUser, {
    method: "POST",
    body: JSON.stringify({
      student: ids.student,
      subject: ids.subject,
      batch: ids.batch,
      status: "Present",
      teacher: ids.otherTeacher
    })
  });
  assert.equal(result.status, 200);
  const body = await result.json();
  assert.equal(body.attendance.teacher, ids.teacher);
});

test("teacher cannot update or delete another teacher's attendance", async () => {
  const update = await request(`/update/${ids.attendance}`, "TEACHER", ids.teacherUser, {
    method: "PUT",
    body: JSON.stringify({ status: "Absent" })
  });
  assert.equal(update.status, 403);

  const remove = await request(`/delete/${ids.attendance}`, "TEACHER", ids.teacherUser, {
    method: "DELETE"
  });
  assert.equal(remove.status, 403);
});

test("teacher cannot read attendance for an unassigned subject", async () => {
  const result = await request("/subject/unassigned-subject", "TEACHER", ids.teacherUser);
  assert.equal(result.status, 403);
});

test("teacher can read assigned subject attendance but cannot read batch attendance", async () => {
  const assignedSubject = await request(`/subject/${ids.subject}`, "TEACHER", ids.teacherUser);
  assert.equal(assignedSubject.status, 200);

  const batchAttendance = await request(`/batch/${ids.batch}`, "TEACHER", ids.teacherUser);
  assert.equal(batchAttendance.status, 403);

  const defaulters = await request("/defaulters", "TEACHER", ids.teacherUser);
  assert.equal(defaulters.status, 403);
});

test("bulk attendance marking is not an implemented API endpoint", async () => {
  const result = await request("/mark/bulk", "TEACHER", ids.teacherUser, {
    method: "POST",
    body: JSON.stringify({ records: [] })
  });
  assert.equal(result.status, 404);
});

test("attendance population excludes authentication and sensitive identity fields", async () => {
  for (const endpoint of [
    `/student/${ids.student}`,
    `/batch/${ids.batch}`,
    `/subject/${ids.subject}`
  ]) {
    const result = await request(endpoint, "HOD", ids.hodUser);
    assert.equal(result.status, 200);
    const body = await result.json();
    const record = body.attendance[0];
    assert.ok(record);
    assert.equal("password" in record.student, false);
    assert.equal("aadhaarEncrypted" in record.student, false);
    assert.equal("apaarId" in record.student, false);
    assert.equal("password" in record.teacher, false);
    assert.equal("email" in record.teacher, false);
  }

  assert.ok(populateSelections.length >= 12);
});
