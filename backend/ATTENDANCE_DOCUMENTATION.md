# Attendance behavior and calculation rules

This document describes the current implementation in
`controllers/attendanceController.js`, `controllers/reportController.js`,
`controllers/dashboardController.js`, the Attendance schema, and
`utils/attendanceCalculations.js`.

## Status values and policies

Attendance status is case-sensitive and limited by the Mongoose enum to
`Present`, `Absent`, or `Late`.

The shared calculator uses `process.env.LATE_AS`, defaulting to `present`.

| `LATE_AS` | Effective present count |
|---|---|
| `present` (default) | `Present + Late` |
| `partial` | `Present + (Late × 0.5)` |
| `absent` | `Present` |

Unknown non-empty policy strings follow the helper's default branch and count
Late as fully present; deployments should use one of the three named values.

## Formula, rounding, and examples

```text
effectivePresent = helper(Present count, Late count, LATE_AS)
attendance percentage = effectivePresent / all attendance records × 100
```

`Absent` records are included in the denominator and contribute zero.
Percentage response fields formatted as strings use two decimal places. The
dashboard defaulter comparison uses the unrounded calculation. Zero records
return numeric `0` in the Attendance percentage endpoint; other formatted
report fields can return `"0.00"`.

For 2 Present, 1 Late, 0 Absent (3 records):

| Policy | Effective present | Percentage |
|---|---:|---:|
| `present` | 3 | 100.00% |
| `partial` | 2.5 | 83.33% |
| `absent` | 2 | 66.67% |

For 0 records, the percentage is 0. For only 4 Absent records, all policies
produce 0%. For 3 Late-only records, policies produce 100%, 50%, or 0%,
respectively.

## How reports apply calculations

- **Student detailed report** (`GET /api/attendance/report/student/:id`):
  one overall aggregation and subject aggregation; each uses the same helper
  and total record count.
- **Student percentage** (`GET /api/attendance/percentage/:studentId`) and
  **defaulters** (`GET /api/attendance/defaulters`): count each status and use
  the shared policy. Defaulter criterion is strictly `< 75%`.
- **Student, batch and subject JSON reports** (`/api/reports/...`): use shared
  helper; add Late counts to response. Percentages include all attendance
  records in the total.
- **Student PDF report**: prints counts for Present/Late/Absent and uses shared
  helper for attendance percentage.
- **Monthly batch preview and download PDFs**: aggregate counts for Present,
  Late and total records in the selected month; each student row and the
  overall weighted average use the shared policy. The effective count column
  is labeled `Effective`.
- **Student dashboard** uses the shared calculation. **HOD dashboard** uses
  the same calculation and counts only students with at least one record as
  defaulters.

These are record-count percentages, not percentages of scheduled class
sessions. No holiday, excused absence, or per-subject credit weighting exists.

## Marking, date identity, and duplicate behavior

`POST /api/attendance/mark` requires `student`, `subject`, `batch`, and a
valid status. `date` is optional and defaults to the current time. The
authenticated teacher profile (resolved by User email) supplies the stored
teacher ID; a client-supplied teacher ID is not trusted.

The target student must belong to the supplied batch, the teacher must be
assigned to the subject, and the subject/teacher departments must match the
batch department through current model relationships.

The submitted date is normalized to **local server midnight** for storage.
The upsert filter spans local `00:00:00.000` through `23:59:59.999`, for the
same student + subject + batch. Re-marking that combination on the same local
calendar day updates its existing record. This local-time interpretation can
differ from a client using UTC dates near midnight.

The Attendance schema's unique index is
`{ student, subject, batch, date }`. It indexes the precise Date value, not a
calendar-day expression. Normalized API writes align with same-day behavior;
legacy records and direct database writes with varying times can still evade
day-level equivalence. Concurrent same-day upserts can race: a duplicate-key
error is returned as HTTP 409, rather than automatically retried.

`PUT /api/attendance/update/:id` validates status/date and reauthorizes the
teacher and target. It normalizes the date and checks for another record with
the same student/subject/batch/date day; collision returns HTTP 409. It saves
the existing record and does not create an upsert. `DELETE` removes the record;
reports then reflect the remaining records.

Malformed attendance IDs are mapped to 404 by the attendance error handler.
Missing required fields, invalid status, or invalid date return 400. Missing
student or batch references return 404; an unassigned subject/department is
denied. Mongoose references do not provide database-level foreign-key checks.

## Authorization

- JWT middleware protects all Attendance routes.
- Student callers on attendance history, percentage, and detailed report are
  resolved to a unique Student profile by matching authenticated User email;
  they may access only that profile's ID.
- Teachers marking/updating/deleting are resolved to Teacher by email.
  Subject assignment and department/student-batch relationships are checked.
- Teachers reading a subject are restricted to assigned subjects and matching
  department batches.
- Admin/HOD role allowances are defined per route in
  [API_DOCUMENTATION.md](./API_DOCUMENTATION.md). `ADMIN` is permitted in some
  route middleware, but is not an allowed User schema/login role.

No direct User-to-profile or Teacher-to-Batch reference exists. Email matching
is application-level; there is no direct class-teacher assignment.

## Known limitations and auditability

- The HOD dashboard excludes zero-record students from its defaulter count;
  the attendance defaulter list includes them with 0% and therefore lists
  them. Both use the same 75% threshold but differ on this edge case.
- Attendance update/delete history is not persisted. The schema has no
  original status, correction reason, updated-by actor, or immutable history.
  `updatedAt` is overwritten on update and deletion removes the record.
- A smallest future audit implementation should append an immutable correction
  event (attendance ID, before/after status and date, actor, timestamp, reason,
  action) in a separately approved schema/transaction design. This phase does
  not add it.
- No attendance bulk endpoint, calendar-day database constraint, or historical
  record normalization/migration is implemented.
