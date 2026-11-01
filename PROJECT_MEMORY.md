# Project Memory & Architecture Analysis: College Attendance ERP (EduSphere)

## 1. Project Identity & Purpose
This project is an **Attendance & Academic ERP (Enterprise Resource Planning) System** tailored for higher-education colleges / universities (specifically configured around MES College / BCA & CS departments).

It streamlines daily academic operations across **4 primary stakeholder roles**:
1. **Student**:
   - Views personal daily period schedule and real-time attendance status.
   - Monitors per-subject attendance percentages, condonation thresholds, and attendance logs.
   - Submits leave requests and receives administrative notifications.
2. **Teacher (Faculty)**:
   - Views personal daily teaching schedules across classes.
   - Takes period-by-period student attendance (Present, Absent, Late) directly from the schedule slot.
   - Initiates period swap requests with peer faculty members.
3. **Class Teacher**:
   - Retains all Teacher capabilities plus dedicated management over their assigned class ("My Class" view).
   - Reviews student rosters, monitors attendance health, and recommends student leaves.
4. **Head of Department (HOD)**:
   - Full department-wide governance ("Department" tab).
   - Manages batches/classes, teachers, students, and subjects (with semester promotion workflows).
   - Department-level analytics, defaulter lists (< 75% attendance), PDF report exports, timetable editing, and leave approvals.

---

## 2. Technology Stack & Directory Structure

```
c:\Users\muham\tester\fahhhh\
├── backend/                  # Node.js + Express + MongoDB REST API
│   ├── config/               # Database connection (db.js -> MongoDB Atlas via Mongoose)
│   ├── controllers/          # 13 controllers (Auth, Attendance, Dashboard, Department, Leaves, Reports, etc.)
│   ├── models/               # 10 Mongoose schemas (User, Student, Teacher, Batch, Department, Subject, Attendance, Timetable, Leave, Notification)
│   ├── routes/               # Modular Express API routes
│   ├── middleware/           # JWT auth and role validation middleware
│   ├── seed.js               # Database seeder with sample HOD, Teachers, Students & Timetables
│   └── server.js             # Express application root (Port 5000)
│
└── frontend/                 # Flutter mobile & cross-platform client (Android, iOS, Web, Desktop)
    ├── lib/
    │   ├── core/
    │   │   ├── network/      # ApiClient (Dio + token interceptor) & ApiEndpoints
    │   │   ├── routes/       # GoRouter configuration (StatefulShellRoute with top-level details)
    │   │   ├── theme_data/   # Design system (Material 3 tokens, AppColors, AppTextStyles)
    │   │   └── widgets/      # Shared UI elements (AppButton, InputField, AppDialog, etc.)
    │   └── features/
    │       ├── auth/         # Login, JWT caching, CurrentUser model, NetworkAuthRepository
    │       ├── home/         # Role-adaptive schedule calendar, timetable cards, quick attendance
    │       ├── timetable/    # 5×5 Timetable grid, TimetableNotifier, swap flows, HOD edit mode
    │       ├── attendance/   # Period attendance marking & submission to /api/attendance/mark
    │       ├── department/   # Classes, Teachers, Students, Subjects directory & CRUD dialogs
    │       ├── my_class/     # Class teacher roster & subject management
    │       ├── my_subjects/  # Subject performance details & attendance history
    │       ├── profile/      # User profile, attendance stats, edit profile
    │       ├── inbox/        # Notifications and Leave request workflows
    │       └── navigation/   # Bottom navigation bar shell
    └── test/                 # 30 Unit & Widget tests
```

---

## 3. Backend Architecture & Endpoints

- **Runtime**: Node.js v24+, Express 5, Mongoose 9.
- **Database**: MongoDB Atlas (`attendance_app` database).
- **Authentication**: JWT token-based (`Authorization: Bearer <token>`) with bcrypt password hashing.

### Key API Modules:
- **Auth**: `POST /api/auth/login` (returns JWT + user details).
- **Batches**: `GET /api/batches`, `POST /api/batches`, `PUT /api/batches/:id/promote`.
- **Teachers & Students**: `GET/POST /api/teachers`, `GET/POST /api/students`, `DELETE /api/students/:id`.
- **Subjects & Departments**: `GET/POST /api/subjects`, `GET/POST /api/departments`.
- **Timetable**: `GET /api/timetable`, `GET /api/timetable/batch/:id`, `GET /api/timetable/teacher/:id`.
- **Attendance**:
  - `POST /api/attendance/mark` (student, subject, teacher, batch, status: 'Present'/'Absent').
  - `GET /api/attendance/student/:id`, `GET /api/attendance/batch/:id`, `GET /api/attendance/percentage/:studentId`, `GET /api/attendance/defaulters`.
- **Reports**: `GET /api/reports/batch/:id/monthly-pdf`, `GET /api/reports/batch/:id/monthly-preview`.
- **Leaves & Notifications**: `GET/POST /api/leaves`, `PUT /api/leaves/:id/approve`, `GET /api/notifications/:userId`.

---

## 4. Frontend State & Network Architecture

- **State Management**: Flutter Riverpod with `riverpod_generator` code-gen (`*.g.dart`).
- **HTTP Client**: Dio (`ApiClient`) configured with base URL resolution (`http://10.0.2.2:5000/api` for Android emulator, `http://localhost:5000/api` for Web/Desktop). Includes automatic bearer token injection from `SharedPreferences`.
- **Current Data Providers**:
  - `authProvider` / `authNotifierProvider`: Connected to `NetworkAuthRepository`. Caches user session in `SharedPreferences` (`cached_user_profile` & `auth_token`).
  - `departmentRepositoryProvider`: Connected to backend (`getClasses`, `getTeachers`, `getStudents`, `getSubjects`, `createTeacher`, `createStudent`, `createSubject`, `deleteStudent`, etc.).
  - `timetableRepositoryProvider`: Connected to backend (`getAllTimetable`, `getBatchTimetable`, `getTeacherTimetable`).
  - `attendanceRepositoryProvider`: Connected to backend (`markAttendance`, `markBulkAttendance`, `getAttendancePercentage`, `getStudentAttendance`).
  - `inboxRepositoryProvider`: Connected to backend (`getNotifications`, `getPendingLeaves`, `approveLeave`, `rejectLeave`).

---

## 5. Verification & Test Status
- **Static Analysis**: `flutter analyze` executed with **0 issues**.
- **Unit & Widget Tests**: All **30 tests passed** in `frontend/test/`.
- **Backend Code Syntax**: Verified with `node --check` across all routes, controllers, models, and server files.

---

## 6. Recent Backend & Frontend Synchronizations Completed
1. **User Authentication Loop Synchronized**:
   - `studentController.createStudent` & `deleteStudent` now atomically maintain corresponding credentials in the `User` collection.
   - `teacherController.createTeacher` & `deleteTeacher` now atomically maintain corresponding credentials in the `User` collection.
   - Any newly created student or teacher can immediately log in to the application.
2. **Attendance Deduplication**:
   - `attendanceController.markAttendance` now upserts attendance for the student, subject, batch, and date, eliminating duplicate records when saved multiple times.
3. **Frontend Hardcode Eliminated**:
   - Timetable Screen: Class and teacher dropdown filters now dynamically query `departmentClassesProvider` and `departmentTeachersProvider`.
   - Add Teacher Dialog: Assigned subject and class dropdowns dynamically populate from live department providers.
   - My Subjects: Real backend `attendancePercent` metrics are prioritized over mock patterns.
   - Profile Editing: Name, email, and phone modifications are synced to backend teacher/student update endpoints.
   - Resilient Networking: `ApiClient` supports optional `SharedPreferences` with safe fallback for isolated test scopes.

---

## 7. Integration Checklist for Full End-to-End Connectivity
When connecting frontend screens to backend live endpoints:
1. **Ensure Backend Is Running**: Run `npm run dev` in `backend/` (uses port 5000 and connects to MongoDB Atlas).
2. **Physical Device vs. Emulator Network Config**:
   - Android Emulator uses `http://10.0.2.2:5000/api` (already configured in `ApiEndpoints.baseUrl`).
   - Physical phone testing requires using local LAN IP (e.g. `http://192.168.x.x:5000/api`).
3. **Database Seeding**: Run `node seed.js` in `backend/` to ensure initial accounts and timetables exist:
   - HOD: `anu@mescas.org` / `Hod@123`
   - Teachers: `rijina@mescas.org` / `Teacher@123`, `sheetal@mescas.org` / `Teacher@123`
   - Students: `shiyasps@mescas.org` / `Student@123`
4. **Subject Details Screen Integration**: Wire the remaining mock data in `features/my_subjects/screens/subject_details_screen.dart` directly to `attendanceRepositoryProvider` and `studentAttendancePercentageProvider`.
