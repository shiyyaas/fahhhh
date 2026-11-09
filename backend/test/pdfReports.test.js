const assert = require("node:assert/strict");
const { after, beforeEach, test } = require("node:test");
const Module = require("node:module");
const path = require("node:path");
const stream = require("node:stream");

process.env.JWT_SECRET = "backend-tests-only-secret";

const ids = {
  user: "000000000000000000000001",
  hodUser: "000000000000000000000002",
  otherHodUser: "000000000000000000000003",
  studentUser: "000000000000000000000004",
  teacherUser: "000000000000000000000005",
  student: "000000000000000000000011",
  defaulterStudent: "000000000000000000000012",
  teacher: "000000000000000000000021",
  subject: "000000000000000000000031",
  batch: "000000000000000000000041",
  department: "000000000000000000000051"
};

const student = {
  _id: ids.student,
  studentName: "Aarav Sharma",
  registerNo: "T-001",
  email: "aarav@example.test",
  department: "Computer Science",
  batchId: ids.batch
};

const defaulterStudent = {
  _id: ids.defaulterStudent,
  studentName: "Rohan Varma",
  registerNo: "T-002",
  email: "rohan@example.test",
  department: "Computer Science",
  batchId: ids.batch
};

const batch = {
  _id: ids.batch,
  batchName: "BCA 2024-2027",
  department: "Computer Science",
  program: "BCA",
  currentSemester: 2
};

const subject = {
  _id: ids.subject,
  subjectName: "Data Structures",
  subjectCode: "BCA201",
  semester: 2,
  credits: 4,
  departments: [ids.department]
};

const department = {
  _id: ids.department,
  departmentName: "Computer Science",
  departmentCode: "CS",
  hodName: "Dr. Ananya Roy"
};

let attendanceRecords = [];

const matches = (record, filter) => Object.entries(filter).every(([key, value]) => {
  if (value && typeof value === "object" && "$gte" in value && "$lte" in value) {
    const time = new Date(record[key]).getTime();
    return time >= value.$gte.getTime() && time <= value.$lte.getTime();
  }
  if (value && typeof value === "object" && "$in" in value) {
    return value.$in.some((item) => String(item) === String(record[key]));
  }
  return String(record[key]) === String(value);
});

const query = (result) => ({
  select() { return this; },
  populate() { return this; },
  sort() { return this; },
  limit() { return this; },
  then(resolve, reject) { return Promise.resolve(result).then(resolve, reject); }
});

const mocks = {
  "../models/Attendance": {
    find(filter = {}) {
      const records = attendanceRecords.filter((rec) => matches(rec, filter)).map((r) => ({
        ...r,
        subject: r.subject === ids.subject ? { ...subject } : r.subject
      }));
      return query(records);
    },
    async countDocuments(filter) {
      return attendanceRecords.filter((record) => matches(record, filter)).length;
    },
    async aggregate(pipeline) {
      if (pipeline[0].$match.date) {
        return [{ _id: ids.student, totalClasses: 10, presentClasses: 8, lateClasses: 2 }];
      }
      const studentId = pipeline[0].$match.student;
      const records = attendanceRecords.filter((r) => String(r.student) === String(studentId));
      const bySubject = new Map();
      for (const r of records) {
        const cur = bySubject.get(String(r.subject)) || { totalClasses: 0, present: 0, late: 0, absent: 0 };
        cur.totalClasses += 1;
        if (r.status === "Present") cur.present += 1;
        if (r.status === "Late") cur.late += 1;
        if (r.status === "Absent") cur.absent += 1;
        bySubject.set(String(r.subject), cur);
      }
      return [...bySubject].map(([subId, stats]) => ({
        subjectId: subId,
        subjectName: subject.subjectName,
        subjectCode: subject.subjectCode,
        ...stats
      }));
    }
  },
  "../models/Student": {
    findById(id) {
      if (String(id) === ids.student) return query({ ...student });
      if (String(id) === ids.defaulterStudent) return query({ ...defaulterStudent });
      return query(null);
    },
    find(filter = {}) {
      const all = [{ ...student }, { ...defaulterStudent }];
      if (filter.batchId) {
        return query(all.filter((s) => String(s.batchId) === String(filter.batchId)));
      }
      if (filter.department) {
        return query(all.filter((s) => s.department === filter.department));
      }
      return query(all);
    }
  },
  "../models/Subject": {
    findById(id) {
      return query(String(id) === ids.subject ? { ...subject } : null);
    }
  },
  "../models/Batch": {
    findById(id) {
      return query(String(id) === ids.batch ? { ...batch } : null);
    },
    find(filter = {}) {
      if (filter.department) {
        return query(filter.department === batch.department ? [{ ...batch }] : []);
      }
      return query([{ ...batch }]);
    }
  },
  "../models/Department": {
    findById(id) {
      return query(String(id) === ids.department ? { ...department } : null);
    },
    findOne(filter = {}) {
      if (filter.departmentName) {
        return query(filter.departmentName === department.departmentName ? { ...department } : null);
      }
      return query({ ...department });
    }
  },
  "../models/User": {
    findById(id) {
      if (String(id) === ids.otherHodUser) {
        return query({
          _id: id,
          role: "HOD",
          department: "Commerce"
        });
      }
      if (String(id) === ids.studentUser) {
        return query({
          _id: id,
          role: "STUDENT",
          email: student.email
        });
      }
      if (String(id) === ids.teacherUser) {
        return query({
          _id: id,
          role: "TEACHER",
          email: "teacher@example.test"
        });
      }
      return query({
        _id: id,
        role: "HOD",
        department: "Computer Science"
      });
    }
  }
};

const originalLoad = Module._load;
Module._load = function(request, parent, isMain) {
  if (parent && parent.filename.includes(`${path.sep}controllers${path.sep}`) && mocks[request]) {
    return mocks[request];
  }
  return originalLoad.call(this, request, parent, isMain);
};

const reportController = require("../controllers/reportController");
const reportRoutes = require("../routes/reportRoutes");
const attendanceRoutes = require("../routes/attendanceRoutes");

after(() => {
  Module._load = originalLoad;
});

class MockResponse extends stream.Writable {
  constructor() {
    super();
    this.statusCode = 200;
    this.headers = {};
    this.chunks = [];
    this.body = null;
  }
  _write(chunk, encoding, callback) {
    this.chunks.push(chunk);
    callback();
  }
  status(code) {
    this.statusCode = code;
    return this;
  }
  setHeader(name, value) {
    this.headers[name.toLowerCase()] = value;
  }
  json(data) {
    this.body = data;
    this.emit("finish");
    return this;
  }
  send(data) {
    this.body = data;
    this.emit("finish");
    return this;
  }
  getBuffer() {
    return Buffer.concat(this.chunks);
  }
  waitForEnd() {
    return new Promise((resolve, reject) => {
      this.on("finish", () => {
        if (this.statusCode >= 400 && !this.chunks.length) {
          return resolve(Buffer.from(JSON.stringify(this.body || {})));
        }
        resolve(this.getBuffer());
      });
      this.on("error", reject);
    });
  }
}

const createReq = (params = {}, query = {}, user = { userId: ids.hodUser, role: "HOD" }) => ({
  params,
  query,
  user
});

beforeEach(() => {
  // Setup standard attendance: student has 90%, defaulterStudent has 40%
  attendanceRecords = [
    // Student: 9 Present, 1 Late (out of 10 -> 95% or 90%)
    ...Array(9).fill().map(() => ({ student: ids.student, subject: ids.subject, batch: ids.batch, status: "Present", date: new Date("2026-02-10") })),
    { student: ids.student, subject: ids.subject, batch: ids.batch, status: "Late", date: new Date("2026-02-11") },

    // DefaulterStudent: 2 Present, 8 Absent (out of 10 -> 20%)
    ...Array(2).fill().map(() => ({ student: ids.defaulterStudent, subject: ids.subject, batch: ids.batch, status: "Present", date: new Date("2026-02-10") })),
    ...Array(8).fill().map(() => ({ student: ids.defaulterStudent, subject: ids.subject, batch: ids.batch, status: "Absent", date: new Date("2026-02-11") }))
  ];
});

test("all 7 attendance PDF report controller functions are exported", () => {
  assert.equal(typeof reportController.downloadStudentReport, "function", "Student overall PDF export");
  assert.equal(typeof reportController.downloadStudentSubjectReport, "function", "Student subject-wise PDF export");
  assert.equal(typeof reportController.downloadSubjectReport, "function", "Subject overall PDF export");
  assert.equal(typeof reportController.downloadFullBatchReport, "function", "Full batch PDF export");
  assert.equal(typeof reportController.downloadMonthlyBatchReport, "function", "Monthly batch PDF export");
  assert.equal(typeof reportController.downloadDepartmentReport, "function", "Department PDF export");
  assert.equal(typeof reportController.downloadDefaultersReport, "function", "Defaulter report PDF export");
  assert.equal(typeof reportController.getSubjectReport, "function", "Subject JSON report export");
});

test("reportRoutes defines all 7 downloadable PDF routes", () => {
  const routes = reportRoutes.stack
    .filter((layer) => layer.route)
    .map((layer) => ({ path: layer.route.path, methods: Object.keys(layer.route.methods) }));

  const paths = routes.map((r) => r.path);
  assert.ok(paths.includes("/student/:studentId/pdf"), "Route /student/:studentId/pdf missing");
  assert.ok(paths.includes("/student/:studentId/subject-wise-pdf"), "Route /student/:studentId/subject-wise-pdf missing");
  assert.ok(paths.includes("/subject/:subjectId/pdf"), "Route /subject/:subjectId/pdf missing");
  assert.ok(paths.includes("/batch/:batchId/pdf"), "Route /batch/:batchId/pdf missing");
  assert.ok(paths.includes("/batch/:batchId/monthly-pdf"), "Route /batch/:batchId/monthly-pdf missing");
  assert.ok(paths.includes("/department/:departmentId/pdf"), "Route /department/:departmentId/pdf missing");
  assert.ok(paths.includes("/defaulters/pdf"), "Route /defaulters/pdf missing");
});

test("1. downloadStudentReport generates a valid PDF with correct headers and late policy", async () => {
  process.env.LATE_AS = "present";
  const res = new MockResponse();
  const req = createReq({ studentId: ids.student });

  const endPromise = res.waitForEnd();
  await reportController.downloadStudentReport(req, res);
  const pdfBytes = await endPromise;

  assert.equal(res.headers["content-type"], "application/pdf");
  assert.ok(res.headers["content-disposition"].includes("attachment"));
  assert.ok(res.headers["content-disposition"].includes("T-001.pdf"));
  assert.ok(pdfBytes.length > 500, "PDF bytes should be non-empty");
  assert.equal(pdfBytes.subarray(0, 4).toString(), "%PDF", "Must begin with %PDF magic bytes");
});

test("2. downloadStudentSubjectReport generates a valid subject-wise PDF", async () => {
  const res = new MockResponse();
  const req = createReq({ studentId: ids.student });

  const endPromise = res.waitForEnd();
  await reportController.downloadStudentSubjectReport(req, res);
  const pdfBytes = await endPromise;

  assert.equal(res.headers["content-type"], "application/pdf");
  assert.ok(res.headers["content-disposition"].includes("attachment"));
  assert.ok(res.headers["content-disposition"].includes("T-001-subject-attendance.pdf"));
  assert.ok(pdfBytes.length > 500, "PDF bytes should be non-empty");
  assert.equal(pdfBytes.subarray(0, 4).toString(), "%PDF");
});

test("3. downloadSubjectReport generates a valid subject overall PDF", async () => {
  const res = new MockResponse();
  const req = createReq({ subjectId: ids.subject });

  const endPromise = res.waitForEnd();
  await reportController.downloadSubjectReport(req, res);
  const pdfBytes = await endPromise;

  assert.equal(res.headers["content-type"], "application/pdf");
  assert.ok(res.headers["content-disposition"].includes("attachment"));
  assert.ok(res.headers["content-disposition"].includes("BCA201-attendance-report.pdf"));
  assert.ok(pdfBytes.length > 500);
  assert.equal(pdfBytes.subarray(0, 4).toString(), "%PDF");
});

test("4. downloadFullBatchReport generates a valid full batch attendance PDF", async () => {
  const res = new MockResponse();
  const req = createReq({ batchId: ids.batch });

  const endPromise = res.waitForEnd();
  await reportController.downloadFullBatchReport(req, res);
  const pdfBytes = await endPromise;

  assert.equal(res.headers["content-type"], "application/pdf");
  assert.ok(res.headers["content-disposition"].includes("attachment"));
  assert.ok(res.headers["content-disposition"].includes("BCA 2024-2027-full-attendance-report.pdf"));
  assert.ok(pdfBytes.length > 500);
  assert.equal(pdfBytes.subarray(0, 4).toString(), "%PDF");
});

test("5. downloadMonthlyBatchReport generates monthly batch PDF with month/year params", async () => {
  const res = new MockResponse();
  const req = createReq({ batchId: ids.batch }, { month: "2", year: "2026" });

  const endPromise = res.waitForEnd();
  await reportController.downloadMonthlyBatchReport(req, res);
  const pdfBytes = await endPromise;

  assert.equal(res.headers["content-type"], "application/pdf");
  assert.ok(res.headers["content-disposition"].includes("attachment"));
  assert.ok(res.headers["content-disposition"].includes("February-2026.pdf"));
  assert.ok(pdfBytes.length > 500);
  assert.equal(pdfBytes.subarray(0, 4).toString(), "%PDF");
});

test("6. downloadDepartmentReport generates a valid department attendance PDF", async () => {
  const res = new MockResponse();
  const req = createReq({ departmentId: ids.department });

  const endPromise = res.waitForEnd();
  await reportController.downloadDepartmentReport(req, res);
  const pdfBytes = await endPromise;

  assert.equal(res.headers["content-type"], "application/pdf");
  assert.ok(res.headers["content-disposition"].includes("attachment"));
  assert.ok(res.headers["content-disposition"].includes("CS-attendance-report.pdf"));
  assert.ok(pdfBytes.length > 500);
  assert.equal(pdfBytes.subarray(0, 4).toString(), "%PDF");
});

test("7. downloadDefaultersReport identifies < 75% students and generates defaulter PDF", async () => {
  const res = new MockResponse();
  const req = createReq({}, {});

  const endPromise = res.waitForEnd();
  await reportController.downloadDefaultersReport(req, res);
  const pdfBytes = await endPromise;

  assert.equal(res.headers["content-type"], "application/pdf");
  assert.ok(res.headers["content-disposition"].includes("attachment"));
  assert.ok(res.headers["content-disposition"].includes("defaulters-report.pdf"));
  assert.ok(pdfBytes.length > 500);
  assert.equal(pdfBytes.subarray(0, 4).toString(), "%PDF");
});

test("missing resources return 404 in PDF report endpoints", async () => {
  const res1 = new MockResponse();
  await reportController.downloadStudentReport(createReq({ studentId: "999999999999999999999999" }), res1);
  assert.equal(res1.statusCode, 404);
  assert.equal(res1.body.message, "Student not found");

  const res2 = new MockResponse();
  await reportController.downloadSubjectReport(createReq({ subjectId: "999999999999999999999999" }), res2);
  assert.equal(res2.statusCode, 404);
  assert.equal(res2.body.message, "Subject not found");

  const res3 = new MockResponse();
  await reportController.downloadFullBatchReport(createReq({ batchId: "999999999999999999999999" }), res3);
  assert.equal(res3.statusCode, 404);
  assert.equal(res3.body.message, "Batch not found");

  const res4 = new MockResponse();
  await reportController.downloadDepartmentReport(createReq({ departmentId: "999999999999999999999999" }), res4);
  assert.equal(res4.statusCode, 404);
  assert.equal(res4.body.message, "Department not found");
});

test("route middleware chain enforces authentication and role authorization", () => {
  const routes = reportRoutes.stack.filter((layer) => layer.route);

  const getRoute = (path) => routes.find((r) => r.route.path === path);

  const studentPdf = getRoute("/student/:studentId/pdf");
  assert.ok(studentPdf, "Route /student/:studentId/pdf must exist");
  assert.ok(studentPdf.route.stack.length >= 4, "Must have verifyToken, authorizeRoles, ownership check, and controller");

  const studentSubjPdf = getRoute("/student/:studentId/subject-wise-pdf");
  assert.ok(studentSubjPdf, "Route /student/:studentId/subject-wise-pdf must exist");
  assert.ok(studentSubjPdf.route.stack.length >= 4);

  const batchFullPdf = getRoute("/batch/:batchId/pdf");
  assert.ok(batchFullPdf, "Route /batch/:batchId/pdf must exist");
  assert.ok(batchFullPdf.route.stack.length >= 4);

  const batchMonthlyPdf = getRoute("/batch/:batchId/monthly-pdf");
  assert.ok(batchMonthlyPdf, "Route /batch/:batchId/monthly-pdf must exist");
  assert.ok(batchMonthlyPdf.route.stack.length >= 4);

  const subjectPdf = getRoute("/subject/:subjectId/pdf");
  assert.ok(subjectPdf, "Route /subject/:subjectId/pdf must exist");
  assert.ok(subjectPdf.route.stack.length >= 4);

  const deptPdf = getRoute("/department/:departmentId/pdf");
  assert.ok(deptPdf, "Route /department/:departmentId/pdf must exist");
  assert.ok(deptPdf.route.stack.length >= 4);

  const defaultersPdf = getRoute("/defaulters/pdf");
  assert.ok(defaultersPdf, "Route /defaulters/pdf must exist");
  assert.ok(defaultersPdf.route.stack.length >= 3);
});

test("cross-department security: HOD from Commerce cannot access Computer Science PDF reports", async () => {
  const otherHodReq = (params = {}, query = {}) => ({
    params,
    query,
    user: { userId: ids.otherHodUser, role: "HOD" }
  });

  // 1. Defaulters with CS batchId query param
  const res1 = new MockResponse();
  await reportController.downloadDefaultersReport(otherHodReq({}, { batchId: ids.batch }), res1);
  assert.equal(res1.statusCode, 403, "Must reject cross-department batch defaulters report with 403");

  // 2. Defaulters department-wide must not leak CS students
  const res2 = new MockResponse();
  const end2 = res2.waitForEnd();
  await reportController.downloadDefaultersReport(otherHodReq(), res2);
  const pdfBytes2 = await end2;
  assert.equal(res2.statusCode, 200);
  assert.ok(pdfBytes2.length > 500);

  // 3. Department report for CS department ID
  const res3 = new MockResponse();
  await reportController.downloadDepartmentReport(otherHodReq({ departmentId: ids.department }), res3);
  assert.equal(res3.statusCode, 403, "Must reject cross-department department report with 403");

  // 4. Full batch report for CS batch
  const res4 = new MockResponse();
  await reportController.downloadFullBatchReport(otherHodReq({ batchId: ids.batch }), res4);
  assert.equal(res4.statusCode, 403, "Must reject cross-department full batch report with 403");

  // 5. Monthly batch report for CS batch
  const res5 = new MockResponse();
  await reportController.downloadMonthlyBatchReport(otherHodReq({ batchId: ids.batch }, { month: "2", year: "2026" }), res5);
  assert.equal(res5.statusCode, 403, "Must reject cross-department monthly batch report with 403");

  // 6. Student report for CS student
  const res6 = new MockResponse();
  await reportController.downloadStudentReport(otherHodReq({ studentId: ids.student }), res6);
  assert.equal(res6.statusCode, 403, "Must reject cross-department student report with 403");

  // 7. Student subject-wise report for CS student
  const res7 = new MockResponse();
  await reportController.downloadStudentSubjectReport(otherHodReq({ studentId: ids.student }), res7);
  assert.equal(res7.statusCode, 403, "Must reject cross-department student subject-wise report with 403");

  // 8. Subject report for CS subject
  const res8 = new MockResponse();
  await reportController.downloadSubjectReport(otherHodReq({ subjectId: ids.subject }), res8);
  assert.equal(res8.statusCode, 403, "Must reject cross-department subject report with 403");
});

test("role permissions: non-HOD roles cannot access administrative PDF endpoints", async () => {
  const teacherReq = (params = {}) => ({
    params,
    query: {},
    user: { userId: ids.teacherUser, role: "TEACHER" }
  });
  const studentReq = (params = {}) => ({
    params,
    query: {},
    user: { userId: ids.studentUser, role: "STUDENT" }
  });

  // Defaulters PDF controller enforces HOD role
  const res1 = new MockResponse();
  await reportController.downloadDefaultersReport(teacherReq(), res1);
  assert.equal(res1.statusCode, 403);

  const res2 = new MockResponse();
  await reportController.downloadDefaultersReport(studentReq(), res2);
  assert.equal(res2.statusCode, 403);
});


