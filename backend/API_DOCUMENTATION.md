# API Documentation

This document describes all available backend API endpoints for the College ERP system. It reflects the current implementation in the **backend** directory.

---

## Authentication

| Method | URL | Description | Authentication | Allowed Roles |
|--------|-----|-------------|----------------|---------------|
| `POST` | `/api/auth/login` | User login – returns JWT token. | **None** (public) | N/A |
| `POST` | `/api/auth/forgot-password` | Request password reset email. | **None** | N/A |
| `POST` | `/api/auth/reset-password` | Reset password using token. | **None** | N/A |
| `PUT`  | `/api/auth/avatar` | Upload/replace user avatar. | **JWT** (`verifyToken`) | Any authenticated user |

---

## Attendance

| Method | URL | Description | Authentication | Allowed Roles |
|--------|-----|-------------|----------------|---------------|
| `POST` | `/api/attendance/mark` | Record a new attendance entry (Present/Absent/Late). | **JWT** | `TEACHER` |
| `PUT`  | `/api/attendance/update/:id` | Update an existing attendance record. | **JWT** | `TEACHER` |
| `DELETE` | `/api/attendance/delete/:id` | Delete an attendance record. | **JWT** | `TEACHER` |
| `GET`  | `/api/attendance/student/:id` | Retrieve all attendance for a student (overall & subject‑wise). | **JWT** | `ADMIN`, `HOD`, `STUDENT` |
| `GET`  | `/api/attendance/batch/:id` | Retrieve batch‑level attendance summary. | **JWT** | `ADMIN`, `HOD` |
| `GET`  | `/api/attendance/subject/:id` | Retrieve subject‑level attendance summary. | **JWT** | `ADMIN`, `HOD`, `TEACHER` |
| `GET`  | `/api/attendance/percentage/:studentId` | Get overall attendance percentage for a student. | **JWT** | `ADMIN`, `HOD`, `STUDENT` |
| `GET`  | `/api/attendance/defaulters` | List students falling below the shortage threshold. | **JWT** | `ADMIN`, `HOD` |
| `GET`  | `/api/attendance/report/student/:id` | Detailed student attendance report (aggregated). | **JWT** | `ADMIN`, `HOD`, `STUDENT` |

**Request body (mark / update)** (JSON):
```json
{
  "student": "<studentObjectId>",
  "subject": "<subjectObjectId>",
  "teacher": "<teacherObjectId>",
  "batch": "<batchObjectId>",
  "date": "2026-11-06",
  "status": "Present" // or "Absent" or "Late"
}
```

**Success response example** (`GET /api/attendance/student/:id`):
```json
{
  "success": true,
  "student": {
    "_id": "60f1c2...",
    "studentName": "John Doe",
    "registerNo": "2021001",
    "department": "Computer Science",
    "batch": "60e5b7...",
    "email": "john@example.com",
    "phoneNo": "1234567890"
  },
  "overall": {
    "totalClasses": 40,
    "present": 30,
    "late": 5,
    "absent": 5,
    "attendancePercentage": "87.50"
  },
  "subjects": [
    {
      "subjectId": "60f1d3...",
      "subjectName": "Data Structures",
      "totalClasses": 20,
      "present": 18,
      "late": 1,
      "absent": 1,
      "attendancePercentage": "95.00"
    }
  ]
}
```

---

## Students

| Method | URL | Description | Authentication | Allowed Roles |
|--------|-----|-------------|----------------|---------------|
| `POST` | `/api/students/` | Create a new student record. | **JWT** | `HOD` |
| `GET`  | `/api/students/` | List all students (with optional pagination). | **JWT** | `HOD`, `TEACHER` |
| `GET`  | `/api/students/:id` | Get details of a single student. | **JWT** | Any authenticated user (no role restriction) |
| `PUT`  | `/api/students/:id` | Update student information. | **JWT** | `HOD` |
| `DELETE`| `/api/students/:id` | Delete a student. | **JWT** | `HOD` |

**Request body (create / update)**:
```json
{
  "studentName": "Jane Doe",
  "registerNo": "2021002",
  "email": "jane@example.com",
  "password": "hashedPassword",
  "phoneNo": "9876543210",
  "batchId": "<batchObjectId>",
  "department": "Computer Science"
}
```
---

## Teachers

| Method | URL | Description | Authentication | Allowed Roles |
|--------|-----|-------------|----------------|---------------|
| `POST` | `/api/teachers/` | Create a teacher. | **JWT** | None (public in current code) |
| `GET`  | `/api/teachers/` | List teachers. | **JWT** | None |
| `GET`  | `/api/teachers/:id` | Get teacher details. | **JWT** | None |
| `PUT`  | `/api/teachers/:id` | Update teacher. | **JWT** | None |
| `DELETE`| `/api/teachers/:id` | Delete teacher. | **JWT** | None |
---

## Batches

| Method | URL | Description | Authentication | Allowed Roles |
|--------|-----|-------------|----------------|---------------|
| `POST` | `/api/batches/` | Create batch. | **None** (public) |
| `GET`  | `/api/batches/` | List batches. | **None** |
| `PUT`  | `/api/batches/:id/promote` | Promote batch to next semester. | **None** |
---

## Departments

| Method | URL | Description | Authentication | Allowed Roles |
|--------|-----|-------------|----------------|---------------|
| `POST` | `/api/departments/` | Create department. | **None** |
| `GET`  | `/api/departments/` | List departments. | **None** |
| `GET`  | `/api/departments/:id` | Get department details. | **None** |
| `PUT`  | `/api/departments/:id` | Update department. | **None** |
| `DELETE`| `/api/departments/:id` | Delete department. | **None** |
---

## Subjects

| Method | URL | Description | Authentication | Allowed Roles |
|--------|-----|-------------|----------------|---------------|
| `POST` | `/api/subjects/` | Create subject. | **None** |
| `GET`  | `/api/subjects/` | List subjects. | **None** |
| `GET`  | `/api/subjects/:id` | Get subject details. | **None** |
| `PUT`  | `/api/subjects/:id` | Update subject. | **None** |
| `DELETE`| `/api/subjects/:id` | Delete subject. | **None** |
---

## Timetable

| Method | URL | Description | Authentication | Allowed Roles |
|--------|-----|-------------|----------------|---------------|
| `POST` | `/api/timetables/` | Create timetable entry. | **None** |
| `GET`  | `/api/timetables/` | List all timetables. | **None** |
| `GET`  | `/api/timetables/batch/:id` | Get timetable for a batch. | **None** |
| `GET`  | `/api/timetables/teacher/:id` | Get timetable for a teacher. | **None** |
| `PATCH`| `/api/timetables/:id` | Update timetable entry. | **None** |
| `DELETE`| `/api/timetables/:id` | Delete timetable entry. | **None** |
---

## Leave Management

| Method | URL | Description | Authentication | Allowed Roles |
|--------|-----|-------------|----------------|---------------|
| `POST` | `/api/leaves/` | Apply for leave. | **None** |
| `GET`  | `/api/leaves/` | List leaves. | **None** |
| `PUT`  | `/api/leaves/:id/recommend` | Recommend a leave. | **None** |
| `PUT`  | `/api/leaves/:id/approve` | Approve a leave. | **None** |
| `PUT`  | `/api/leaves/:id/reject` | Reject a leave. | **None** |
---

## Notifications

| Method | URL | Description | Authentication | Allowed Roles |
|--------|-----|-------------|----------------|---------------|
| `POST` | `/api/notifications/` | Create a notification. | **None** |
| `GET`  | `/api/notifications/:userId` | Get notifications for a user. | **None** |
| `PUT`  | `/api/notifications/:id/read` | Mark notification as read. | **None** |
---

## Reports

| Method | URL | Description | Authentication | Allowed Roles |
|--------|-----|-------------|----------------|---------------|
| `GET` | `/api/reports/student/:studentId` | Generate PDF student report. | **None** |
| `GET` | `/api/reports/batch/:batchId` | Generate batch report. | **None** |
| `GET` | `/api/reports/subject/:subjectId` | Generate subject report. | **None** |
| `GET` | `/api/reports/student/:studentId/pdf` | Download student report PDF. | **None** |
| `GET` | `/api/reports/batch/:batchId/monthly-pdf` | Download monthly batch PDF. | **None** |
| `GET` | `/api/reports/batch/:batchId/monthly-preview` | Preview monthly batch report. | **None** |
---

## Dashboard

| Method | URL | Description | Authentication | Allowed Roles |
|--------|-----|-------------|----------------|---------------|
| `GET` | `/api/dashboard/hod` | HOD dashboard data. | **None** |
| `GET` | `/api/dashboard/teacher/:teacherId` | Teacher dashboard data. | **None** |
| `GET` | `/api/dashboard/student/:studentId` | Student dashboard data. | **None** |
---

## Miscellaneous

- All routes are prefixed with `/api/<module>` as shown above.
- The server uses **Helmet**, **rate limiting**, **CORS** (configured in `middleware/`), and **input validation** (via `validation.js`).
- Errors are returned in the shape `{ success: false, message: "<error description>" }` with appropriate HTTP status codes (400, 401, 403, 404, 500).

---

*For any changes to the API, the documentation should be updated accordingly.*
