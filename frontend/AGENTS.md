# AGENTS.md

# Attendance Management App

## Project Overview

This is a Flutter-based Attendance Management System for colleges.

The application is being developed with scalability in mind, starting with department-level management and later expanding to support the entire institution.

The project follows a feature-first architecture and uses Riverpod for state management.

---

## Tech Stack

- Flutter (Material 3)
- Dart
- Riverpod
- Dio
- GoRouter
- SharedPreferences

---

## Architecture

The project follows a feature-first architecture.

Example:

lib/
├── core/
├── features/
│   ├── authentication/
│   ├── home/
│   ├── attendance/
│   ├── my_class/
│   ├── my_subjects/
│   ├── profile/
│   └── department/

Each feature should contain only the files related to that feature.

Shared code belongs inside `core`.

---

## State Management

- Use Riverpod.
- Keep providers inside their respective features whenever possible.
- Global providers should only exist if multiple features depend on them.

---

## Navigation

- Use GoRouter.
- Avoid Navigator.push unless absolutely necessary.
- Keep navigation centralized.

---

## UI Guidelines

- Follow the existing DesignSystem.
- Use Material 3.
- Reuse existing widgets before creating new ones.
- Keep UI consistent across all screens.
- Prefer responsive layouts.

---

## Code Style

- Write readable and maintainable code.
- Keep widgets focused on a single responsibility.
- Extract reusable widgets when appropriate.
- Prefer composition over duplication.
- Use meaningful variable and method names.
- Avoid unnecessary comments. Code should be self-explanatory.

---

## Folder Rules

Each feature may contain:

screens/
widgets/
providers/
models/
services/
repositories/

Only create folders when they are needed.

---

## Data Layer

- UI should not directly access APIs.
- Use repositories for data access.
- Business logic should stay outside widgets.

---

## Before Making Changes

Before implementing a feature:

1. Understand the existing architecture.
2. Reuse existing components whenever possible.
3. Avoid modifying unrelated files.
4. Keep changes minimal and focused.

---

## When Adding Features

New features should:

- Match the existing architecture.
- Follow the current UI design.
- Use Riverpod.
- Keep code modular.
- Avoid breaking existing functionality.

---

## Things to Avoid

- Large unnecessary refactors.
- Renaming files without reason.
- Changing project architecture.
- Adding new packages unless required.
- Duplicating code.

---

## If Unsure

Prefer consistency with the existing codebase over introducing a different pattern.

If multiple approaches are possible, choose the one that is simplest, easiest to maintain, and aligns with the existing architecture.
