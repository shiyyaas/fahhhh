# Backend role/permission matrix

This matrix reflects the Phase 9 routes and controller ownership checks.
Resource permissions are limited to the caller's own profile, assignments, or
department where those relationships are available in the database.

| Permission area | Student | Teacher | Class Teacher | HOD | Admin |
|---|---|---|---|---|---|
| Login/authentication | Allowed | Allowed | Not implemented | Allowed | Not implemented |
| Student profile access | Restricted to self | Not implemented | Not implemented | Restricted to own department | Not implemented |
| Attendance viewing | Restricted to self | Restricted to assigned subject | Not implemented | Restricted to own department | Not implemented |
| Attendance marking | Not implemented | Restricted to assigned subject and matching department/batch | Not implemented | Not implemented | Not implemented |
| Attendance updating | Not implemented | Restricted to records created/managed by self and current assignment | Not implemented | Not implemented | Not implemented |
| Attendance deletion | Not implemented | Restricted to records created/managed by self and current assignment | Not implemented | Not implemented | Not implemented |
| Department reads | Own department only | Assigned departments only | Not implemented | Own department only | Not implemented |
| Subject access | Own department | Assigned subjects within assigned departments | Not implemented | Own department | Not implemented |
| Batch access | Restricted to own batch | Restricted to assigned departments | Not implemented | Restricted to own department | Not implemented |
| Dashboard access | Restricted to self | Restricted to self | Not implemented | Restricted to own department | Not implemented |
| Reports | Restricted to self | Not implemented | Not implemented | Restricted to own department | Not implemented |
| Timetable | Restricted to own batch | Restricted to own schedule | Not implemented | Restricted to own department | Not implemented |
| Leave | Apply/read own requests | Apply/read own requests | Not implemented | Read/approve/reject own department | Not implemented |
| Notifications | Read/mark own | Read/mark own | Not implemented | Create for own department; read/mark own | Not implemented |
| Attendance issue management | Not implemented | Not implemented | Not implemented | Not implemented | Not implemented |
| Avatar update | Allowed for own account | Allowed for own account | Not implemented | Allowed for own account | Not implemented |

## Route behavior and limitations

- The User schema and login support only `STUDENT`, `TEACHER`, and `HOD`.
  There is no `CLASS_TEACHER` or `ADMIN` role. ADMIN access previously listed
  on attendance routes was removed.
- All administrative mutations require JWT and HOD role. HOD operations that
  target an existing resource additionally verify department ownership.
- HOD department scoping uses `User.department` and Department name matching.
  Students are associated by email with Student profiles; teachers are
  associated by email with Teacher profiles. A missing or ambiguous profile
  or department mapping fails closed.
- Students can access only their own student profile, attendance, percentage,
  report, dashboard, timetable batch, leave requests, notifications, and
  avatar. Department reads are limited to the department on their linked
  Student profile, and the profile's batch must exist in that same department.
  They cannot list the student directory or mutate administrative resources.
- Teachers can mark, update, and delete attendance only after profile
  resolution and subject/department/batch checks. They cannot access batch
  attendance or administrative CRUD. No direct Teacher-to-Batch assignment
  exists; teacher batch scope is derived from assigned subject/department.
- The leave schema has no teacher-to-student advising relationship. Therefore,
  approval/recommendation mutations are restricted to same-department HOD
  rather than inferring a teacher's authority over a leave applicant.
- HOD subject reads are limited to their department. Teacher subject reads
  require both an assigned department and the teacher's ID in the subject's
  `teachers` list. Student subject reads are limited to their profile
  department. Teacher data populated by subject endpoints is limited to
  `teacherName` and `avatar`.
- Department list/detail reads are limited to the HOD's department, a teacher's
  assigned departments, or the student's linked profile department. Missing or
  inconsistent associations fail closed.
- Student batch and timetable reads require the authenticated User email to
  resolve to a Student profile and require that profile's batch to exist with
  a department matching the profile department.
- `controllers/uploadController.js` is legacy and is not mounted. It trusts
  caller-supplied identity fields and does not validate image signatures; do
  not mount or reuse it without equivalent authentication, ownership, and
  file validation. The mounted upload routes use the JWT-bound avatar handler.
- Avatar APIs require JWT and update the authenticated account only.
  `GET /uploads/*` remains public static content to support existing image
  URLs; files there should be considered public.
- Public API endpoints are limited to login, forgot-password, reset-password,
  the plain-text root health endpoint, and static uploaded-file reads. The
  server accepts requests without an `Origin` header; browser CORS origins
  must be listed in `CORS_ORIGINS`.

For exact routes and response shapes, see [API_DOCUMENTATION.md](./API_DOCUMENTATION.md).
