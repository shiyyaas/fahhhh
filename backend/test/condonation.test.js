const assert = require("node:assert/strict");
const { describe, test, beforeEach, afterEach } = require("node:test");
const stream = require("node:stream");
const Module = require("node:module");
const path = require("node:path");

process.env.JWT_SECRET = "condonation-test-suite-secret-key-32b";
process.env.LATE_AS = "present";

const ids = {
  hodCS: "111111111111111111111111",
  hodCommerce: "222222222222222222222222",
  studentCS_User: "333333333333333333333333",
  studentOther_User: "444444444444444444444444",
  studentZero_User: "555555555555555555555555",

  studentZero: "000000000000000000000000",
  student90: "aaaaaaaaaaaaaaaaaaaaaaaa",
  student75: "bbbbbbbbbbbbbbbbbbbbbbbb",
  student7499: "cccccccccccccccccccccccc",
  student60: "dddddddddddddddddddddddd",
  studentCommerce: "eeeeeeeeeeeeeeeeeeeeeeee",

  batchCS1: "ba0000000000000000000001",
  batchCS2: "ba0000000000000000000002",
  batchCommerce: "ba0000000000000000000003",

  deptCS: "de0000000000000000000001",
  deptCommerce: "de0000000000000000000002"
};

const users = {
  [ids.hodCS]: {
    _id: ids.hodCS,
    role: "HOD",
    department: "Computer Science",
    email: "hod.cs@college.test"
  },
  [ids.hodCommerce]: {
    _id: ids.hodCommerce,
    role: "HOD",
    department: "Commerce",
    email: "hod.comm@college.test"
  },
  [ids.studentCS_User]: {
    _id: ids.studentCS_User,
    role: "STUDENT",
    department: "Computer Science",
    email: "cs_student@college.test"
  },
  [ids.studentOther_User]: {
    _id: ids.studentOther_User,
    role: "STUDENT",
    department: "Commerce",
    email: "other_student@college.test"
  },
  [ids.studentZero_User]: {
    _id: ids.studentZero_User,
    role: "STUDENT",
    department: "Computer Science",
    email: "zero_student@college.test"
  }
};

const batches = {
  [ids.batchCS1]: {
    _id: ids.batchCS1,
    batchName: "BCA 2024-2027",
    department: "Computer Science"
  },
  [ids.batchCS2]: {
    _id: ids.batchCS2,
    batchName: "BSc CS 2024-2027",
    department: "Computer Science"
  },
  [ids.batchCommerce]: {
    _id: ids.batchCommerce,
    batchName: "BCom 2024-2027",
    department: "Commerce"
  }
};

const students = [
  {
    _id: ids.studentZero,
    studentName: "Student Zero Classes",
    registerNo: "REG-ZERO",
    department: "Computer Science",
    email: "zero_student@college.test",
    batchId: ids.batchCS1
  },
  {
    _id: ids.student90,
    studentName: "Student 90 Percent",
    registerNo: "REG-90",
    department: "Computer Science",
    email: "s90@college.test",
    batchId: ids.batchCS1
  },
  {
    _id: ids.student75,
    studentName: "Student 75 Percent",
    registerNo: "REG-75",
    department: "Computer Science",
    email: "s75@college.test",
    batchId: ids.batchCS1
  },
  {
    _id: ids.student7499,
    studentName: "Student 74.99 Percent",
    registerNo: "REG-7499",
    department: "Computer Science",
    email: "s7499@college.test",
    batchId: ids.batchCS1
  },
  {
    _id: ids.student60,
    studentName: "Student 60 Percent",
    registerNo: "REG-60",
    department: "Computer Science",
    email: "cs_student@college.test",
    batchId: ids.batchCS2
  },
  {
    _id: ids.studentCommerce,
    studentName: "Commerce Student",
    registerNo: "REG-COMM",
    department: "Commerce",
    email: "other_student@college.test",
    batchId: ids.batchCommerce
  }
];

let attendanceStatsMap = {};

const query = (value) => {
  const result = {
    select() { return result; },
    populate() { return result; },
    lean() { return Promise.resolve(value); },
    then(resolve, reject) {
      return Promise.resolve(value).then(resolve, reject);
    }
  };
  return result;
};

const mocks = {
  "../models/User": {
    findById(id) {
      return query(users[String(id)] || null);
    },
    findOne(filter) {
      const match = Object.values(users).find(
        (u) =>
          (!filter.email || u.email === filter.email) &&
          (!filter.role || u.role === filter.role)
      );
      return query(match || null);
    }
  },
  "../models/Student": {
    modelName: "Student",
    findById(id) {
      const s = students.find((item) => String(item._id) === String(id));
      if (!s) return query(null);
      const cloned = { ...s };
      if (cloned.batchId && batches[String(cloned.batchId)]) {
        cloned.batchId = { ...batches[String(cloned.batchId)] };
      }
      return query(cloned);
    },
    findOne(filter) {
      const s = students.find(
        (item) =>
          (!filter._id || String(item._id) === String(filter._id)) &&
          (!filter.email || item.email === filter.email)
      );
      return query(s ? { ...s } : null);
    },
    find(filter = {}) {
      let filtered = [...students];
      if (filter.department) {
        filtered = filtered.filter((s) => s.department === filter.department);
      }
      if (filter.batchId) {
        filtered = filtered.filter((s) => String(s.batchId) === String(filter.batchId));
      }
      if (filter.$or) {
        const regexes = filter.$or.map((cond) => cond.studentName || cond.registerNo);
        filtered = filtered.filter((s) =>
          regexes.some((reg) => reg.test(s.studentName) || reg.test(s.registerNo))
        );
      }
      const populated = filtered.map((s) => {
        const item = { ...s };
        if (item.batchId && batches[String(item.batchId)]) {
          item.batchId = { ...batches[String(item.batchId)] };
        }
        return item;
      });
      return query(populated);
    }
  },
  "../models/Batch": {
    modelName: "Batch",
    findById(id) {
      return query(batches[String(id)] || null);
    }
  },
  "../models/Department": {
    modelName: "Department",
    findOne(filter) {
      if (filter.departmentName === "Computer Science") {
        return query({ _id: ids.deptCS, departmentName: "Computer Science" });
      }
      if (filter.departmentName === "Commerce") {
        return query({ _id: ids.deptCommerce, departmentName: "Commerce" });
      }
      return query(null);
    }
  },
  "../models/Attendance": {
    async aggregate(pipeline) {
      const match = pipeline[0] && pipeline[0].$match;
      if (!match) return [];
      let sids = [];
      if (match.student && match.student.$in) {
        sids = match.student.$in.map(String);
      } else if (match.student) {
        sids = [String(match.student)];
      }
      return sids.map((sid) => {
        const stats = attendanceStatsMap[sid] || {
          totalClasses: 0,
          presentClasses: 0,
          lateClasses: 0,
          absentClasses: 0
        };
        return { _id: sid, ...stats };
      });
    },
    async find(filter) {
      const sid = String(filter.student);
      const stats = attendanceStatsMap[sid] || {
        totalClasses: 0,
        presentClasses: 0,
        lateClasses: 0,
        absentClasses: 0
      };
      const records = [];
      for (let i = 0; i < stats.presentClasses; i++) records.push({ status: "Present" });
      for (let i = 0; i < stats.lateClasses; i++) records.push({ status: "Late" });
      for (let i = 0; i < stats.absentClasses; i++) records.push({ status: "Absent" });
      return records;
    }
  }
};

const originalLoad = Module._load;
Module._load = function (request, parent, isMain) {
  if (
    parent &&
    (parent.filename.includes("condonationController") ||
      parent.filename.includes("ownership") ||
      parent.filename.includes("authMiddleware") ||
      parent.filename.includes("condonationRoutes")) &&
    mocks[request]
  ) {
    return mocks[request];
  }
  return originalLoad.call(this, request, parent, isMain);
};

const condonationController = require("../controllers/condonationController");
const condonationRoutes = require("../routes/condonationRoutes");
const { requireStudentOrHod } = require("../middleware/ownership");
const { authorizeRoles } = require("../middleware/authMiddleware");

class MockResponse extends stream.Writable {
  constructor() {
    super();
    this.statusCode = 200;
    this.headers = {};
    this.body = null;
    this.chunks = [];
  }
  _write(chunk, encoding, callback) {
    this.chunks.push(Buffer.from(chunk));
    callback();
  }
  status(code) {
    this.statusCode = code;
    return this;
  }
  setHeader(name, value) {
    this.headers[name.toLowerCase()] = value;
    return this;
  }
  json(body) {
    this.body = body;
    this.emit("finish");
    return this;
  }
  send(body) {
    this.body = body;
    this.emit("finish");
    return this;
  }
  getBuffer() {
    return Buffer.concat(this.chunks);
  }
  async waitForEnd() {
    return new Promise((resolve) => {
      this.on("finish", () => resolve(this.getBuffer()));
    });
  }
}

const createReq = ({ user, params = {}, query = {}, body = {} } = {}) => ({
  user,
  params,
  query,
  body
});

describe("Condonation Eligibility Backend Feature", () => {
  beforeEach(() => {
    process.env.LATE_AS = "present";
    attendanceStatsMap = {
      // 0. Zero classes: 0 total -> NO_ATTENDANCE_DATA
      [ids.studentZero]: { totalClasses: 0, presentClasses: 0, lateClasses: 0, absentClasses: 0 },
      // 1. Student at 90%: 90 present, 0 late, 10 absent, 100 total -> 90.00%
      [ids.student90]: { totalClasses: 100, presentClasses: 90, lateClasses: 0, absentClasses: 10 },
      // 2. Student at 75%: 75 present, 0 late, 25 absent, 100 total -> 75.00%
      [ids.student75]: { totalClasses: 100, presentClasses: 75, lateClasses: 0, absentClasses: 25 },
      // 3. Student at 74.99%: 7499 present, 0 late, 2501 absent, 10000 total -> 74.99%
      [ids.student7499]: { totalClasses: 10000, presentClasses: 7499, lateClasses: 0, absentClasses: 2501 },
      // 4. Student at 60%: 60 present, 0 late, 40 absent, 100 total -> 60.00%
      [ids.student60]: { totalClasses: 100, presentClasses: 60, lateClasses: 0, absentClasses: 40 },
      // Commerce student at 50%: 50 present, 50 absent -> 50.00%
      [ids.studentCommerce]: { totalClasses: 100, presentClasses: 50, lateClasses: 0, absentClasses: 50 }
    };
  });

  afterEach(() => {
    process.env.LATE_AS = "present";
  });

  test("0. Student with zero total classes: status is NO_ATTENDANCE_DATA and student is excluded from eligible lists and exports", async () => {
    // 0A: Individual student eligibility check for zero-attendance student
    const reqZero = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      params: { studentId: ids.studentZero }
    });
    const resZero = new MockResponse();
    await condonationController.getStudentEligibility(reqZero, resZero);

    assert.equal(resZero.statusCode, 200);
    assert.equal(resZero.body.success, true);
    assert.equal(resZero.body.student.totalClasses, 0);
    assert.equal(resZero.body.student.attendancePercentage, "0.00");
    assert.equal(resZero.body.student.eligibility, "NO_ATTENDANCE_DATA");

    // 0B: Student self-view authorization on their own zero-classes record
    const reqSelf = createReq({
      user: { userId: ids.studentZero_User, role: "STUDENT" },
      params: { studentId: ids.studentZero }
    });
    const resSelf = new MockResponse();
    await condonationController.getStudentEligibility(reqSelf, resSelf);
    assert.equal(resSelf.statusCode, 200);
    assert.equal(resSelf.body.success, true);
    assert.equal(resSelf.body.student.eligibility, "NO_ATTENDANCE_DATA");

    // 0C: Department eligible students list excludes zero-attendance students
    const reqEligible = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      query: {}
    });
    const resEligible = new MockResponse();
    await condonationController.getEligibleStudents(reqEligible, resEligible);
    assert.equal(resEligible.statusCode, 200);
    assert.ok(!resEligible.body.data.some((s) => s.studentId === ids.studentZero));
    assert.ok(!resEligible.body.data.some((s) => s.eligibility === "NO_ATTENDANCE_DATA"));

    // 0D: CSV export excludes zero-attendance students
    const resCSV = new MockResponse();
    await condonationController.exportEligibleCSV(reqEligible, resCSV);
    assert.equal(resCSV.statusCode, 200);
    assert.ok(!resCSV.body.includes(ids.studentZero));
    assert.ok(!resCSV.body.includes("NO_ATTENDANCE_DATA"));

    // 0E: PDF export excludes zero-attendance students
    const resPDF = new MockResponse();
    const pdfPromise = resPDF.waitForEnd();
    await condonationController.exportEligiblePDF(reqEligible, resPDF);
    const pdfBytes = await pdfPromise;
    assert.equal(resPDF.statusCode, 200);
    assert.ok(!pdfBytes.includes(Buffer.from("REG-ZERO")));
    assert.ok(!pdfBytes.includes(Buffer.from("NO_ATTENDANCE_DATA")));
  });

  test("0b. Unit tests for calculateEligibility: zero classes, below 75%, exactly 75%, and above 75%", () => {
    const { calculateEligibility } = condonationController;

    // Rule 1: totalClasses === 0 -> NO_ATTENDANCE_DATA
    assert.equal(calculateEligibility(0, "0.00"), "NO_ATTENDANCE_DATA");
    assert.equal(calculateEligibility(0, "60.00"), "NO_ATTENDANCE_DATA");
    assert.equal(calculateEligibility(0, "75.00"), "NO_ATTENDANCE_DATA");
    assert.equal(calculateEligibility(0, "90.00"), "NO_ATTENDANCE_DATA");
    assert.equal(calculateEligibility(null, "0.00"), "NO_ATTENDANCE_DATA");
    assert.equal(calculateEligibility(undefined, "0.00"), "NO_ATTENDANCE_DATA");

    // Rule 2: totalClasses > 0 and attendance percentage < 75 -> ELIGIBLE
    assert.equal(calculateEligibility(100, "0.00"), "ELIGIBLE");
    assert.equal(calculateEligibility(100, "50.00"), "ELIGIBLE");
    assert.equal(calculateEligibility(100, "60.00"), "ELIGIBLE");
    assert.equal(calculateEligibility(100, "74.99"), "ELIGIBLE");

    // Rule 3: Attendance percentage >= 75 -> NOT_ELIGIBLE
    assert.equal(calculateEligibility(100, "75.00"), "NOT_ELIGIBLE"); // exactly 75% boundary
    assert.equal(calculateEligibility(100, "75.01"), "NOT_ELIGIBLE");
    assert.equal(calculateEligibility(100, "90.00"), "NOT_ELIGIBLE"); // above 75%
    assert.equal(calculateEligibility(100, "100.00"), "NOT_ELIGIBLE");
  });

  test("1. Student at 90%: calculated attendance is 90.00% and status is NOT_ELIGIBLE", async () => {
    const req = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      params: { studentId: ids.student90 }
    });
    const res = new MockResponse();
    await condonationController.getStudentEligibility(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.student.attendancePercentage, "90.00");
    assert.equal(res.body.student.eligibility, "NOT_ELIGIBLE");
  });

  test("2. Student at 75%: exactly 75% is strictly NOT_ELIGIBLE (boundary test)", async () => {
    const req = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      params: { studentId: ids.student75 }
    });
    const res = new MockResponse();
    await condonationController.getStudentEligibility(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.student.attendancePercentage, "75.00");
    assert.equal(res.body.student.eligibility, "NOT_ELIGIBLE");
  });

  test("3. Student at 74.99%: attendance strictly below 75% is ELIGIBLE", async () => {
    const req = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      params: { studentId: ids.student7499 }
    });
    const res = new MockResponse();
    await condonationController.getStudentEligibility(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.student.attendancePercentage, "74.99");
    assert.equal(res.body.student.eligibility, "ELIGIBLE");
  });

  test("4. Student at 60%: attendance below 75% is ELIGIBLE", async () => {
    const req = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      params: { studentId: ids.student60 }
    });
    const res = new MockResponse();
    await condonationController.getStudentEligibility(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.student.attendancePercentage, "60.00");
    assert.equal(res.body.student.eligibility, "ELIGIBLE");
  });

  test("5. LATE_AS calculation behavior: evaluates present, partial (0.5), and absent policies", async () => {
    // 74 present, 2 late, 24 absent, total 100 classes
    attendanceStatsMap[ids.student60] = {
      totalClasses: 100,
      presentClasses: 74,
      lateClasses: 2,
      absentClasses: 24
    };

    // Policy 'present': (74 + 2) / 100 = 76.00% -> NOT_ELIGIBLE
    process.env.LATE_AS = "present";
    const reqPresent = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      params: { studentId: ids.student60 }
    });
    const resPresent = new MockResponse();
    await condonationController.getStudentEligibility(reqPresent, resPresent);
    assert.equal(resPresent.body.student.attendancePercentage, "76.00");
    assert.equal(resPresent.body.student.eligibility, "NOT_ELIGIBLE");

    // Policy 'partial': (74 + 2 * 0.5) / 100 = 75.00% -> NOT_ELIGIBLE (75% threshold)
    process.env.LATE_AS = "partial";
    const reqPartial = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      params: { studentId: ids.student60 }
    });
    const resPartial = new MockResponse();
    await condonationController.getStudentEligibility(reqPartial, resPartial);
    assert.equal(resPartial.body.student.attendancePercentage, "75.00");
    assert.equal(resPartial.body.student.eligibility, "NOT_ELIGIBLE");

    // Policy 'absent': 74 / 100 = 74.00% -> ELIGIBLE
    process.env.LATE_AS = "absent";
    const reqAbsent = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      params: { studentId: ids.student60 }
    });
    const resAbsent = new MockResponse();
    await condonationController.getStudentEligibility(reqAbsent, resAbsent);
    assert.equal(resAbsent.body.student.attendancePercentage, "74.00");
    assert.equal(resAbsent.body.student.eligibility, "ELIGIBLE");
  });

  test("6. HOD can see their own department's eligible students with search, batch filter, and sorting", async () => {
    // All 4 CS students evaluated: 90% (not eligible), 75% (not eligible), 74.99% (eligible), 60% (eligible)
    const req = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      query: { sort: "asc" }
    });
    const res = new MockResponse();
    await condonationController.getEligibleStudents(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.totalEligible, 2);
    assert.equal(res.body.data.length, 2);
    // Ascending sort: lowest attendance first (60.00% then 74.99%)
    assert.equal(res.body.data[0].studentId, ids.student60);
    assert.equal(res.body.data[0].attendancePercentage, "60.00");
    assert.equal(res.body.data[1].studentId, ids.student7499);
    assert.equal(res.body.data[1].attendancePercentage, "74.99");
    // All returned students must have eligibility === "ELIGIBLE"
    assert.ok(res.body.data.every((s) => s.eligibility === "ELIGIBLE"));
    assert.ok(res.body.data.every((s) => s.department === "Computer Science"));
    assert.ok(res.body.data.every((s) => s.totalClasses > 0));
    assert.ok(!res.body.data.some((s) => s.studentId === ids.studentZero));

    // Batch filtering
    const reqBatch = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      query: { batchId: ids.batchCS2 }
    });
    const resBatch = new MockResponse();
    await condonationController.getEligibleStudents(reqBatch, resBatch);
    assert.equal(resBatch.statusCode, 200);
    assert.equal(resBatch.body.totalEligible, 1);
    assert.equal(resBatch.body.data[0].studentId, ids.student60);

    // Search filter
    const reqSearch = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      query: { search: "7499" }
    });
    const resSearch = new MockResponse();
    await condonationController.getEligibleStudents(reqSearch, resSearch);
    assert.equal(resSearch.statusCode, 200);
    assert.equal(resSearch.body.totalEligible, 1);
    assert.equal(resSearch.body.data[0].studentId, ids.student7499);
  });

  test("7. HOD cannot access another department's records", async () => {
    // HOD of Commerce attempts to access CS student
    const reqCrossStudent = createReq({
      user: { userId: ids.hodCommerce, role: "HOD" },
      params: { studentId: ids.student60 }
    });
    const resCrossStudent = new MockResponse();
    await condonationController.getStudentEligibility(reqCrossStudent, resCrossStudent);
    assert.equal(resCrossStudent.statusCode, 403);
    assert.equal(resCrossStudent.body.message, "Forbidden");

    // HOD of CS attempts to query eligible students using a Commerce batchId
    const reqCrossBatch = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      query: { batchId: ids.batchCommerce }
    });
    const resCrossBatch = new MockResponse();
    await condonationController.getEligibleStudents(reqCrossBatch, resCrossBatch);
    assert.equal(resCrossBatch.statusCode, 403);
    assert.equal(resCrossBatch.body.message, "Forbidden");

    // Ownership middleware check: requireStudentOrHod
    let middlewareCalledNext = false;
    const middlewareReq = createReq({
      user: { userId: ids.hodCommerce, role: "HOD" },
      params: { studentId: ids.student60 }
    });
    const middlewareRes = new MockResponse();
    await requireStudentOrHod("studentId")(middlewareReq, middlewareRes, () => {
      middlewareCalledNext = true;
    });
    assert.equal(middlewareCalledNext, false);
    assert.equal(middlewareRes.statusCode, 403);
  });

  test("8. Empty eligible-student results: handles clean empty state when no students are < 75%", async () => {
    // Increase attendance for all CS students so none are below 75%
    attendanceStatsMap[ids.student7499] = { totalClasses: 100, presentClasses: 85, lateClasses: 0, absentClasses: 15 };
    attendanceStatsMap[ids.student60] = { totalClasses: 100, presentClasses: 95, lateClasses: 0, absentClasses: 5 };

    const req = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      query: {}
    });
    const res = new MockResponse();
    await condonationController.getEligibleStudents(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.totalEligible, 0);
    assert.deepEqual(res.body.data, []);

    // CSV export empty state
    const resCSV = new MockResponse();
    await condonationController.exportEligibleCSV(req, resCSV);
    assert.equal(resCSV.statusCode, 200);
    const lines = resCSV.body.trim().split("\r\n");
    // Only header row present
    assert.equal(lines.length, 1);
    assert.ok(lines[0].includes("Student ID"));

    // PDF export empty state
    const resPDF = new MockResponse();
    const pdfPromise = resPDF.waitForEnd();
    await condonationController.exportEligiblePDF(req, resPDF);
    const pdfBytes = await pdfPromise;
    assert.equal(resPDF.headers["content-type"], "application/pdf");
    assert.equal(pdfBytes.subarray(0, 4).toString(), "%PDF");
  });

  test("9. Student cannot access department-wide reports but can access their own record", async () => {
    // Check role authorization middleware rejects non-HOD roles for department reports
    let authNext = false;
    const studentAuthReq = createReq({
      user: { userId: ids.studentCS_User, role: "STUDENT" }
    });
    const studentAuthRes = new MockResponse();
    authorizeRoles("HOD")(studentAuthReq, studentAuthRes, () => {
      authNext = true;
    });
    assert.equal(authNext, false);
    assert.equal(studentAuthRes.statusCode, 403);

    // Student attempts to access another student's eligibility
    let otherStudentNext = false;
    const otherReq = createReq({
      user: { userId: ids.studentCS_User, role: "STUDENT" },
      params: { studentId: ids.student90 }
    });
    const otherRes = new MockResponse();
    await requireStudentOrHod("studentId")(otherReq, otherRes, () => {
      otherStudentNext = true;
    });
    assert.equal(otherStudentNext, false);
    assert.equal(otherRes.statusCode, 403);

    // Student accesses their OWN eligibility record
    let ownStudentNext = false;
    const ownReq = createReq({
      user: { userId: ids.studentCS_User, role: "STUDENT" },
      params: { studentId: ids.student60 }
    });
    const ownRes = new MockResponse();
    await requireStudentOrHod("studentId")(ownReq, ownRes, () => {
      ownStudentNext = true;
    });
    assert.equal(ownStudentNext, true);

    // Controller also verifies and returns the student's eligibility
    const controllerRes = new MockResponse();
    await condonationController.getStudentEligibility(ownReq, controllerRes);
    assert.equal(controllerRes.statusCode, 200);
    assert.equal(controllerRes.body.success, true);
    assert.equal(controllerRes.body.student.studentId, ids.student60);
    assert.equal(controllerRes.body.student.attendancePercentage, "60.00");
    assert.equal(controllerRes.body.student.eligibility, "ELIGIBLE");
  });

  test("10. CSV and PDF exports contain only authorized records with correct headers", async () => {
    const req = createReq({
      user: { userId: ids.hodCS, role: "HOD" },
      query: {}
    });

    // 10A: CSV Export
    const resCSV = new MockResponse();
    await condonationController.exportEligibleCSV(req, resCSV);

    assert.equal(resCSV.statusCode, 200);
    assert.equal(resCSV.headers["content-type"], "text/csv; charset=utf-8");
    assert.ok(resCSV.headers["content-disposition"].includes("condonation-eligible-students.csv"));

    // Check BOM for Excel compatibility
    assert.ok(resCSV.body.startsWith("\uFEFF"));

    const csvLines = resCSV.body.replace(/^\uFEFF/, "").trim().split("\r\n");
    // 1 header line + 2 eligible CS students
    assert.equal(csvLines.length, 3);
    assert.ok(csvLines[0].includes("Student ID"));
    assert.ok(csvLines[0].includes("Eligibility Status"));

    // Ensure Commerce student (50%), zero-classes student, and 90%/75% students are NOT in CSV
    assert.ok(resCSV.body.includes(ids.student60));
    assert.ok(resCSV.body.includes(ids.student7499));
    assert.ok(!resCSV.body.includes(ids.student90));
    assert.ok(!resCSV.body.includes(ids.student75));
    assert.ok(!resCSV.body.includes(ids.studentCommerce));
    assert.ok(!resCSV.body.includes(ids.studentZero));
    assert.ok(!resCSV.body.includes("NO_ATTENDANCE_DATA"));

    // 10B: PDF Export
    const resPDF = new MockResponse();
    const pdfPromise = resPDF.waitForEnd();
    await condonationController.exportEligiblePDF(req, resPDF);
    const pdfBytes = await pdfPromise;

    assert.equal(resPDF.statusCode, 200);
    assert.equal(resPDF.headers["content-type"], "application/pdf");
    assert.ok(resPDF.headers["content-disposition"].includes("condonation-eligible-report.pdf"));
    assert.ok(pdfBytes.length > 500);
    assert.equal(pdfBytes.subarray(0, 4).toString(), "%PDF");
    assert.ok(!pdfBytes.includes(Buffer.from("REG-ZERO")));
    assert.ok(!pdfBytes.includes(Buffer.from("Student Zero Classes")));
  });
});
