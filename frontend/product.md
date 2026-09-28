# Attendance App — Product Requirements Document

> Product specification derived from the complete Figma file. Requirements marked **Inferred** are implied by the interface but require stakeholder confirmation.

## 1. Analysis Coverage

Every page in the Figma file was reviewed.

| Page | Reviewed scope | Approx. nodes |
| --- | --- | ---: |
| Components & Assets | Navigation, lists, dropdowns, charts, notifications, buttons, tables, inputs, keyboard, and shared states | 2,374 |
| Student | Login, home, attendance, issue reporting, subjects, timetable, history, notifications, and profile | 3,253 |
| Teacher | Login, attendance capture, classes, subjects, reports, student profiles, timetable, and profile | 5,229 |
| HOD - Admin | Login, department management, classes, teachers, subjects, reports, inbox, timetable, and profile | 14,742 |
| Complete | Consolidated HOD and non-HOD class-teacher variants | 2,663 |

The role-specific pages provide the detailed product flows. The Complete page confirms two teacher variants:

- Teacher who is also an HOD
- Class teacher who is not an HOD

## 2. Product Summary

The Attendance App is a mobile-first attendance management system for educational institutions.

It centralizes:

- Daily attendance capture
- Student attendance visibility
- Timetable management
- Attendance analytics
- Report generation
- Attendance issue resolution
- Department administration

The product supports three primary user groups:

1. Students
2. Teachers and class teachers
3. Heads of department and administrators

## 3. Product Problem

Educational attendance workflows are often fragmented across paper registers, spreadsheets, informal messages, and separate reporting systems.

This creates several problems:

- Teachers spend excessive time recording and correcting attendance.
- Students have limited visibility into their attendance.
- Attendance disputes are difficult to track and resolve.
- Class teachers and HODs lack a consolidated view of attendance risk.
- Timetable changes and teacher swaps are difficult to coordinate.
- Reports require repetitive manual preparation.

## 4. Product Vision

Provide one role-aware application where every attendance event can be recorded, reviewed, analyzed, corrected, and reported with clear accountability.

## 5. Product Goals

- Make daily attendance fast to record.
- Give students transparent and timely attendance information.
- Help teachers identify attendance risks.
- Give HODs department-wide visibility and control.
- Provide a traceable attendance-correction workflow.
- Support timetable change requests.
- Reduce manual report preparation.
- Support multiple classes, batches, subjects, and teachers.

## 6. Non-Goals

## 7. Users and Roles

### 7.1 Student

A student needs to:

- Review today’s classes.
- View attendance status for each session.
- Review subject-level attendance.
- Review overall attendance.
- View attendance history by date or month.
- Report an incorrect attendance record.
- Track the outcome of an attendance issue.
- View their timetable.
- Manage profile and application settings.

### 7.2 Teacher

A teacher needs to:

- Review today’s teaching schedule.
- Record attendance for assigned sessions.
- Update individual student attendance.
- Mark an entire roster with one status.
- Review assigned subjects.
- View class lists.
- View student attendance profiles.
- Analyze subject-level attendance.
- Preview and download reports.
- Review timetable information.
- Request timetable or teacher swaps.

### 7.3 Class Teacher

A class teacher has teacher capabilities plus responsibility for a specific class.

Additional needs include:

- Review all students in the assigned class.
- Review class-wide attendance trends.
- View subject attendance for the class.
- Generate class attendance reports.
- Review attendance history.
- Review condonation information.

### 7.4 HOD / Department Admin

An HOD has teacher capabilities plus department administration.

Additional needs include:

- Review department classes.
- Review department teachers.
- Manage teacher records and assignments.
- Manage class and subject information.
- Review attendance across the department.
- Manage timetables.
- Review teacher swap requests.
- Review student attendance issues.
- Accept, reject, verify, or correct requests.
- Manage archived batches.

## 8. Permission Matrix

| Capability | Student | Teacher | Class Teacher | HOD/Admin |
| --- | :---: | :---: | :---: | :---: |
| View own attendance | Yes | No | No | No |
| Report own attendance issue | Yes | No | No | No |
| Record session attendance | No | Yes | Yes | Yes |
| View assigned subjects | Yes | Yes | Yes | Yes |
| View student profile | No | Yes | Yes | Yes |
| View assigned class | No | Limited | Yes | Yes |
| Generate class reports | No | Limited | Yes | Yes |
| Review condonation list | No | Limited | Yes | Yes |
| Request timetable swap | No | Yes | Yes | Yes |
| Review own requests | Yes | Yes | Yes | Yes |
| Review all attendance issues | No | Limited | Limited | Yes |
| Manage department classes | No | No | No | Yes |
| Manage teachers | No | No | No | Yes |
| Manage department timetable | No | No | No | Yes |
| Manage archived batches | No | No | No | Yes |

> **Inferred:** Exact permission boundaries between Teacher, Class Teacher, and HOD require confirmation.

## 9. Navigation Model

### Student Navigation

- Home
- Subjects
- Profile

### Teacher Navigation

- Home
- Class
- Subjects
- Profile

### HOD Navigation

- Department
- Home
- Class
- Subjects
- Profile

Navigation should be generated from the authenticated user’s roles and permissions.

## 10. Functional Requirements

### 10.1 Authentication

The product must provide:

- Loading or launch state
- Email-address input
- Password input
- Login action
- Forgot-password entry point
- Role-aware routing
- Logout

The following require additional definition:

- Password-reset flow
- First-time account activation
- Multi-factor authentication
- Session timeout
- Locked-account handling
- Invalid-login states
- Network-error states

### 10.2 Student Home

The student home must display:

- Current date
- Today’s timetable
- Calendar or day selector
- Subject name
- Teacher name
- Session time
- Attendance status
- Notifications
- Inbox or request access

Student attendance states shown in the designs:

- Present
- Late
- Absent
- Ongoing
- Pending

### 10.3 Attendance Issue Reporting

A student must be able to report an incorrect attendance record.

The flow must support:

1. Select the affected attendance session.
2. Open “Report Attendance Issue.”
3. Select a reason.
4. Submit the report.
5. Receive a review outcome.

Reasons shown in the designs:

- Mistakenly marked absent
- Mistakenly marked late
- Present but not recorded

Possible outcomes:

- Under review
- Rejected
- Verified and corrected

The outcome should identify the affected session and explain the next action.

### 10.4 Teacher Attendance Capture

Teachers must be able to:

- Open an assigned class session.
- View class and subject context.
- View the student roster.
- Search students.
- Sort students.
- Assign attendance to individual students.
- Apply one status to all students.
- Save the attendance record.

Bulk options shown in the designs:

- All Present
- All Late
- All Absent

Attendance must not be considered recorded until the teacher completes the save action.

> **Inferred:** The system should warn users about unsaved changes and confirm overwriting an existing record.

### 10.5 Session Status

Teacher subject sessions use these states:

- Pending
- Record Now
- Recorded
- Missed

Recommended lifecycle:

`Pending → Record Now → Recorded`

A session becomes `Missed` when its attendance window expires without a completed record.

> **Inferred:** The exact attendance window and late-edit rules require confirmation.

### 10.6 Subjects

The subjects module must support:

- Subject list
- Assigned class or batch
- Teacher information
- Student roster
- Attendance percentage
- Attendance analysis
- Attendance history
- Search
- Sorting
- Class selection where a subject is shared across classes

### 10.7 Classes

The class module must support:

- Class identity
- Department
- Class teacher
- Student count
- Student list
- Subject list
- Overall attendance percentage
- Student attendance percentage
- Attendance history
- Timetable
- Condonation list
- Report generation

### 10.8 Student Profile for Staff

Teachers and authorized staff must be able to view:

- Student name
- Course and class
- Register number
- Email address
- Phone number
- Parent contact
- Average attendance
- Attendance trend
- Subject attendance history

Access to personal contact information must be permission-controlled.

### 10.9 Attendance Analytics

Analytics must support:

- Average attendance percentage
- Daily or weekly trend visualization
- Subject-level analysis
- Student-level analysis
- Class-level analysis
- Department-level analysis for HODs
- Time filters

Time filters shown in the designs:

- 1 week
- 1 month
- All time

Charts must expose their data in an accessible textual or tabular form.

### 10.10 Attendance History

Attendance history must support:

- Month selection
- Calendar view
- Day-level attendance records
- Subject details
- Session details
- Status labels
- Navigation to record details

Students should only see their own history. Staff access should follow role and class assignment.

### 10.11 Reports

The product must support:

- Attendance report generation
- Report preview
- Report download
- Download-success feedback
- Class-level reports
- Student-level reports
- Subject-level reports

> **Inferred:** Report format, included columns, date range, and authorization rules require confirmation.

### 10.12 Condonation

The class experience includes a “Check Condonation” action and Condonation Register.

The module should support:

- Viewing students eligible for condonation review
- Displaying attendance by subject
- Showing student identity
- Showing register number
- Exporting or generating a report

> **Inferred:** Eligibility thresholds, approval workflow, and institutional policy are not defined.

### 10.13 Timetable

All roles may view relevant timetable data.

Timetable entries include:

- Weekday
- Period
- Start time
- End time
- Subject
- Teacher
- Class

Teachers and HODs have additional timetable actions:

- View class timetables
- View teacher timetables
- Select a class
- Select a teacher
- Request a swap
- Review timetable settings

### 10.14 Timetable Swap Requests

A teacher must be able to request a timetable or teacher swap.

The flow includes:

1. Choose the affected timetable entry.
2. Choose a class.
3. Select a replacement teacher.
4. Submit the request.
5. HOD reviews the request.
6. HOD accepts or rejects it.

A request should identify:

- Requesting teacher
- Current period
- Day
- Class
- Proposed replacement teacher
- Request status

### 10.15 Inbox and Notifications

The inbox supports role-based messages and requests.

Filters shown in the design:

- All
- Teacher
- Student
- Leave

Message types include:

- Teacher swap request
- Student attendance issue
- Accepted teacher request
- Rejected teacher request
- Student issue under review
- Verified student issue
- Rejected student issue

Staff actions include:

- Accept
- Reject
- Review

### 10.16 Department Management

HODs must be able to view and manage:

- Department identity
- Department classes
- Department teachers
- Teacher assignments
- Assigned subjects
- Assigned classes
- Timetable settings
- Archived batches

The department interface includes:

- Search
- Sorting
- Add
- Upload
- Multi-selection
- Delete

### 10.17 Teacher Management

HODs must be able to:

- View teacher list
- Search teachers
- Sort teachers
- Add teacher details
- Edit teacher details
- Assign subjects
- Assign a class
- Review contact information
- Upload teacher data
- Select and delete records

Teacher fields shown include:

- Teacher name
- Email
- Phone number
- Initial credential
- Assigned subjects
- Assigned class

> **Security:** Production interfaces must never expose stored passwords. Initial credentials must be temporary and securely delivered.

### 10.18 Batch Management

The HOD interface includes archived batches.

The product should support:

- Viewing active batches
- Viewing archived batches
- Opening batch details
- Retaining historical attendance records

Archive and restoration rules are not defined in the current designs.

### 10.19 Profile and Settings

Profiles may include:

- Name
- Role
- Department
- Class
- Assigned subjects
- Email
- Phone number
- Profile photo

Settings shown include:

- Edit profile
- Attendance history for students
- Timetable settings for staff
- Notifications
- Change password
- App settings
- Logout

## 11. Search, Sort, and Filtering

Search is used across student, teacher, class, and subject lists.

Sort options shown include:

- Roll number
- Highest attendance
- Lowest attendance

Filters shown include:

- Week
- Month
- All time
- Message sender or type
- Class
- Teacher
- Attendance status

Search and filter state should remain active when returning from a detail screen.

## 12. Product Status Models

### Attendance Record Status

- Present
- Late
- Absent
- Pending
- Ongoing

### Teaching Session Status

- Pending
- Record Now
- Recorded
- Missed

### Attendance Issue Status

- Submitted
- Under Review
- Verified
- Corrected
- Rejected

### Teacher Request Status

- Submitted
- Accepted
- Rejected

### Download Status

- Starting
- In progress
- Completed
- Failed

The failed state is required even though it is not represented in the current design.

## 13. Business Rules

The following rules are supported or strongly suggested by the interface:

1. Attendance belongs to a student, subject session, date, and time.
2. A session belongs to a class, subject, and teacher.
3. A student may have only one effective attendance status per session.
4. Teachers can record attendance for assigned sessions.
5. Class teachers can review broader class attendance.
6. HODs can review department-level information and requests.
7. Students can report only their own attendance issues.
8. Corrected attendance must update student history and analytics.
9. Reports must reflect the effective status after approved corrections.
10. Archived batches must retain historical records.

Rules requiring confirmation:

- Who may edit attendance after it is recorded?
- Is HOD approval required for every correction?
- How long is the attendance-recording window?
- What makes a session missed?
- What attendance percentage triggers condonation?
- Can students submit multiple issues for one session?
- Can teachers reverse an accepted swap?
- How are holidays and canceled sessions handled?

## 14. Data Model

### User

- ID
- Name
- Email
- Phone
- Profile photo
- Status
- Roles

### Role

- Student
- Teacher
- Class Teacher
- HOD
- Admin

### Department

- ID
- Name
- HOD
- Teachers
- Classes
- Subjects

### Academic Batch

- ID
- Name
- Academic year
- Department
- Status

Batch status:

- Active
- Archived

### Class

- ID
- Name
- Department
- Batch
- Class teacher
- Students
- Subjects

### Student

- User ID
- Register number
- Class
- Course
- Parent contact

### Teacher

- User ID
- Department
- Assigned classes
- Assigned subjects
- HOD flag

### Subject

- ID
- Name
- Department
- Classes
- Assigned teachers

### Timetable Entry

- ID
- Weekday
- Period
- Start time
- End time
- Subject
- Class
- Teacher

### Teaching Session

- ID
- Timetable entry
- Date
- Class
- Subject
- Teacher
- Session status

### Attendance Record

- ID
- Session
- Student
- Attendance status
- Recorded by
- Recorded at
- Last updated by
- Last updated at

### Attendance Issue

- ID
- Attendance record
- Student
- Reason
- Description
- Status
- Reviewer
- Decision note
- Created at
- Resolved at

### Swap Request

- ID
- Requesting teacher
- Original timetable entry
- Proposed teacher
- Status
- Reviewer
- Created at
- Resolved at

### Notification

- ID
- Recipient
- Type
- Title
- Message
- Related entity
- Read state
- Created at

### Generated Report

- ID
- Report type
- Scope
- Date range
- Requested by
- File reference
- Generation status

## 15. Key Acceptance Criteria

### Student Attendance Visibility

- A student can view today’s sessions and statuses.
- A student can view subject attendance percentages.
- A student can view overall attendance.
- A student can view historical records by month.
- Attendance status is communicated with color and text.

### Attendance Issue Reporting

- A student can select an attendance record.
- A student can submit an issue reason.
- The request appears in the authorized reviewer’s inbox.
- A reviewer can verify, correct, or reject the request.
- The student receives the final outcome.
- An approved correction updates history, analytics, and reports.

### Teacher Attendance Capture

- A teacher can open an assigned session.
- The complete class roster is displayed.
- Individual and bulk actions are available.
- Attendance can be saved.
- A saved session changes to Recorded.
- Saved records appear in student history and analytics.

### HOD Request Review

- HOD can filter inbox messages.
- HOD can open teacher and student requests.
- HOD can accept, reject, or review requests.
- Decisions are recorded.
- Requesters receive the outcome.

### Reports

- Authorized users can select a report scope.
- Users can preview a report.
- Users can download a report.
- Success and failure feedback is displayed.

## 16. Non-Functional Requirements

### Accessibility

- Important text should not use very small font sizes.
- Interactive targets should be at least 44 × 44 px.
- Status must never rely on color alone.
- Charts must have textual or tabular equivalents.
- Text and controls must meet WCAG contrast requirements.

### Security and Privacy

- Access must be role- and assignment-based.
- Student personal information must be restricted.
- Passwords must never be displayed or stored as readable text.
- Attendance corrections should be auditable.
- Administrative decisions should be auditable.
- Report downloads require authorization.

### Reliability

- Saving attendance should be idempotent.
- Duplicate submissions should be prevented.
- Loading states should be displayed.
- Success states should be displayed.
- Empty states should be displayed.
- Offline states should be handled.
- Error states should be displayed.
- Corrections must update dependent summaries consistently.

### Performance

- Daily schedules should load quickly on mobile networks.
- Rosters should load quickly.
- Search and filtering should remain responsive for large batches.
- Long tables should use pagination, virtualization, or progressive loading.

## 17. Content Corrections

The following visible copy should be corrected:

- `Attendance Histroy` → `Attendance History`
- `Sign in to you’re Account` → `Sign in to your account`
- `Enter you’re password` → `Enter your password`
- `Enter you’re email address` → `Enter your email address`
- `View you’re Time table here` → `View your timetable here`
- `View your’e attendance here` → `View your attendance here`
- `Download successs` → `Download complete`
- `canel` → `Cancel`
- `Fir` → `Fri`
- `THUS` → `THU` or `THURS`
- `Dropdwon` → `Dropdown`

Product terminology should be standardized:

- Timetable vs. Time Table
- Class teacher vs. Class Teacher
- HOD vs. Admin
- Attendance issue vs. Attendance report
- Verified vs. Corrected

## 18. Missing Product Decisions

The Figma file does not define the following sufficiently:

- Account provisioning and activation
- Password recovery
- Error, empty, and offline behavior
- Attendance-edit deadlines
- Approval rules for corrections
- Attendance-percentage formulas
- Condonation policy
- Report formats and date ranges
- Holiday and canceled-session handling
- Notification delivery channels
- Data retention and archival rules
- Audit-log visibility
- Bulk-import validation
- Teacher deletion safeguards
- Parent access
- Institution-level administration

These decisions should be resolved before engineering estimates are finalized.

## 19. Suggested MVP

### MVP Scope

- Role-based login
- Student home
- Student subject attendance
- Student attendance history
- Teacher daily schedule
- Teacher attendance capture
- Class student list
- Basic attendance analytics
- Student attendance issue reporting
- HOD issue review
- Timetable viewing
- Profile
- Logout

### Post-MVP Scope

- Timetable swap requests
- Advanced department management
- Teacher bulk upload
- Archived batch management
- Condonation workflow
- Advanced report generation
- Notification preferences
- Department analytics

## 20. Success Metrics

Recommended metrics:

- Percentage of scheduled sessions recorded on time
- Median time required to record one class
- Attendance-record correction rate
- Median issue-resolution time
- Monthly active students
- Monthly active teachers
- Monthly active HODs
- Percentage of students viewing attendance each month
- Report-generation success rate
- Timetable-request resolution time
- Reduction in manual report preparation

## 21. Recommended Product Architecture

Organize the application around shared domain modules:

- Authentication
- Users and roles
- Departments
- Classes and batches
- Subjects
- Timetables and sessions
- Attendance
- Analytics
- Issues and approvals
- Inbox and notifications
- Reports
- Profiles and settings

The authenticated user’s role, department, class assignment, and subject assignment should determine navigation and access.

## 22. Glossary

- **Attendance record:** One student’s attendance status for one teaching session.
- **Teaching session:** A scheduled subject occurrence for a class on a particular date and time.
- **Class teacher:** A teacher responsible for the overall administration of a class.
- **HOD:** Head of Department.
- **Condonation:** An institution-specific process related to attendance shortage eligibility or exemption.
- **Attendance issue:** A student-submitted claim that an attendance record is incorrect.
- **Swap request:** A teacher request to exchange or reassign a timetable period.
- **Recorded session:** A session whose attendance has been saved.
- **Missed session:** A session whose attendance was not recorded within the allowed period.
