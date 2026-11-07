const assert = require("node:assert/strict");
const { test } = require("node:test");
const Department = require("../models/Department");
const User = require("../models/User");
const Teacher = require("../models/Teacher");
const Student = require("../models/Student");
const Batch = require("../models/Batch");
const Subject = require("../models/Subject");
const { getDepartments, getDepartment } = require("../controllers/departmentController");
const { getSubjects, getSubject } = require("../controllers/subjectController");
const { requireOwnStudentBatchOrHod } = require("../middleware/ownership");

const ids = {
    user: "111111111111111111111111",
    north: "aaaaaaaaaaaaaaaaaaaaaaaa",
    south: "bbbbbbbbbbbbbbbbbbbbbbbb",
    teacher: "cccccccccccccccccccccccc",
    student: "dddddddddddddddddddddddd",
    batch: "eeeeeeeeeeeeeeeeeeeeeeee",
    otherBatch: "ffffffffffffffffffffffff",
    assignedSubject: "999999999999999999999999",
    unassignedSubject: "888888888888888888888888"
};

const departments = [
    { _id: ids.north, departmentName: "North" },
    { _id: ids.south, departmentName: "South" }
];

const query = (value) => {
    const result = {
        select() { return result; },
        sort() { return result; },
        populate() { return result; },
        then(resolve, reject) {
            return Promise.resolve(value).then(resolve, reject);
        }
    };
    return result;
};

const response = () => ({
    statusCode: 0,
    status(code) {
        this.statusCode = code;
        return this;
    },
    json(body) {
        this.body = body;
        return this;
    }
});

const installMocks = (t, { user, teacher = null, student = null, batch = null }) => {
    const departmentFindFilters = [];
    const subjectFindFilters = [];
    const subjectFindOneFilters = [];
    const studentFindOneFilters = [];
    const batchFindOneFilters = [];

    t.mock.method(User, "findById", () => query(user));
    t.mock.method(Department, "findOne", (filter) => query(
        departments.find((department) => department.departmentName === filter.departmentName) || null
    ));
    t.mock.method(Department, "find", (filter) => {
        departmentFindFilters.push(filter);
        const allowedIds = filter && filter._id && filter._id.$in || [];
        return query(departments.filter((department) =>
            allowedIds.some((id) => String(id) === String(department._id))
        ));
    });
    t.mock.method(Department, "findById", (id) => query(
        departments.find((department) => String(department._id) === String(id)) || null
    ));
    t.mock.method(Teacher, "findOne", (filter) => query(
        teacher && teacher.email === filter.email ? teacher : null
    ));
    t.mock.method(Student, "findOne", (filter) => {
        studentFindOneFilters.push(filter);
        return query(student && student.email === filter.email ? student : null);
    });
    t.mock.method(Batch, "findOne", (filter) => {
        batchFindOneFilters.push(filter);
        return query(batch &&
            String(batch._id) === String(filter._id) &&
            batch.department === filter.department
            ? batch
            : null
        );
    });
    t.mock.method(Subject, "find", (filter) => {
        subjectFindFilters.push(filter);
        return query([{
            _id: ids.assignedSubject,
            departments: [ids.north],
            teachers: [ids.teacher]
        }]);
    });
    t.mock.method(Subject, "findOne", (filter) => {
        subjectFindOneFilters.push(filter);
        const matchesTeacher = filter.teachers &&
            String(filter.teachers) === ids.teacher;
        return query(filter._id === ids.assignedSubject && matchesTeacher
            ? { _id: ids.assignedSubject }
            : null
        );
    });

    return {
        departmentFindFilters,
        subjectFindFilters,
        subjectFindOneFilters,
        studentFindOneFilters,
        batchFindOneFilters
    };
};

const userFor = (role, extra = {}) => ({
    _id: ids.user,
    email: `${role.toLowerCase()}@example.test`,
    role,
    ...extra
});

const requestFor = (role, params = {}) => ({
    user: { userId: ids.user, role },
    params
});

test("HOD department reads include only the HOD department", async (t) => {
    const mocks = installMocks(t, {
        user: userFor("HOD", { department: "North" })
    });

    const list = response();
    await getDepartments(requestFor("HOD"), list);
    assert.deepEqual(list.body.departments.map((department) => department._id), [ids.north]);
    assert.deepEqual(mocks.departmentFindFilters[0]._id.$in, [ids.north]);

    const foreign = response();
    await getDepartment(requestFor("HOD", { id: ids.south }), foreign);
    assert.equal(foreign.statusCode, 404);

    const own = response();
    await getDepartment(requestFor("HOD", { id: ids.north }), own);
    assert.equal(own.statusCode, 200);
});

test("teacher department reads include only assigned departments", async (t) => {
    const teacher = {
        _id: ids.teacher,
        email: "teacher@example.test",
        departments: [ids.north]
    };
    const mocks = installMocks(t, {
        user: userFor("TEACHER"),
        teacher
    });

    const list = response();
    await getDepartments(requestFor("TEACHER"), list);
    assert.deepEqual(list.body.departments.map((department) => department._id), [ids.north]);
    assert.deepEqual(mocks.departmentFindFilters.at(-1)._id.$in, [ids.north]);

    const foreign = response();
    await getDepartment(requestFor("TEACHER", { id: ids.south }), foreign);
    assert.equal(foreign.statusCode, 404);
});

test("student department reads are limited to the linked student's department", async (t) => {
    const student = {
        _id: ids.student,
        email: "student@example.test",
        department: "North",
        batchId: ids.batch
    };
    installMocks(t, {
        user: userFor("STUDENT"),
        student,
        batch: { _id: ids.batch, department: "North" }
    });

    const list = response();
    await getDepartments(requestFor("STUDENT"), list);
    assert.deepEqual(list.body.departments.map((department) => department._id), [ids.north]);

    const foreign = response();
    await getDepartment(requestFor("STUDENT", { id: ids.south }), foreign);
    assert.equal(foreign.statusCode, 404);
});

test("teacher subject reads require the authenticated teacher assignment", async (t) => {
    const teacher = {
        _id: ids.teacher,
        email: "teacher@example.test",
        departments: [ids.north]
    };
    const mocks = installMocks(t, {
        user: userFor("TEACHER"),
        teacher
    });

    const list = response();
    await getSubjects(requestFor("TEACHER"), list);
    assert.equal(mocks.subjectFindFilters[0].teachers, ids.teacher);
    assert.deepEqual(mocks.subjectFindFilters[0].departments.$in, [ids.north]);

    const unassigned = response();
    await getSubject(requestFor("TEACHER", { id: ids.unassignedSubject }), unassigned);
    assert.equal(unassigned.statusCode, 404);
    assert.equal(mocks.subjectFindOneFilters[0].teachers, ids.teacher);

    const assigned = response();
    await getSubject(requestFor("TEACHER", { id: ids.assignedSubject }), assigned);
    assert.equal(assigned.statusCode, 200);
});

const callBatchOwnership = async (role, id) => {
    let proceeded = false;
    const res = response();
    await requireOwnStudentBatchOrHod("id")(
        requestFor(role, { id }),
        res,
        () => { proceeded = true; }
    );
    return { proceeded, response: res };
};

test("student cannot request another student's batch", async (t) => {
    const student = {
        _id: ids.student,
        email: "student@example.test",
        department: "North",
        batchId: ids.batch
    };
    const mocks = installMocks(t, {
        user: userFor("STUDENT"),
        student,
        batch: { _id: ids.batch, department: "North" }
    });

    const result = await callBatchOwnership("STUDENT", ids.otherBatch);
    assert.equal(result.proceeded, false);
    assert.equal(result.response.statusCode, 403);
    assert.deepEqual(mocks.studentFindOneFilters[0], { email: "student@example.test" });
});

test("student with a nonexistent batch fails closed", async (t) => {
    const student = {
        _id: ids.student,
        email: "student@example.test",
        department: "North",
        batchId: ids.batch
    };
    const mocks = installMocks(t, {
        user: userFor("STUDENT"),
        student,
        batch: null
    });

    const result = await callBatchOwnership("STUDENT", ids.batch);
    assert.equal(result.proceeded, false);
    assert.equal(result.response.statusCode, 403);
    assert.deepEqual(mocks.batchFindOneFilters[0], {
        _id: ids.batch,
        department: "North"
    });
});

test("student batch department mismatch fails closed", async (t) => {
    const student = {
        _id: ids.student,
        email: "student@example.test",
        department: "North",
        batchId: ids.batch
    };
    const mocks = installMocks(t, {
        user: userFor("STUDENT"),
        student,
        batch: { _id: ids.batch, department: "South" }
    });

    const result = await callBatchOwnership("STUDENT", ids.batch);
    assert.equal(result.proceeded, false);
    assert.equal(result.response.statusCode, 403);
    assert.deepEqual(mocks.batchFindOneFilters[0], {
        _id: ids.batch,
        department: "North"
    });
});
