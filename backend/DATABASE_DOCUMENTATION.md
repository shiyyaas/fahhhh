# MongoDB / Mongoose data model

This reference reflects the model definitions in `models/`. Unless a schema
sets a collection option (none of these do), Mongoose derives a lowercase,
pluralized collection name from the model name. Collection names below are
therefore Mongoose's conventional names, not an explicit schema setting.
Every schema uses Mongoose's default `_id` and `__v`; all ten schemas enable
`createdAt` and `updatedAt` timestamps. The schemas define no pre/post hooks or
custom instance/static methods.

## Models

### User (`users`)

| Field | Type | Required | Default / constraints |
|---|---|---:|---|
| `name` | String | Yes | — |
| `email` | String | Yes | Unique; lowercase and trimmed |
| `password` | String | Yes | — |
| `role` | String | Yes | Enum: `HOD`, `TEACHER`, `STUDENT` |
| `department` | String | No | — |
| `phone` | String | No | — |
| `avatar` | String | No | `""` |
| `avatarPublicId` | String | No | `""` |
| `isActive` | Boolean | No | `true` |
| `resetPasswordToken` | String | No | `null` |
| `resetPasswordExpires` | Date | No | `null` |

No Student or Teacher ObjectId reference is defined on User. Application
controllers create/synchronize profiles by email. Password hashing occurs in
controllers, not a model hook. No model hooks or custom indexes are defined
here beyond the unique email constraint.

### Student (`students`)

| Field | Type | Required | Default / constraints |
|---|---|---:|---|
| `studentName` | String | Yes | — |
| `registerNo` | String | Yes | Unique |
| `email` | String | Yes | Unique |
| `password` | String | Yes | — |
| `phoneNo` | String | No | — |
| `apaarId` | String | No | — |
| `aadhaarEncrypted` | String | No | — |
| `avatar` | String | No | `""` |
| `batchId` | ObjectId, ref `Batch` | Yes | — |
| `department` | String | No | `"Computer Science"` |
| `role` | String | No | `"STUDENT"` |
| `isFirstLogin` | Boolean | No | `true` |
| `isActive` | Boolean | No | `true` |

`email` and `registerNo` have unique constraints. No direct reference to a User
is defined. Account-to-student resolution in attendance controllers uses
matching email as application logic.

### Teacher (`teachers`)

| Field | Type | Required | Default / constraints |
|---|---|---:|---|
| `teacherName` | String | Yes | Trimmed |
| `employeeId` | String | Yes | Unique, trimmed |
| `email` | String | Yes | Unique, lowercase, trimmed |
| `password` | String | Yes | — |
| `phoneNo` | String | No | — |
| `avatar` | String | No | `""` |
| `departments` | Array of ObjectId, ref `Department` | No | Mongoose array default |
| `role` | String | No | `"TEACHER"` |
| `isActive` | Boolean | No | `true` |

There is no direct User reference or Teacher-to-Batch field. Subject stores the
teacher assignment; attendance authorization resolves User to Teacher by
email, then uses subject and department/batch data.

### Department (`departments`)

| Field | Type | Required | Default / constraints |
|---|---|---:|---|
| `departmentName` | String | Yes | Unique, trimmed |
| `departmentCode` | String | Yes | Unique, uppercase, trimmed |
| `hodName` | String | Yes | Trimmed |
| `isActive` | Boolean | No | `true` |

There is no HOD User reference. Teacher and Subject may refer to Department;
Batch stores the department name as a string, not an ObjectId reference.

### Batch (`batches`)

| Field | Type | Required | Default / constraints |
|---|---|---:|---|
| `batchName` | String | Yes | Unique, trimmed |
| `program` | String | No | `"BCA"`, trimmed |
| `department` | String | Yes | Trimmed; no `ref` |
| `admissionYear` | Number | No | `2024` |
| `currentSemester` | Number | No | `1`, min 1, max 8 |
| `startYear` | Number | Yes | — |
| `endYear` | Number | Yes | — |
| `isActive` | Boolean | No | `true` |

Student, Attendance, and Timetable reference Batch. No relationship to Teacher
is declared.

### Subject (`subjects`)

| Field | Type | Required | Default / constraints |
|---|---|---:|---|
| `subjectName` | String | Yes | Trimmed |
| `subjectCode` | String | Yes | Unique, uppercase, trimmed |
| `departments` | Array of ObjectId, ref `Department` | No | Mongoose array default |
| `teachers` | Array of ObjectId, ref `Teacher` | No | Mongoose array default |
| `semester` | Number | Yes | Min 1, max 6 |
| `credits` | Number | No | `4` |
| `isActive` | Boolean | No | `true` |

### Attendance (`attendances`)

| Field | Type | Required | Default / constraints |
|---|---|---:|---|
| `student` | ObjectId, ref `Student` | Yes | — |
| `subject` | ObjectId, ref `Subject` | Yes | — |
| `teacher` | ObjectId, ref `Teacher` | Yes | — |
| `batch` | ObjectId, ref `Batch` | Yes | — |
| `date` | Date | No | `Date.now` |
| `status` | String | Yes | Enum: `Present`, `Absent`, `Late` |

Explicit unique compound index: `{ student: 1, subject: 1, batch: 1, date: 1 }`.
This is exact Date equality at the database index level; it does not intrinsically
express a calendar day. API writes normalize dates to local midnight, but
existing or direct writes with non-midnight times can still represent the same
calendar day as different indexed values.

No audit-history fields, correction reason, actor reference, or schema hooks are
defined.

### Timetable (`timetables`)

| Field | Type | Required | Default / constraints |
|---|---|---:|---|
| `batch` | ObjectId, ref `Batch` | Yes | — |
| `subject` | ObjectId, ref `Subject` | Yes | — |
| `teacher` | ObjectId, ref `Teacher` | Yes | — |
| `day` | String | Yes | Monday through Saturday |
| `startTime` | String | Yes | Controller validates 24-hour `HH:mm` |
| `endTime` | String | Yes | Controller validates `HH:mm` and later than start |
| `isActive` | Boolean | No | `true` |

Overlap checks are implemented in the controller for active entries sharing a
batch or teacher; there is no corresponding database unique/index constraint.

### Leave (`leaves`)

| Field | Type | Required | Default / constraints |
|---|---|---:|---|
| `applicantId` | ObjectId | Yes | No `ref` |
| `applicantType` | String | Yes | Enum `STUDENT`, `TEACHER` |
| `reason` | String | Yes | — |
| `fromDate` | Date | Yes | — |
| `toDate` | Date | Yes | — |
| `status` | String | No | Enum `PENDING_TEACHER`, `PENDING_HOD`, `APPROVED`, `REJECTED`; default `PENDING_TEACHER` |
| `teacherApproval` | Boolean | No | `false` |
| `hodApproval` | Boolean | No | `false` |
| `approvedBy` | ObjectId | No | `null`; no `ref` |

The schema does not declare Applicant/Approver references or date-order
validation. Approval stages and authorization are controller/route behavior,
not schema constraints. Mounted leave routes require JWT authentication;
HOD review routes additionally verify the applicant belongs to the HOD's
department.

### Notification (`notifications`)

| Field | Type | Required | Default / constraints |
|---|---|---:|---|
| `recipientId` | ObjectId | Yes | No `ref` |
| `recipientRole` | String | Yes | Enum `STUDENT`, `TEACHER`, `HOD` |
| `title` | String | Yes | — |
| `message` | String | Yes | — |
| `isRead` | Boolean | No | `false` |

No User reference or recipient ownership enforcement is defined by the schema.

## Relationships: declared references versus application logic

| Relationship | Implementation |
|---|---|
| Student → Batch | `Student.batchId` ObjectId ref |
| Teacher → Department | `Teacher.departments[]` ObjectId refs |
| Subject → Department | `Subject.departments[]` ObjectId refs |
| Subject → Teacher | `Subject.teachers[]` ObjectId refs |
| Attendance → Student / Subject / Teacher / Batch | ObjectId refs on each Attendance record |
| Timetable → Batch / Subject / Teacher | ObjectId refs |
| User ↔ Student / Teacher | No ObjectId references; profile controllers match email |
| Batch → Department | String name only, not a ref |
| Teacher → Batch | No direct ref/assignment field |
| Leave applicant/approver → User/profile | ObjectIds without `ref` |
| Notification recipient → User/profile | ObjectId without `ref` |

Mongoose `ref` enables population but does not itself enforce that referenced
documents exist. No cross-document foreign-key validation is configured.
Student batch authorization therefore performs an application-level check:
the authenticated User must resolve by email to a Student profile, the
referenced Batch must exist, and `Batch.department` must match
`Student.department`. Mismatches fail closed; this check does not migrate or
rewrite existing records.
