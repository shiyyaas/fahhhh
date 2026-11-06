# Backend role/permission matrix

This matrix reflects route middleware and controller checks, not intended
institutional policy. “Allowed” means an implemented route permits the role
or is public; public routes are also usable without a role or token.
“Restricted” means only specified routes/actions are available or a resource
check is applied. “Not implemented” means no corresponding route/role feature
exists. “Not verified” means code does not establish a safe role-specific
permission.

| Permission area | Student | Teacher | Class Teacher | HOD | Admin |
|---|---|---|---|---|---|
| Login/authentication | Allowed | Allowed | Not implemented | Allowed | Not implemented |
| Student profile access | Restricted | Allowed | Not implemented | Allowed | Not verified |
| Attendance viewing | Restricted | Restricted | Not implemented | Allowed | Restricted |
| Attendance marking | Not implemented | Restricted | Not implemented | Not implemented | Not implemented |
| Attendance updating | Not implemented | Restricted | Not implemented | Not implemented | Not implemented |
| Attendance deletion | Not implemented | Restricted | Not implemented | Not implemented | Not implemented |
| Subject access | Allowed | Allowed | Not implemented | Allowed | Allowed |
| Batch access | Allowed | Allowed | Not implemented | Allowed | Allowed |
| Dashboard access | Allowed | Allowed | Not implemented | Allowed | Allowed |
| Reports | Allowed | Allowed | Not implemented | Allowed | Allowed |
| Timetable | Allowed | Allowed | Not implemented | Allowed | Allowed |
| Leave | Allowed | Allowed | Not implemented | Allowed | Allowed |
| Notifications | Allowed | Allowed | Not implemented | Allowed | Allowed |
| Attendance issue management | Not implemented | Not implemented | Not implemented | Not implemented | Not implemented |

## Route-level interpretation and limitations

- The only roles defined by the User schema and accepted by login are `STUDENT`,
  `TEACHER`, and `HOD`. There is no `CLASS_TEACHER` or `ADMIN` schema role.
  Attendance route middleware nevertheless names `ADMIN` for selected reads;
  that role requires a token issued outside the current login implementation.
- Student attendance history, percentage, and detailed attendance report are
  role-restricted and the controller resolves Student by authenticated User
  email, then limits student users to their own profile. The separate
  `GET /api/students/:id` profile route accepts any valid JWT and does not
  check ownership.
- Teachers can mark/update/delete attendance only after controller-level
  profile, subject, and student/batch/department checks. Teacher profile
  association is email-based. No direct Teacher-to-Batch assignment exists.
- Teacher attendance viewing is limited to subjects assigned through
  `Subject.teachers` plus department/batch matching. Teacher batch-attendance
  route is not permitted.
- The displayed `Allowed` entries for Subjects, Batches, Dashboards, Reports,
  Timetable, Leave and Notifications reflect routes that have no authentication
  or role middleware. They do **not** mean secure role-scoped access; those
  endpoints are publicly reachable.
- Teacher CRUD routes are likewise public. HOD is the only role check on
  Student create/update/delete, and list access is HOD/Teacher.
- Leave stage names and controller operations suggest an approval flow, but
  its routes do not authenticate or enforce Student/Teacher/HOD roles.
- Notification retrieval accepts a caller-provided recipient ID and does not
  verify ownership.
- `POST /api/upload/avatar` is public and accepts caller-supplied profile IDs
  and/or email. By contrast, `PUT /api/auth/avatar` requires JWT.
- “Not implemented” is not a statement that a role is forbidden by a business
  policy; it means no corresponding dedicated permission implementation was
  found.

See [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) for all actual paths and
per-route middleware.
