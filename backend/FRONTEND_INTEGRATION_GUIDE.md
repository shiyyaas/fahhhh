# Backend integration guide (Flutter client reference)

This is backend documentation only. Examples are illustrative and reflect
routes that exist in the current backend; they do not imply that a Flutter
dependency or client implementation is present.

## Backend setup and base URL

From `backend/`, install the dependencies from the existing package lockfile,
then run `npm run dev` for nodemon or `npm start` for the production script.
The server loads dotenv, requires a `JWT_SECRET` of at least 32 bytes, connects
to MongoDB, and listens on `PORT` or `5000`. Configure browser origins in
`CORS_ORIGINS` as a comma-separated exact-origin allowlist. Do not copy server
secrets into a mobile application.

Use the deployment's HTTPS base URL in a release build. Local emulator/device
network routing differs by platform; set the host in client configuration.
All JSON API routes use paths beginning `/api/`. For example:

```text
http://localhost:5000/api/attendance
```

`GET /` is a plain-text health response, not JSON.

## Login and JWT requests

Send `POST /api/auth/login` with JSON:

```json
{ "email": "student@example.test", "password": "<password>" }
```

On success, response fields include `success`, `message`, `token`, and a
non-secret `user` summary (`id`, `name`, `email`, `role`, `department`,
`phone`, `avatar`). JWTs last seven days. The token carries `userId` and
`role`; the backend provides no refresh-token endpoint.

For protected routes, send:

```http
Authorization: Bearer <JWT>
Content-Type: application/json
```

The route middleware responds with HTTP 401 for a missing, invalid, or expired
token and HTTP 403 for a role/resource disallowed by the route. Login and
password reset endpoints allow up to 10 requests per client IP per 15-minute
window. Consult [ROLE_PERMISSION_MATRIX.md](./ROLE_PERMISSION_MATRIX.md) for
role and department scopes.

Illustrative Dart request using `package:http`:

```dart
final response = await http.get(
  Uri.parse('$baseUrl/api/attendance/student/$studentId'),
  headers: {
    'Authorization': 'Bearer $jwt',
    'Accept': 'application/json',
  },
);
```

The backend does not prescribe a client token-storage mechanism. Store tokens
using an appropriate platform secure-storage mechanism and avoid logging them.

## Attendance requests and responses

Teacher attendance marking uses `POST /api/attendance/mark`:

```dart
final response = await http.post(
  Uri.parse('$baseUrl/api/attendance/mark'),
  headers: {
    'Authorization': 'Bearer $jwt',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'student': studentId,
    'subject': subjectId,
    'batch': batchId,
    'date': '2026-11-06',
    'status': 'Present',
  }),
);
```

The body requires `student`, `subject`, `batch`, and one of the case-sensitive
statuses `Present`, `Absent`, or `Late`. `date` is optional; the authenticated
teacher is resolved server-side, so a body `teacher` field is not authoritative.
Success is HTTP 200 with `{success:true,message,attendance}`. Marking is an
upsert for the same student/subject/batch on a local calendar day.

Other useful endpoints:

- `GET /api/attendance/student/:id` — `{success,attendance}`.
- `GET /api/attendance/percentage/:studentId` —
  `{success,totalClasses,presentClasses,lateClasses,absentClasses,attendancePercentage}`.
- `GET /api/attendance/report/student/:id` — detailed student and subject
  summaries.
- `GET /api/attendance/subject/:id` and `/api/attendance/batch/:id` — records
  with populated fields.

There is no bulk-mark endpoint and no pagination/date-filter query on these
attendance endpoints.
Administrative writes require HOD authorization and are department-scoped.
Student and teacher profiles are resolved from authenticated User email; do not
assume User and profile IDs are interchangeable.

## Interpreting percentages and dates

`LATE_AS` on the server controls Late calculations:

- `present` (default): Late counts fully.
- `partial`: Late counts as one half.
- `absent`: Late counts as zero.

Absent records remain in the denominator. A formatted value such as `"83.33"`
is a percentage string, not a fraction; zero attendance may be numeric `0` in
the direct percentage endpoint and `"0.00"` in formatted reports.

Marking accepts a date value that JavaScript can parse. The backend normalizes
it to midnight in the **server's local timezone** and uses that local
calendar-day range to find/upsert a record. JavaScript parses a date-only ISO
string (`YYYY-MM-DD`) as UTC before the controller normalizes it locally; on a
server west of UTC this can resolve to the previous local day. A UTC timestamp
close to midnight can also cross a server-local day. Confirm the deployment
timezone and send dates that resolve to the intended local calendar date. The
API does not provide a common date serialization policy for every model
endpoint.

## Errors and content types

Most JSON errors have `{success:false,message}`. Common attendance statuses:

- 400: missing required marking field, invalid status, or invalid date.
- 401: missing/invalid JWT on a protected route.
- 403: role/resource authorization denial.
- 404: missing record or malformed attendance ObjectId in attendance handlers.
- 409: same-day update collision or duplicate-key conflict.
- 500: unexpected server error.

Other controllers may use different fields/status codes. Handle errors by HTTP
status and parse the body defensively; do not assume one universal error
schema. Unexpected errors use generic messages. Monthly reports and PDF endpoints return
`application/pdf` when a PDF is generated; save/read response bytes instead of
decoding as JSON. Empty monthly batches return JSON.

## Uploads

- `PUT /api/auth/avatar`: JWT-protected multipart field `avatar`; Cloudinary
  upload. Accepts JPEG/PNG/WebP up to 5 MiB and validates the file signature.
  The target account is always the authenticated user.
- `POST /api/upload/avatar`: authenticated alias to the same handler and
  contract; it does not accept caller-selected `userId` or email.
- `GET /uploads/*`: public static files; treat these URLs as public.

## Known integration limitations

- Department scoping relies on the current text `User.department` and
  Department name; profile association is email-based. If the relationship
  cannot be resolved, access fails closed.
- Department reads return only the HOD department, departments linked to the
  teacher profile, or the student's profile department. Subject reads for
  teachers additionally require the subject to list their Teacher profile ID
  in `teachers`; students and HODs remain department-scoped.
- Student batch and timetable access requires a valid linked Student profile
  and a batch whose department matches that profile. Inconsistent mappings are
  denied; clients must not infer batch access from a submitted ID.
- A HOD cannot rename the department name through the department update API;
  that name is currently used as the cross-model scope key.
- No direct Teacher-to-Batch or teacher-to-leave-advisor relationship exists.
  Teacher authorization is derived from assigned subjects/departments.
- Existing static uploads are public by design. Authenticated avatar updates
  affect only the account in the JWT.
- The legacy `controllers/uploadController.js` is not mounted and must not be
  reused without authentication, ownership, and image-signature checks.
- There is no Class Teacher role, direct Teacher-to-Batch mapping, refresh
  token, pagination, general attendance date filter, or bulk attendance API.
- Response population and error field shapes vary by endpoint. Attendance
  history, batch attendance, and subject attendance use explicit allowlists;
  other profile CRUD responses have different projections.

For exact inputs, response fields, and permissions for every mounted route,
see [API_DOCUMENTATION.md](./API_DOCUMENTATION.md).
