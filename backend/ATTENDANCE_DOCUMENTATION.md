# Attendance Documentation

## Overview
The Attendance module enables teachers to record attendance for students and provides comprehensive reporting for students, batches, and subjects. It supports three status values: **Present**, **Absent**, and **Late**.

---

## Endpoints

| Method | URL | Controller | Auth Middleware | Allowed Roles | Description |
|--------|-----|------------|----------------|---------------|-------------|
| `POST` | `/api/attendance/mark` | `markAttendance` | `verifyToken` | `TEACHER` | Record a new attendance entry (creates or updates to avoid duplicates). |
| `PUT`  | `/api/attendance/update/:id` | `updateAttendance` | `verifyToken` | `TEACHER` | Update an existing attendance record by its MongoDB `_id`. |
| `DELETE`| `/api/attendance/delete/:id` | `deleteAttendance` | `verifyToken` | `TEACHER` | Delete an attendance record. |
| `GET`  | `/api/attendance/student/:id` | `getStudentAttendance` | `verifyToken` | `ADMIN`, `HOD`, `STUDENT` | Retrieve all raw attendance entries for a specific student. |
| `GET`  | `/api/attendance/batch/:id` | `getBatchAttendance` | `verifyToken` | `ADMIN`, `HOD` | Retrieve attendance for all students in a batch. |
| `GET`  | `/api/attendance/subject/:id` | `getSubjectAttendance` | `verifyToken` | `ADMIN`, `HOD`, `TEACHER` | Retrieve attendance for a specific subject across all batches. |
| `GET`  | `/api/attendance/percentage/:studentId` | `getAttendancePercentage` | `verifyToken` | `ADMIN`, `HOD`, `STUDENT` | Compute overall attendance percentage for a student (Present only, Late ignored). |
| `GET`  | `/api/attendance/defaulters` | `getDefaulters` | `verifyToken` | `ADMIN`, `HOD` | List students whose overall attendance is below **75 %** (hard‑coded warning threshold). |
| `GET`  | `/api/attendance/report/student/:id` | `getStudentReport` | `verifyToken` | `ADMIN`, `HOD`, `STUDENT` | Detailed aggregated report (overall + subject‑wise percentages, Late handling). |

---

## Request Payloads

### `markAttendance` (POST `/mark`)
```json
{
  "student": "<ObjectId>",
  "subject": "<ObjectId>",
  "teacher": "<ObjectId>",
  "batch": "<ObjectId>",
  "date": "2026-11-06",   // optional, defaults to today
  "status": "Present"   // or "Absent" or "Late"
}
```
- **Duplicate prevention**: The controller uses a compound unique index (student, subject, batch, date). If an entry already exists for the same day, it is **upserted** (updated) rather than creating a duplicate.

### `updateAttendance` (PUT `/update/:id`)
```json
{
  "student": "<ObjectId>",
  "subject": "<ObjectId>",
  "teacher": "<ObjectId>",
  "batch": "<ObjectId>",
  "date": "2026-11-06",
  "status": "Late"
}
```
- All fields are optional; only provided fields will be overwritten.

### `deleteAttendance` (DELETE `/delete/:id`)
- No request body; the `id` path parameter is the attendance document `_id`.

---

## Response Structures

All successful responses share the common shape `{ "success": true, ... }`. Errors follow `{ "success": false, "message": "..." }` with appropriate HTTP status codes (400, 401, 403, 404, 500).

### Successful `markAttendance`
```json
{
  "success": true,
  "message": "Attendance marked successfully",
  "attendance": { /* attendance document */ }
}
```

### Successful `getStudentReport`
```json
{
  "success": true,
  "student": {
    "_id": "...",
    "studentName": "John Doe",
    "registerNo": "2021001",
    "department": "Computer Science",
    "batch": "...",
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
      "subjectId": "...",
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
- The **late policy** is controlled by the environment variable `LATE_AS` (`present`, `partial`, `absent`). The default treats Late as Present.

### `getDefaulters`
```json
{
  "success": true,
  "totalDefaulters": 3,
  "defaulters": [
    {
      "studentId": "...",
      "studentName": "Alice",
      "registerNo": "2021003",
      "attendancePercentage": "68.75"
    }
  ]
}
```
- The threshold is hard‑coded to **75 %**. To change it, modify the controller logic or introduce a configurable env variable.

---

## Attendance Calculations

1. **Effective Present** – calculated by `effectivePresent(present, late, policy)`:
   - `present` + `late`                                                                                                                                                                                                                                                                                   **(policy values)**
   - `present` + `late` × 0.5                                                                                                                                                                                                                                                                                                                                                 **expressed**
   - `present`                                                                                                                                                                                                                                                                                                                          **(policy values)**
   - The policy is read from `process.env.LATE_AS` (defaults to `present`).
2. **Overall Percentage** – `effectivePresent / totalClasses * 100` (rounded to two decimals).
3. **Subject‑wise Percentage** – same calculation per subject.
4. **Defaulters** – students with `(present / total) * 100 < 75` (hard‑coded). The controller currently counts only **Present** status; Late is ignored unless the `LATE_AS` policy is `present`.

---

## Configuration (Environment Variables)

| Variable | Purpose | Default |
|----------|---------|---------|
| `LATE_AS` | Determines how Late records affect the present count. Accepts `present`, `partial`, or `absent`. | `present` |
| `JWT_SECRET` | Secret for JWT verification (used by auth middleware). | – |

---

## Pagination & Filtering
*The current implementation does not include pagination on attendance list endpoints. If needed, add `limit` & `page` query parameters and modify controller queries accordingly.*

---

## CSV Export
*There is no dedicated CSV export endpoint for attendance in the current codebase. The generic `utils/csvExport.js` utility exists but is not wired to a route.*

---

## Summary of Missing / Unimplemented Features
- Configurable shortage/warning thresholds (currently hard‑coded to 75 %).
- Pagination on list endpoints.
- CSV export for attendance reports.
- Role‑based constraints for teachers updating only their own subjects/batches (mentioned in comments but not enforced).

---

*All documentation reflects the actual code; any future changes should be mirrored here.*
