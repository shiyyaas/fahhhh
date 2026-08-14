# Attendance Management Application (Frontend)

A Flutter-based college Attendance Management System built with Material 3, Riverpod, Dio, GoRouter, and SharedPreferences.

---

## Overview

This application facilitates college attendance tracking across multiple roles (Student, Teacher, Class Teacher, Head of Department / HOD). It features role-adaptive views for daily schedules, timetable grids, subject metrics, class management, department analytics, and attendance recording/history.

---

## Tech Stack & Architecture

- **Framework**: Flutter (Material 3) with Dart
- **State Management**: Riverpod (`flutter_riverpod` + `riverpod_generator`)
- **Navigation**: GoRouter (declarative routing with `StatefulShellRoute` for bottom navigation)
- **Networking**: Dio (prepared repository abstraction for seamless backend integration)
- **Local Persistence**: SharedPreferences (`sharedPreferencesProvider`)
- **Design System**: Material 3, custom typography (`AppTextStyles`), colors (`AppColors`), and radius (`AppRadius`)

### Architecture Pattern

The application follows a **feature-first** modular architecture:

```
lib/
├── main.dart
├── core/
│   ├── routes/          # Centralized GoRouter setup (app_router.dart)
│   ├── theme_data/      # Design system tokens (AppColors, AppTextStyles, DesignSystem)
│   └── widgets/         # Shared reusable UI elements (BlueBtn, WhiteBtn, InputField)
└── features/
    ├── auth/            # Authentication, CurrentUser polymorphic model, AuthProvider
    ├── home/            # Role-aware daily schedule, week calendar, timetable cards
    ├── timetable/       # Grid timetable view (Classes/Teachers modes), single source slot model
    ├── attendance/      # Attendance taking & viewing screen with date-adaptive states
    ├── department/      # Department overview, class & teacher lists, attendance charts
    ├── my_class/        # Class-teacher & student management views
    ├── my_subjects/     # Teacher/Student subject lists and details
    ├── profile/         # User profile, edit profile, attendance history
    ├── inbox/           # Notifications and leave/swap request management
    └── navigation/      # Bottom navbar shell framework
```

---

## User Roles & Capabilities

The app dynamically adapts layouts and features based on the logged-in user:

1. **Student**:
   - Views personal daily period schedule and attendance status on Home.
   - Accesses class timetable directly (class selector disabled).
   - Views personal subject performance, details, and attendance history calendar.
2. **Teacher**:
   - Views personal teaching schedule and records/edits period attendance.
   - Switches timetable grid between "Classes" and "Teachers" views.
   - Manages assigned subjects and class details.
3. **Class Teacher**:
   - Has all Teacher capabilities plus management over their assigned class ("My Class" tab).
4. **Head of Department (HOD)**:
   - Has all Teacher capabilities plus department-wide oversight ("Department" tab).
   - Editing privileges on the Timetable grid screen to modify schedules.

---

## Key Development Rules & Single Source of Truth

- **Single Source of Truth**: Timetable data (`TimetableSlot`) is centrally managed via `TimetableNotifier` in `lib/features/timetable/providers/timetable_provider.dart`. Home schedule cards and timetable grid views derive dynamically from this single state.
- **Frontend-First Data Layer**: UI components strictly interact with abstract repositories (`AuthRepository`, `TimetableNotifier`), making future backend integration seamless by replacing mock data layers without refactoring UI widgets.
- **Navigation Rule**: Core detail screens and attendance taking flows are top-level routes outside the `StatefulShellRoute` to hide the bottom navigation bar when viewing detailed tasks.

---

## Getting Started & Development Commands

### Prerequisites

- Flutter SDK (3.22+ recommended)
- Dart SDK

### Installation & Dependencies

```bash
# Navigate to frontend folder
cd frontend

# Install dependencies
flutter pub get
```

### Code Generation

To regenerate Riverpod provider files (`*.g.dart`), run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Running the Application

```bash
flutter run
```

### Code Quality & Testing

Run analyzer checks and unit/widget tests:

```bash
# Run static code analysis
flutter analyze

# Run unit and widget tests
flutter test
```
