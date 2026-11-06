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
  files; no authentication middleware is attached.
- `POST /api/auth/login` issues a JWT valid for seven days. The token includes
  `userId` and `role`.
- Protected routes expect `Authorization: Bearer <JWT>`. Missing and invalid
  tokens return HTTP 401. Role middleware returns HTTP 403.
- Login roles defined by the User schema are `HOD`, `TEACHER`, and `STUDENT`.
  Some attendance routes also allow `ADMIN`, although the User role enum does
  not include `ADMIN`.
- Many routes have no authentication middleware. Their tables say **None**;
  no role check is implied.
- Pagination is not implemented for the documented collection endpoints.

## Authentication

| Method and path | Auth / roles | Purpose and inputs | Success and errors |
|---|---|---|---|
| `POST /api/auth/login` | None | Body: `{ "email": string, "password": string }`. Email is lowercased and trimmed. | 200 `{success:true,message,token,user:{id,name,email,role,department,phone,avatar}}`; 400 missing credentials; 401 unknown user or incorrect password; 500 generic login failure. |
| `POST /api/auth/forgot-password` | None | Body: `{ "email": string }`. Requires configured reset URL and working mail delivery for an email to be sent. | 200 generic response whether or not an active account exists; 400 missing email; 500 generic failure. Reset links expire after 15 minutes. |
| `POST /api/auth/reset-password` | None | Body: `{ "token": string, "newPassword": string }`; password minimum length 8. | 200 `{success:true,message}`; 400 missing/invalid/expired token or short password; 500 generic failure. Token is single-use. |
| `PUT /api/auth/avatar` | JWT; any authenticated role | Multipart form field `avatar`; JPEG/PNG/WebP, maximum 5 MiB. | 200 `{success:true,message,avatarUrl,user}`; 400 no image; 404 user missing; 500 upload failure. Upload uses Cloudinary. |

`POST /api/upload/avatar` is a separate, implemented route; see Upload below.
It is **not** protected by the JWT middleware and has a different storage and
request contract.

## Students

All paths below are under `/api/students`.

| Method and path | Auth / roles | Inputs and behavior | Success / errors |
|---|---|---|---|
| `POST /` | JWT; HOD | JSON body fields read: `studentName`, `registerNo`, `email`, `phoneNo`, `apaarId`, `aadhaarNo`, `batchId`. A batch must exist. A temporary password is derived from the last five characters of `aadhaarNo`, then hashed. A matching User is upserted by email. | 201 `{success:true,message,tempPassword,student}`; 400 duplicate email/register number; 404 batch missing; 500 other failure. The returned student object is not projected, and the response includes the temporary password. |
| `GET /` | JWT; HOD or TEACHER | No query parameters. Returns all students sorted newest first; no pagination. | 200 `{success:true,students}`; student `password` and `aadhaarEncrypted` are excluded; 500 failure. |
| `GET /:id` | JWT; any role accepted by `verifyToken` | Path `id`: Student ObjectId. No ownership check is implemented. | 200 `{success:true,student}` with batch populated and `password`, `aadhaarEncrypted` excluded; 404 not found; 500 error. |
| `PUT /:id` | JWT; HOD | Path `id`; request body is passed to `findByIdAndUpdate` without an explicit allowlist. Some changed fields are synchronized to User by email. | 200 `{success:true,student}`; 404 missing; 500 error. The updated object is not explicitly redacted. |
| `DELETE /:id` | JWT; HOD | Path `id`. Deletes the Student and then a User with matching lowercased email, if found. | 200 `{success:true,message}` even if no Student existed; 500 error. |

No query filtering or pagination is implemented. Student profile GET access is
not restricted to the matching student account.

## Teachers

All paths under `/api/teachers` have **no authentication and no role checks**.

| Method and path | Inputs and behavior | Success / errors |
|---|---|---|
| `POST /` | JSON fields read: `teacherName`, `employeeId`, `email`, `phoneNo`, `departments`. Email is required; duplicate email/employee ID is checked; supplied department IDs are checked. Creates matching User by email. Temporary password is `${employeeId}@123`, stored hashed. | 201 `{success:true,message,tempPassword,teacher}`; 400 missing email or duplicate; 404 invalid department reference; 500 error. The response includes the temporary password and unprojected teacher document. |
| `GET /` | No query parameters. Returns teachers sorted newest first, populates departments, excludes password; appends currently active subjects assigned to each teacher. | 200 `{success:true,teachers}`; 500 error. |
| `GET /:id` | Teacher ObjectId. Populates departments and excludes password. | 200 `{success:true,teacher}`; 404 missing; 500 error. |
| `PUT /:id` | Teacher ObjectId; body passed to `findByIdAndUpdate`. Populates departments and excludes password. | 200 `{success:true,message,teacher}`; 404 missing; 500 error. |
| `DELETE /:id` | Teacher ObjectId. Deletes Teacher and User by email. | 200 `{success:true,message}`; 404 missing; 500 error. |

## Batches

All paths under `/api/batches` are unauthenticated.

| Method and path | Inputs and behavior | Success / errors |
|---|---|---|
| `POST /` | Body: `batchName`, `department`, `startYear`, `endYear`. Other model fields use schema defaults. | 201 `{success:true,batch}`; 400 duplicate batch name; 500 validation/database error. |
| `GET /` | No query parameters. Returns batches ordered by descending `startYear`. | 200 `{success:true,batches}`; 500 error. |
| `PUT /:id/promote` | Path `id`: Batch ObjectId. Increments `currentSemester`; promotion is refused when it is at least 6. | 200 `{success:true,message,batch}`; 400 completed batch; 404 missing; 500 error. |

## Departments

All paths under `/api/departments` are unauthenticated.

| Method and path | Inputs and behavior | Success / errors |
|---|---|---|
| `POST /` | Body: `departmentName`, `departmentCode`, `hodName`. Checks existing name or code. | 201 `{success:true,message,department}`; 400 duplicate; 500 validation/database error. |
| `GET /` | No query parameters; sorted newest first. | 200 `{success:true,departments}`; 500 error. |
| `GET /:id` | Department ObjectId. | 200 `{success:true,department}`; 404 missing; 500 error. |
| `PUT /:id` | Department ObjectId; body passed to `findByIdAndUpdate`. | 200 `{success:true,message,department}`; 404 missing; 500 error. |
| `DELETE /:id` | Department ObjectId. No cascading relationship cleanup is implemented. | 200 `{success:true,message}`; 404 missing; 500 error. |

## Subjects

All paths under `/api/subjects` are unauthenticated.

| Method and path | Inputs and behavior | Success / errors |
|---|---|---|
| `POST /` | Body: `subjectName`, `subjectCode`, optional `departments`, `teachers`, `credits`, required `semester`. | 201 `{success:true,message,subject}`; 400 duplicate subject code; 500 schema/database error. |
| `GET /` | No query parameters. Populates departments and teachers; results sorted newest first. | 200 `{success:true,subjects}`; 500 error. Populated teacher documents are not explicitly projected. |
| `GET /:id` | Subject ObjectId; populates departments and teachers. | 200 `{success:true,subject}`; 404 missing; 500 error. |
| `PUT /:id` | Subject ObjectId; body passed to `findByIdAndUpdate`, then departments/teachers populated. | 200 `{success:true,message,subject}`; 404 missing; 500 error. |
| `DELETE /:id` | Subject ObjectId. No attendance/timetable cleanup is implemented. | 200 `{success:true,message}`; 404 missing; 500 error. |

## Attendance

All paths are under `/api/attendance`. Requests other than reads below use
JSON; protected routes require a Bearer token.

| Method and path | Auth / roles | Inputs, behavior, success, and errors |
|---|---|---|
| `POST /mark` | JWT; TEACHER | Body requires `student`, `subject`, `batch`, `status`; optional `date`. Client `teacher` is ignored. Status must be `Present`, `Absent`, or `Late`; related student/batch/subject and teacher assignment are checked. Date is normalized to local midnight. 200 `{success:true,message,attendance}`. 400 required field, invalid status/date; 403 unauthorized subject/department; 404 student or batch missing; 409 duplicate-key conflict; 500 other internal error. Same student + subject + batch + local calendar day updates the existing record. |
| `PUT /update/:id` | JWT; TEACHER | Path `id`: attendance ObjectId. Body may provide `student`, `subject`, `batch`, `date`, `status`; teacher cannot be changed by request. Record's stored teacher must match authenticated profile; target links are reauthorized. 200 `{success:true,attendance}`; 400 invalid status/date; 403 unauthorized; 404 missing record/reference or malformed ObjectId; 409 same-day collision; 500 internal error. |
| `DELETE /delete/:id` | JWT; TEACHER | Attendance ObjectId; record must be attributed to authenticated teacher and its target is reauthorized. 200 `{success:true,message}`; 403 unauthorized; 404 missing; 500 internal error. |
| `GET /student/:id` | JWT; ADMIN, HOD, STUDENT | Student ObjectId. Student callers are resolved to a unique profile by User email and may access only their own ID. 200 `{success:true,attendance}`; each record populates allowlisted student, teacher, subject and batch fields. 401/403/404/500 as applicable. |
| `GET /batch/:id` | JWT; ADMIN, HOD | Batch ObjectId. Returns attendance records with allowlisted populations. 401/403/500; no explicit not-found validation for batch. |
| `GET /subject/:id` | JWT; ADMIN, HOD, TEACHER | Subject ObjectId. Teacher is resolved by User email, must be assigned the subject and shares department association with returned batches. Returns populated attendance records. 401/403/500. |
| `GET /percentage/:studentId` | JWT; ADMIN, HOD, STUDENT | Student ObjectId; student callers may request only their own profile. 200 `{success:true,totalClasses,presentClasses,lateClasses,absentClasses,attendancePercentage}`. 401/403/404/500. |
| `GET /defaulters` | JWT; ADMIN, HOD | No query parameters. Returns students below 75%; calculations use `LATE_AS`. 200 `{success:true,totalDefaulters,defaulters:[{studentId,studentName,registerNo,attendancePercentage}]}`; 401/403/500. Zero-record students are included at 0% in this endpoint. |
| `GET /report/student/:id` | JWT; ADMIN, HOD, STUDENT | Student ObjectId; student caller restricted to own ID. 200 detailed `{success,student,overall,subjects}` with policy-based two-decimal percentages. 401/403/404/500. |

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

All three mounted dashboard routes have **no authentication or role check**.
The controller's `getDashboardStats` function is not mounted as a route.

| Method and path | Inputs / success |
|---|---|
| `GET /api/dashboard/hod` | No inputs. 200 `{success:true,dashboard:{totalStudents,totalTeachers,totalSubjects,totalBatches,totalDefaulters}}`. Defaulters with zero attendance are not counted. |
| `GET /api/dashboard/teacher/:teacherId` | Teacher ObjectId. 200 `{success:true,dashboard:{teacherName,subjectsAssigned,timetableEntries,totalStudents}}`. No caller ownership check. |
| `GET /api/dashboard/student/:studentId` | Student ObjectId. 200 `{success:true,dashboard:{studentName,registerNo,batch,currentSemester,presentClasses,lateClasses,absentClasses,attendancePercentage}}`. No caller ownership check. |

Missing profiles return 404; controller errors generally return 500 with a
message. Dashboard summary routes do not have JWT headers.

## Reports

All paths under `/api/reports` are unauthenticated.

| Method and path | Inputs, success and errors |
|---|---|
| `GET /student/:studentId` | JSON summary. 200 `{success:true,report:{studentName,registerNo,totalClasses,presentClasses,lateClasses,absentClasses,attendancePercentage}}`; 404 missing student; 500 error. |
| `GET /batch/:batchId` | JSON summary. 200 `{success:true,report:{batchName,currentSemester,totalAttendance,presentAttendance,lateAttendance,attendancePercentage}}`; 404 missing batch; 500 error. |
| `GET /subject/:subjectId` | JSON summary. 200 `{success:true,report:{subjectName,subjectCode,totalAttendance,presentAttendance,lateAttendance,attendancePercentage}}`; 404 missing subject; 500 error. |
| `GET /student/:studentId/pdf` | PDF attachment. Path Student ObjectId. Document includes totals by status and configured-policy attendance percentage. No JSON success body; 404 missing student; 500 error. |
| `GET /batch/:batchId/monthly-pdf` | Monthly PDF attachment. Required query `month` (1–12) and `year` (positive integer). Returns 400 for missing/invalid values, 404 missing batch, 200 empty JSON if batch has no students, otherwise `application/pdf`; 500 on generation failure. |
| `GET /batch/:batchId/monthly-preview` | Same path/query validation and calculations as monthly PDF, but PDF disposition is inline. Empty batch returns JSON. |

Month parameters are numeric, not localized labels. Monthly PDFs aggregate
attendance records within the selected month using local server dates.

## Timetable

All paths are under `/api/timetable` (singular) and are unauthenticated.

| Method and path | Inputs, behavior and success |
|---|---|
| `POST /` | Body requires `batch`, `subject`, `teacher`, `day`, `startTime`, `endTime`. Day is Monday–Saturday; times use 24-hour `HH:mm`, and end must be later. Checks overlapping active timetable entries for same batch or teacher. 201 `{success:true,message,timetable}`; 400 validation, 409 conflict, 500 error. |
| `GET /` | No parameters; sorted by day/time and populates batch/subject/teacher. 200 `{success:true,timetable}`. |
| `GET /batch/:id` | Batch ObjectId; populated entries. 200 `{success:true,timetable}`. |
| `GET /teacher/:id` | Teacher ObjectId; populated entries. 200 `{success:true,timetable}`. |
| `PATCH /:id` | ObjectId plus the complete set of required timetable fields (same validation as create); conflict check excludes the current ID. 200 `{success:true,message,timetable}`; 400 invalid ID/data, 404 missing, 409 conflict, 500 error. |
| `DELETE /:id` | Timetable ObjectId. 200 `{success:true,message}`; 400 malformed ID, 404 missing, 500 error. |

All timetable error responses use `{success:false,message}`. There are no query
filters or pagination.

## Leave

All paths under `/api/leaves` are unauthenticated and have no role checks.

| Method and path | Request and behavior | Success / errors |
|---|---|---|
| `POST /` | Body passed directly to Leave model: `applicantId`, `applicantType` (`STUDENT` or `TEACHER`), `reason`, `fromDate`, `toDate`; optional status/approval fields follow schema defaults. | 201 `{success:true,message,leave}`; 500 schema/database error. |
| `GET /` | No filters; newest first. | 200 `{success:true,leaves}`; 500 error. |
| `PUT /:id/recommend` | Leave ObjectId. Sets `teacherApproval=true`, status `PENDING_HOD`. | 200 `{success:true,message,leave}`; 404 missing; 500 error. |
| `PUT /:id/approve` | Leave ObjectId. Sets `hodApproval=true`, status `APPROVED`, creates a notification for applicant. | 200 `{success:true,message,leave}`; 404 missing; 500 error. |
| `PUT /:id/reject` | Leave ObjectId. Sets status `REJECTED`. | 200 `{success:true,message,leave}`; 404 missing; 500 error. |

The route layer does not enforce the described student/teacher/HOD approval
roles.

## Notifications

All paths under `/api/notifications` are unauthenticated.

| Method and path | Request and behavior | Success / errors |
|---|---|---|
| `POST /` | Body passed directly to Notification model: `recipientId`, `recipientRole`, `title`, `message`; `isRead` defaults false. | 201 `{success:true,notification}`; 500 validation/database error. |
| `GET /:userId` | Recipient ID; results sorted newest first. No check that caller owns this ID. | 200 `{success:true,notifications}`; 500 error. |
| `PUT /:id/read` | Notification ObjectId; sets `isRead=true`. | 200 `{success:true,notification}` (may be null if absent); 500 error. |

## Upload

`POST /api/upload/avatar` is unauthenticated; it is distinct from the
authenticated Cloudinary endpoint `PUT /api/auth/avatar`.

| Method and path | Request and behavior | Success / errors |
|---|---|---|
| `POST /api/upload/avatar` | Multipart `avatar` file, max 5 MiB, JPEG/PNG/WebP. Optional body `userId`, `role`, `email`; controller synchronizes records by supplied IDs and/or email. Stores file under `/uploads/avatars/`. | 200 `{success:true,message,avatarUrl}`; 400 no file; 500 error. |

The optional identity fields are client-supplied on an unauthenticated route;
the route does not bind them to a verified user.

## Error contract and implementation caveats

Error objects usually contain `{ "success": false, "message": "..." }`, but
there is no single global error handler. Several controllers return raw
`error.message`; attendance controller uses generic internal errors and maps
cast errors to 404. Status codes and response fields vary by endpoint as
listed above. Do not assume one uniform validation or error shape.

The current routers do not implement a common request validator, pagination,
or global authentication. In particular, CRUD modules for Teachers, Batches,
Departments, Subjects, Timetables, Leaves and Notifications are publicly
reachable in the current route definitions.
