const assert = require("node:assert/strict");
const { after, before, test } = require("node:test");
const express = require("express");
const http = require("node:http");
const jwt = require("jsonwebtoken");
const { verifyToken } = require("../middleware/authMiddleware");
const upload = require("../middleware/upload");
const {
    updateAvatar,
    hasValidImageSignature
} = require("../controllers/avatarController");
const User = require("../models/User");
const cloudinary = require("../config/cloudinary");

process.env.JWT_SECRET = "security-hardening-tests-secret-32-bytes";

const app = express();
app.use("/api/teachers", require("../routes/teacherRoutes"));
app.use("/api/departments", require("../routes/departmentRoutes"));
app.use("/api/batches", require("../routes/batchRoutes"));
app.use("/api/subjects", require("../routes/subjectRoutes"));
app.use("/api/timetable", require("../routes/timetableRoutes"));
app.use("/api/notifications", require("../routes/notificationRoutes"));
app.post("/avatar", verifyToken, upload.single("avatar"), updateAvatar);

let server;
let baseUrl;

before(async () => {
    server = http.createServer(app);
    await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
    baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
    if (server) await new Promise((resolve) => server.close(resolve));
});

const tokenFor = (role, options = {}) => jwt.sign(
    { userId: "111111111111111111111111", role },
    process.env.JWT_SECRET,
    options
);

const request = async (path, method = "GET", token) => {
    const response = await fetch(`${baseUrl}${path}`, {
        method,
        headers: token ? { Authorization: `Bearer ${token}` } : {},
    });
    return response;
};

test("administrative mutations reject missing, invalid, and expired JWTs", async () => {
    const cases = [
        undefined,
        "not-a-jwt",
        tokenFor("HOD", { expiresIn: -1 }),
    ];

    for (const token of cases) {
        const response = await request("/api/teachers", "POST", token);
        assert.equal(response.status, 401);
    }
});

test("avatar upload route rejects unauthenticated callers before processing files", async () => {
    const response = await request("/avatar", "POST");
    assert.equal(response.status, 401);
});

test("students and teachers cannot create or mutate administrative records", async (t) => {
    let activeRole = "STUDENT";
    t.mock.method(User, "findById", () => ({
        select: async () => ({ role: activeRole, isActive: true }),
    }));
    for (const role of ["STUDENT", "TEACHER"]) {
        activeRole = role;
        const token = tokenFor(role);
        assert.equal((await request("/api/teachers", "POST", token)).status, 403);
        assert.equal((await request("/api/departments", "POST", token)).status, 403);
        assert.equal((await request("/api/batches", "POST", token)).status, 403);
        assert.equal((await request("/api/subjects/111111111111111111111111", "DELETE", token)).status, 403);
        assert.equal((await request("/api/timetable", "POST", token)).status, 403);
    }
});

test("HOD ownership checks deny cross-department student records", async (t) => {
    const User = require("../models/User");
    const Student = require("../models/Student");
    const { requireStudentOrHod } = require("../middleware/ownership");

    t.mock.method(User, "findById", () => ({
        select: async () => ({ role: "HOD", department: "North" }),
    }));
    t.mock.method(Student, "findById", () => ({
        select: async () => ({ department: "South" }),
    }));

    const response = {
        statusCode: 0,
        status(code) {
            this.statusCode = code;
            return this;
        },
        json() {
            return this;
        },
    };
    let proceeded = false;

    await requireStudentOrHod("id")(
        {
            user: { userId: "111111111111111111111111", role: "HOD" },
            params: { id: "222222222222222222222222" },
        },
        response,
        () => { proceeded = true; }
    );

    assert.equal(proceeded, false);
    assert.equal(response.statusCode, 403);
});

test("avatar validation requires file signatures to match allowed image MIME types", () => {
    const pngSignature = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);

    assert.equal(
        hasValidImageSignature({ mimetype: "image/png", buffer: pngSignature }),
        true
    );
    assert.equal(
        hasValidImageSignature({ mimetype: "image/jpeg", buffer: pngSignature }),
        false
    );
    assert.equal(
        hasValidImageSignature({ mimetype: "image/png", buffer: Buffer.from("not image") }),
        false
    );
});

test("avatar update uses the authenticated account, ignoring caller-supplied IDs", async (t) => {
    const authenticatedId = "111111111111111111111111";
    const callerSuppliedId = "222222222222222222222222";
    const user = {
        _id: authenticatedId,
        name: "Test User",
        email: "user@example.test",
        role: "STUDENT",
        save: async () => {}
    };
    const findUser = t.mock.method(User, "findById", async (id) => {
        assert.equal(id, authenticatedId);
        return user;
    });
    const uploadStream = t.mock.method(
        cloudinary.uploader,
        "upload_stream",
        (options, callback) => ({
            end() {
                callback(null, {
                    public_id: "avatar-test",
                    secure_url: "https://images.example.test/avatar.png"
                });
            }
        })
    );
    const res = {
        statusCode: 0,
        status(code) {
            this.statusCode = code;
            return this;
        },
        json(body) {
            this.body = body;
            return this;
        }
    };

    await updateAvatar({
        user: { userId: authenticatedId },
        body: { userId: callerSuppliedId, email: "victim@example.test" },
        file: {
            mimetype: "image/png",
            buffer: Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])
        }
    }, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.user.id, authenticatedId);
    assert.equal(findUser.mock.calls.length, 1);
    assert.equal(uploadStream.mock.calls.length, 1);
});
