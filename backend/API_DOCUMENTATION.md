# Backend API contract (implemented behavior)

This document describes routes mounted by `server.js`, based on the current
route middleware and controller code. It does not describe intended or planned
functionality. Unless otherwise stated, JSON requests use
`Content-Type: application/json`; responses use `{ "success": boolean, ... }`.

## Server and authentication

- The API is mounted at `/api/<module>`. `GET /` returns the plain text
  `Attendance ERP API Running`.
- The default listener port is `5000`; `PORT` can override it.
- `GET /uploads/*` serves files from the backend's uploads directory as static
  files without authentication (needed for existing public avatar URLs). These
  files must be treated as public.
- `POST /api/auth/login` issues a JWT valid for seven days. The token includes
  `userId` and `role`.
- Protected routes expect `Authorization: Bearer <JWT>`. Missing, malformed,
  invalid, and expired tokens return HTTP 401. Role middleware returns HTTP 403.
- `JWT_SECRET` must be configured and contain at least 32 bytes or the server
  fails startup. Login roles are `HOD`, `TEACHER`, and `STUDENT`.
- Login and password reset requests are limited to 10 requests per IP address
  per 15-minute window (per server process).
- Browser CORS origins are restricted to exact origins in the comma-separated
  `CORS_ORIGINS` environment variable. Requests without an `Origin` header are
  allowed. An unset allowlist blocks browser-origin access.
- Pagination is not implemented for the documented collection endpoints.

## Authentication

| Method and path | Auth / roles | Purpose and inputs | Success and errors |
|---|---|---|---|
| `POST /api/auth/login` | None; rate-limited | Body: `{ "email": string, "password": string }`. Email is lowercased and trimmed. | 200 `{success:true,message,token,user:{id,name,email,role,department,phone,avatar}}`; 400 invalid/missing or oversized credentials; 401 generic invalid credentials/inactive account; 429 rate limit; 500 generic failure. |
| `POST /api/auth/forgot-password` | None; rate-limited | Body: `{ "email": string }`. Requires configured reset URL and working mail delivery for an email to be sent. | 200 generic response whether or not an active account exists; 400 invalid email; 429 rate limit; 500 generic failure. Reset links expire after 15 minutes. |
| `POST /api/auth/reset-password` | None; rate-limited | Body: `{ "token": 64 hex chars, "newPassword": string }`; password length 8–128. | 200 `{success:true,message}`; 400 missing/invalid/expired token or invalid password; 429 rate limit; 500 generic failure. Token is single-use. |
| `PUT /api/auth/avatar` | JWT; any authenticated role | Multipart form field `avatar`; JPEG/PNG/WebP, maximum 5 MiB. | 200 `{success:true,message,avatarUrl,user}`; 400 no image; 404 user missing; 500 upload failure. Upload uses Cloudinary. |

`POST /api/upload/avatar` is an alias to the same JWT-protected Cloudinary
avatar handler; it does not accept a target user ID or use local disk storage.

## Students

All paths below are under `/api/students`.

| Method and path | Auth / roles | Inputs and behavior | Success / errors |
|---|---|---|---|
| `POST /` | JWT; HOD; own department | JSON body: `studentName`, `registerNo`, `email`, `phoneNo`, `apaarId`, optional legacy `aadhaarNo`, `batchId`. Batch must belong to HOD department. A cryptographically random temporary password is generated; Aadhaar is not persisted. | 201 `{success:true,message,tempPassword,student}`; duplicate account rejected; 403 other department; 404 batch missing; 500 generic failure. Password hash, Aadhaar, and APAAR ID are removed from the returned student. |
| `GET /` | JWT; HOD; own department | No query parameters. Returns own-department students, sorted newest first; no pagination. | 200 `{success:true,students}`; password/Aadhaar/APAAR excluded; 403 when department cannot be resolved; 500 generic failure. |
| `GET /:id` | JWT; HOD in same department or STUDENT self | Student ObjectId. HOD scope and student email-to-profile ownership are checked. | 200 `{success:true,student}` with batch populated; password/Aadhaar/APAAR excluded; 400 invalid ID; 403 out of scope; 404 missing; 500 generic failure. |
| `PUT /:id` | JWT; HOD; own department | Only `studentName`, `registerNo`, `email`, `phoneNo`, `batchId` can be updated. Batch changes must remain in HOD department; matching User fields are synchronized. | 200 `{success:true,student}` with sensitive fields removed; 400/403/404/500 as applicable. |
| `DELETE /:id` | JWT; HOD; own department | Deletes the Student and matching User by email, if found. | 200 `{success:true,message}`; 400 invalid ID; 403 out of scope; 404 or 500 as applicable. |

No query filtering or pagination is implemented. Student records are scoped to
the HOD's department; student profile access is self-only for student callers.

## Teachers

Teacher CRUD routes require JWT and HOD role. HOD access is restricted to the
HOD's department; creation requires assignment to that department.

| Method and path | Auth / roles | Inputs and behavior | Success / errors |
|---|---|---|---|
| `POST /` | JWT; HOD; own department | Body: `teacherName`, `employeeId`, `email`, `phoneNo`, `departments`. Requires a unique email/employee ID and one or more department IDs matching the HOD department. Creates matching User. | 201 `{success:true,message,tempPassword,teacher}` with password hash removed; temporary password is random; 400/403/404/409/500 as applicable. |
| `GET /` | JWT; HOD; own department | No query parameters. Returns same-department teachers with password excluded, department populated, and active assigned-subject summaries. | 200 `{success:true,teachers}`; 403 if department cannot be resolved; 500 generic failure. |
| `GET /:id` | JWT; HOD; same department | Teacher ObjectId. Populates departments and excludes password. | 200 `{success:true,teacher}`; 400 invalid ID; 403 out of scope; 404/500 as applicable. |
| `PUT /:id` | JWT; HOD; same department | Only `teacherName`, `employeeId`, `email`, `phoneNo`, and `departments` can be updated; department assignments must remain within the HOD department. | 200 `{success:true,message,teacher}`; password excluded; 400/403/404/500 as applicable. |
| `DELETE /:id` | JWT; HOD; same department | Deletes Teacher and matching User by email. | 200 `{success:true,message}`; 400/403/404/500 as applicable. |

## Batches

All paths require JWT. List responses are limited to the caller's department;
students receive only their own batch. Mutations require HOD in that batch's
department.

| Method and path | Auth / roles | Inputs and behavior | Success / errors |
|---|---|---|---|
| `POST /` | JWT; HOD; own department | Body: `batchName`, `department`, `startYear`, `endYear`. Department must equal HOD department. | 201 `{success:true,batch}`; 403 out of scope; 400 duplicate/validation; 500 generic failure. |
| `GET /` | JWT; HOD, TEACHER, STUDENT; department-scoped | No query parameters. Descending `startYear`; student sees own batch only, and the batch must exist in the student's profile department. | 200 `{success:true,batches}`; 403 if profile/department/batch association cannot be resolved; 500 generic failure. |
| `PUT /:id/promote` | JWT; HOD; same department | Increments `currentSemester`; promotion is refused when it is at least 6. | 200 `{success:true,message,batch}`; 400 completed; 403/404/500 as applicable. |

## Departments

All routes require JWT. Reads are limited to the caller's resolved scope: HOD
gets their department, teachers get departments linked to their Teacher
profile, and students get the department on their linked Student profile.
Unresolved associations fail closed. Mutations are HOD-only; HOD may not
operate on a different department. Department names cannot be renamed by HOD
because they are the current cross-model scope key.

| Method and path | Auth / roles | Inputs and behavior | Success / errors |
|---|---|---|---|
| `POST /` | JWT; HOD; department name must match caller's configured department | Body: `departmentName`, `departmentCode`, `hodName`; duplicate name/code rejected. A new department generally requires provisioning outside this route because a HOD is already bound to an existing department name. | Controller returns `{success:true,message,department}` with 201; 403 if name is out of scope, 400 duplicate, 500 generic failure. |
| `GET /` | JWT; HOD, TEACHER, STUDENT | No query parameters; returns only departments in the caller's resolved scope, sorted newest first. 200 `{success:true,departments}`; 403 unresolved association. |
| `GET /:id` | JWT; HOD, TEACHER, STUDENT | Department ObjectId in caller's resolved scope. 200 `{success:true,department}`; 400 malformed ID; 403 unresolved association; 404 missing or out of scope. |
| `PUT /:id` | JWT; HOD; same department | May update code/name metadata except changing `departmentName`. 200 `{success:true,message,department}`; 400/403/404/500 as applicable. |
| `DELETE /:id` | JWT; HOD; same department | No cascading cleanup. 200 `{success:true,message}`; 400/403/404/500 as applicable. |

## Subjects

All routes require JWT. HOD reads are limited to the HOD department; teacher
reads additionally require the teacher's profile ID in the subject's
`teachers` assignment; student reads are limited to the student profile's
department. Teachers are populated using the safe `teacherName` and `avatar`
projection. Mutations are HOD-only and assignments are restricted to the HOD
department.

| Method and path | Auth / roles | Inputs and behavior | Success / errors |
|---|---|---|---|
| `POST /` | JWT; HOD; own department | Body: `subjectName`, `subjectCode`, `departments`, `teachers`, `semester`, `credits`. Department and teacher assignments must be within caller department. 201 `{success:true,message,subject}`; 400/403/500 as applicable. |
| `GET /` | JWT; HOD, TEACHER, STUDENT; scoped | No query parameters; sorted newest first. Teachers receive only assigned subjects within their departments. Teacher population contains only `teacherName`, `avatar`. 200 `{success:true,subjects}`; 403 unresolved association; 500 generic failure. |
| `GET /:id` | JWT; HOD, TEACHER, STUDENT; scoped | Subject ObjectId; teachers must be assigned that subject and its department. Safe teacher population. 200 `{success:true,subject}`; 400 invalid ID; 403 unresolved association; 404 missing or out of scope; 500 generic failure. |
| `PUT /:id` | JWT; HOD; same department | Only `subjectName`, `subjectCode`, `departments`, `teachers`, `semester`, and `credits` can be updated; assignments remain within caller department. 200 `{success:true,message,subject}`; 400/403/404/500 as applicable. |
| `DELETE /:id` | JWT; HOD; same department | No attendance/timetable cleanup is implemented. 200 `{success:true,message}`; 400/403/404/500 as applicable. |

## Attendance

All paths are under `/api/attendance`. Requests other than reads below use
JSON; protected routes require a Bearer token.

| Method and path | Auth / roles | Inputs, behavior, success, and errors |
|---|---|---|
| `POST /mark` | JWT; TEACHER | Body requires `student`, `subject`, `batch`, `status`; optional `date`. Client `teacher` is ignored. Status must be `Present`, `Absent`, or `Late`; related student/batch/subject and teacher assignment are checked. Date is normalized to local midnight. 200 `{success:true,message,attendance}`. 400 required field, invalid status/date; 403 unauthorized subject/department; 404 student or batch missing; 409 duplicate-key conflict; 500 other internal error. Same student + subject + batch + local calendar day updates the existing record. |
| `PUT /update/:id` | JWT; TEACHER | Path `id`: attendance ObjectId. Body may provide `student`, `subject`, `batch`, `date`, `status`; teacher cannot be changed by request. Record's stored teacher must match authenticated profile; target links are reauthorized. 200 `{success:true,attendance}`; 400 invalid status/date; 403 unauthorized; 404 missing record/reference or malformed ObjectId; 409 same-day collision; 500 internal error. |
| `DELETE /delete/:id` | JWT; TEACHER | Attendance ObjectId; record must be attributed to authenticated teacher and its target is reauthorized. 200 `{success:true,message}`; 403 unauthorized; 404 missing; 500 internal error. |
| `GET /student/:id` | JWT; HOD in same department or STUDENT self | Student ObjectId. Student callers are resolved by User email and may access only their own ID. 200 `{success:true,attendance}`; each record populates safe allowlisted fields. 400/403/404/500 as applicable. |
| `GET /batch/:id` | JWT; HOD; same department | Batch ObjectId. Returns attendance records with safe allowlisted populations. 400/403/404/500 as applicable. |
| `GET /subject/:id` | JWT; HOD in same department or assigned TEACHER | Subject ObjectId. Teacher is resolved by User email, must be assigned the subject and share department association with returned batches. Returns populated attendance records. 400/403/404/500. |
| `GET /percentage/:studentId` | JWT; HOD in same department or STUDENT self | Student ObjectId; student callers may request only their own profile. 200 `{success:true,totalClasses,presentClasses,lateClasses,absentClasses,attendancePercentage}`. 400/403/404/500. |
| `GET /defaulters` | JWT; HOD; own department | No query parameters. Returns same-department students below 75%; calculations use `LATE_AS`. 200 `{success:true,totalDefaulters,defaulters:[{studentId,studentName,registerNo,attendancePercentage}]}`. Zero-record students are included at 0%. |
| `GET /report/student/:id` | JWT; HOD in same department or STUDENT self | Student ObjectId; student caller restricted to own ID. 200 detailed `{success,student,overall,subjects}` with policy-based two-decimal percentages. 400/403/404/500. |

**Attendance request example:**

```json
{
  "student": "<Student ObjectId>",
  "subject": "<Subject ObjectId>",
  "batch": "<Batch ObjectId>",
  "date": "2026-11-06",
  "status": "Late"
}
```

Attendance routes do not implement bulk marking, date-range filtering, or
pagination. See [ATTENDANCE_DOCUMENTATION.md](./ATTENDANCE_DOCUMENTATION.md)
for calculation and identity rules.

## Dashboard

All dashboard routes require JWT and enforce role and profile ownership.
The controller's `getDashboardStats` function is not mounted as a route.

| Method and path | Inputs / success |
|---|---|
| `GET /api/dashboard/hod` | JWT; HOD; own department. 200 `{success:true,dashboard:{totalStudents,totalTeachers,totalSubjects,totalBatches,totalDefaulters}}`. Defaulters with zero attendance are not counted. |
| `GET /api/dashboard/teacher/:teacherId` | JWT; HOD in same department or TEACHER self. 200 `{success:true,dashboard:{teacherName,subjectsAssigned,timetableEntries,totalStudents}}`. Student totals count departments assigned to that teacher. |
| `GET /api/dashboard/student/:studentId` | JWT; HOD in same department or STUDENT self. 200 `{success:true,dashboard:{studentName,registerNo,batch,currentSemester,presentClasses,lateClasses,absentClasses,attendancePercentage}}`. |

Missing profiles return 404; authorization failures return 403. Unexpected
errors return generic 500 messages.

## Reports

All report routes require JWT. Student reports (JSON and PDF) are limited to
the student or a same-department HOD. Batch and subject reports are HOD-only
and department-scoped.

| Method and path | Inputs, success and errors |
|---|---|
| `GET /student/:studentId` | JWT; HOD same department or student self. 200 JSON summary; 400/403/404/500. |
| `GET /batch/:batchId` | JWT; HOD same department. 200 JSON summary; 400/403/404/500. |
| `GET /subject/:subjectId` | JWT; HOD same department. 200 JSON summary; 400/403/404/500. |
| `GET /student/:studentId/pdf` | JWT; HOD same department or student self. PDF attachment includes totals by status and configured-policy percentage; 400/403/404/500. |
| `GET /batch/:batchId/monthly-pdf` | JWT; HOD same department. Required `month` (1–12), `year` (positive integer). 400 invalid query; 403/404; empty batch returns JSON; otherwise `application/pdf`. |
| `GET /batch/:batchId/monthly-preview` | JWT; HOD same department. Same validation/calculation as monthly PDF; PDF disposition is inline. |

Month parameters are numeric, not localized labels. Monthly PDFs aggregate
attendance records within the selected month using local server dates.

## Timetable

All paths are under `/api/timetable` (singular) and require JWT. HOD can manage
entries only where batch, subject, and teacher all belong to their department.
Teachers can read their own schedule; students can read their own batch's
schedule. HOD collection reads are department-scoped.

| Method and path | Inputs, behavior and success |
|---|---|
| `POST /` | JWT; HOD; in-department assignments only. Requires `batch`, `subject`, `teacher`, `day`, `startTime`, `endTime`. Day Monday–Saturday; 24-hour `HH:mm`; end later; detects overlaps. 201 success; 400 validation; 403 assignment; 409 conflict; 500. |
| `GET /` | JWT; HOD; own department. Sorted by day/time and populates batch/subject/teacher. 200 `{success:true,timetable}`. |
| `GET /batch/:id` | JWT; HOD or STUDENT self-batch. 200 populated entries; 400/403/500. |
| `GET /teacher/:id` | JWT; HOD same department or TEACHER self. 200 populated entries; 400/403/500. |
| `PATCH /:id` | JWT; HOD; existing and requested assignments must be in department. Requires complete timetable fields; checks conflicts. 200 success; 400/403/404/409/500. |
| `DELETE /:id` | JWT; HOD; entry assignments must be in department. 200 success; 400/403/404/500. |

All timetable error responses use `{success:false,message}`. There are no query
filters or pagination.

## Leave

All routes require JWT. Student/teacher leave submission and listing are bound
to the authenticated profile. HOD can list and act on leave requests only for
their department. Because there is no Teacher-to-Batch mapping, teacher
recommendation actions are restricted to HOD rather than inferred from a
teacher assignment.

| Method and path | Auth / roles | Request and behavior | Success / errors |
|---|---|---|---|
| `POST /` | JWT; STUDENT or TEACHER | Body: `reason`, `fromDate`, `toDate`; applicant ID/type are derived from account. Dates must parse and start must not follow end. | 201 `{success:true,message,leave}`; 400 invalid fields; 403 profile unavailable; 500 generic failure. |
| `GET /` | JWT; STUDENT/TEACHER own requests; HOD own department | Newest first; no pagination. | 200 `{success:true,leaves}`; 403 unresolved scope; 500 generic failure. |
| `PUT /:id/recommend` | JWT; HOD; same department | Sets `teacherApproval=true`, status `PENDING_HOD`. | 200 `{success:true,message,leave}`; 400 invalid ID; 403 out of scope; 404/500. |
| `PUT /:id/approve` | JWT; HOD; same department | Sets `hodApproval=true`, status `APPROVED`, creates a notification for applicant. | 200 `{success:true,message,leave}`; 400/403/404/500. |
| `PUT /:id/reject` | JWT; HOD; same department | Sets status `REJECTED`. | 200 `{success:true,message,leave}`; 400/403/404/500. |

## Notifications

All routes require JWT. HOD may create notifications only for recipients in
their department. Users may list notifications for their own User/profile ID
and mark only their own notifications as read.

| Method and path | Auth / roles | Request and behavior | Success / errors |
|---|---|---|---|
| `POST /` | JWT; HOD; recipient in own department | Body: `recipientId`, `recipientRole` (`STUDENT`/`TEACHER`), `title`, `message`; `isRead` defaults false. | 201 `{success:true,notification}`; 400 invalid role; 403 recipient out of scope; 500 generic failure. |
| `GET /:userId` | JWT; own User ID or linked Student/Teacher profile ID | Results sorted newest first. | 200 `{success:true,notifications}`; 400 malformed ID; 403 other recipient; 500 generic failure. |
| `PUT /:id/read` | JWT; own notification only | Sets `isRead=true`. | 200 `{success:true,notification}`; 400 malformed ID; 404 absent/not owned; 500 generic failure. |

## Upload

Both upload paths use the same authenticated Cloudinary avatar handler and
update only the account in the JWT. Neither accepts a target user ID or email.
Uploads are limited to JPEG/PNG/WebP, 5 MiB, and must have a matching file
signature. Local static files under `/uploads/*` remain publicly served.
The legacy `controllers/uploadController.js` is not mounted. It trusts
caller-supplied user IDs/emails and does not validate image signatures; do not
mount or reuse it without authentication, ownership checks, and file-signature
validation.

| Method and path | Request and behavior | Success / errors |
|---|---|---|
| `POST /api/upload/avatar` | JWT; any authenticated role. Multipart field `avatar`; file signature and MIME must be valid; max 5 MiB. | 200 `{success:true,message,avatarUrl,user}`; 400 missing/invalid image; 401 missing/invalid token; 404 user missing; 500 generic failure. |

## Error contract and implementation caveats

Error objects usually contain `{ "success": false, "message": "..." }`.
Unexpected server and database errors return generic messages rather than raw
database text. The global parser/upload handler returns generic 400, 413, or 500
responses. Status codes and response fields vary by endpoint as listed above.

There is no shared schema validator, pagination, or global authentication
middleware; authorization is applied route-by-route with controller-level
ownership checks. The intentionally public API endpoints are login,
forgot-password, reset-password, `GET /`, and static `GET /uploads/*`.
