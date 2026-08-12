# Figma → Flutter Integration Guide (MCP)

Rules for turning Figma designs into this Flutter codebase via the Figma MCP server.
Read `AGENTS.md` first — it is the source of truth for architecture and coding rules.
This document is a companion that maps the design system and UI patterns to actual code so Figma output is pixel-consistent with zero design-system drift.

---

## Workflow (Figma MCP)

1. Use `get_design_context` (or `get_metadata` → drill into node ids) to pull the design for the target screen/component.
2. Map every Figma token to existing Dart tokens BEFORE writing new values:
   - Colors → `AppColors.*`
   - Text → `AppTextStyles.*`
   - Corner radius → `AppRadius.*`
   - Spacing → existing `EdgeInsets` conventions (16/20/24px paddings, 12/16 gaps)
3. Reuse existing widgets (`core/widgets`, `features/home/widgets`, `features/profile/widgets`) instead of rebuilding equivalents.
4. Only introduce a hardcoded hex/radius/font if the token genuinely does not exist — then add it to the token file, never inline in the widget.
5. Never emit `ThemeData` per-screen; always use `DesignSystem.lightTheme` + token classes.

---

## 1. Design Token Definitions

Tokens live in `lib/core/theme_data/` as plain Dart static classes (no transformation system, no JSON — tokens are compiled in).

| File | What it defines |
|---|---|
| `lib/core/theme_data/app_colors.dart` | `AppColors` — brand + status colors |
| `lib/core/theme_data/app_text_styles.dart` | `AppTextStyles` — font families + weights |
| `lib/core/theme_data/app_radius.dart` | `AppRadius` — corner radii (12/16/24) |
| `lib/core/theme_data/design_system.dart` | `DesignSystem.lightTheme` — Material 3 `ThemeData` wiring tokens to components |

### Colors (`app_colors.dart`)
```dart
class AppColors {
  static const Color primary = Color(0xFF136BB3);          // brand blue — Figma's #136BB3
  static const Color background = Colors.white;
  static const Color headingText = Colors.black;
  static const Color smallText = Color(0xFF635959);
  static const Color border = Color.fromARGB(255, 0, 0, 0); // black
  // Status
  static const Color present = Color(0xFF4CAF50);
  static const Color absent  = Color(0xFFE57373);
  static const Color ongoing = Color(0xFF7986CB);
  static const Color pending = Color(0xFF757575);
}
```
Additional colors that exist ONLY as literals (do not redeclare inline; these are known Figma matches):
- Gradients: `0xFF5B8CFF → 0xFF1E4DB7` (selected calendar chip, `week_calendar.dart:55`), `0xFF4A7DFF → 0xFF1B3EA7` (notification bubble, `header_section.dart:69`).
- Status badge pairings (bg/text): see `features/home/widgets/status_badge.dart:79-139` (e.g. recorded `0xFFE7F8EC`/`0xFF1F8B4C`, recordNow `0xFFEAF2FF`/`0xFF2F6BFF`, late `0xFFFFF4E5`/`0xFFE59B00`, missed `0xFFFFEBEB`/`0xFFD92D20`).

### Typography (`app_text_styles.dart`) — Google Fonts
```dart
class AppTextStyles {
  static TextStyle heading = GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Color(0xFF131212));
  static TextStyle small   = GoogleFonts.itim(color: AppColors.smallText);
  static TextStyle sfPRO   = GoogleFonts.inter(color: AppColors.headingText);
}
```
Base font family is **Poppins** (set in `DesignSystem.lightTheme`). Inline `fontSize` is applied via `.copyWith(fontSize: ...)` at call sites — Figma text sizes map to these copyWith overrides.

### Radius (`app_radius.dart`)
```dart
class AppRadius { static const double small = 12, medium = 16, large = 24; }
```
Note: `InputField` (`core/widgets/input_fields.dart`) and edit-profile fields use **radius 30** pill inputs — this is intentional for inputs; keep pill inputs at 30.

---

## 2. Component Library

No storybook/documentation tooling. The "library" is the widget tree under `lib/core/widgets` and per-feature `widgets/` folders. Follow composition — reuse before creating.

### Core shared widgets (`lib/core/widgets/`)
| Widget | File | Purpose |
|---|---|---|
| `BlueBtn` | `blue_btn.dart` | Primary filled action button (press animation, gradient-style shadow). Width defaults to content — pass `width: double.infinity` for full-bleed. |
| `WhiteBtn` | `white_btn.dart` | Outlined/white action button. |
| `InputField` | `input_fields.dart` | Label + pill TextField (controller, label, hint, obscureText). |

```dart
// Primary button pattern (login, save, logout)
BlueBtn(
  text: "Login",
  onPressed: () { ... },
  width: double.infinity,
  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
  mainAxisAlignment: MainAxisAlignment.center,
);
```

### Home feature widgets (`lib/features/home/widgets/`)
| Widget | File | Purpose |
|---|---|---|
| `HeaderSection` | `header_section.dart` | Avatar + name + role subtitle + notification bubble (role-aware). |
| `WeekCalendar` | `week_calendar.dart` | Horizontal 7-day selector with gradient active chip. |
| `DateBtn` | `date_btn.dart` | "Today / day name + date" heading + WhiteBtn "Time Table". |
| `TimetableCard` | `timetable_card.dart` | Blue class card: subject, secondary text, `TimeBadge`, `StatusBadge`, optional avatar. Handles `isToday`/`isFuture`. |
| `TimeBadge` | `time_badge.dart` | Time range pill; shows "NOW" during the live period. |
| `StatusBadge` | `status_badge.dart` | Also defines the **`AttendanceStatus` enum** — import this file for the enum. |

### Profile feature widgets
| Widget | File | Purpose |
|---|---|---|
| `WhiteBox` | `features/profile/widgets/white_box.dart` | Icon + title list row, supports arrow/switch/tap. |

**Rule:** If Figma shows a row/card/button/badge, check these folders first. Do not recreate them locally.

---

## 3. Frameworks & Libraries

- **UI framework**: Flutter, Material 3 (`useMaterial3: true`).
- **State management**: Riverpod (`flutter_riverpod` ^2.6, codegen via `riverpod_annotation` + `riverpod_generator`). Generated files: `*.g.dart` committed alongside source. Add `.g.dart` part directives.
- **Navigation**: `go_router` ^17 — single central router in `lib/core/routes/app_router.dart` (`routerProvider`). No `Navigator.push` except in dialogs; use `context.go` / `context.push` / `context.pop`.
- **HTTP**: `dio` (installed; repositories are mock-only today — swap `MockAuthRepository` for a Dio repo when wiring the backend).
- **Fonts**: `google_fonts` — Poppins (base), Itim (`small`), Inter (`sfPRO`).
- **Persistence**: `shared_preferences` (session cache, `sharedPreferencesProvider`).
- **Build/bundler**: standard Flutter toolchain (`flutter run`, `flutter test`, `flutter build`). No JS bundler. `flutter analyze` is the linter gate (see §6).

---

## 4. Asset Management

- Location: `frontend/assets/images/` — currently `logo.png`, `profile.png`, `student.png`, `teacher.png`.
- Registered **explicitly** in `pubspec.yaml` under `flutter: assets:` — new assets MUST be added there.
- Referenced via `AssetImage('assets/images/xxx.png')` or `Image.asset(...)`. Avatar helpers accept `imageUrl` strings that are asset paths.
- No optimization pipeline, no CDN, no network images. Backend media will arrive later via network URLs — when that happens, prefer `Image.network` behind a small helper, keep `AssetImage` fallback.
- Rule: do not reference an asset by raw path without registering it in `pubspec.yaml`.

---

## 5. Icon System

- **Material Icons only** (`Icons.*`), from the built-in Material font (`uses-material-design: true`).
- No custom icon font / SVG set yet. If Figma uses custom glyphs, propose adding a library instead of inlining — do not hand-roll SVGs per screen.
- Convention: outlined variants for nav/menu/actions (`Icons.home_outlined`, `Icons.person_outline`, `Icons.notifications_none_rounded`, `Icons.menu_book_outlined`, `Icons.groups_outlined`, `Icons.apartment_outlined`); filled for emphasis.
- Nav items are centralized in `lib/features/navigation/models/nav_item.dart` (`NavItem{icon, label, branchIndex}`) and consumed by `MainScreen` — never define nav icons inline.

---

## 6. Styling Approach

- **No CSS.** Styling = Material 3 `ThemeData` + inline widget decoration.
- Global theme is a single instance: `DesignSystem.lightTheme` (in `main.dart`). It wires: background, primary, AppBar (transparent), `textTheme`, input decoration (filled white, `AppRadius.large`, primary focus border), and `elevatedButtonTheme` (primary, full-width, min-height 55).
- Buttons in screens often use `BlueBtn`/`WhiteBtn` (custom press-state animation) instead of `ElevatedButton`. When Figma shows a button, default to these.
- **Responsive**: no breakpoints/media queries yet. Uses `SafeArea`, `Expanded`, `FittedBox`, `SingleChildScrollView`, flexible `Row`/`Column`, and horizontal `ListView`/`SingleChildScrollView` for tables. Fixed-size chips/cards are sized to fit ~390–412px wide viewports.
- **Linting**: `analysis_options.yaml` includes `flutter_lints` (defaults only, no custom rules). Run `flutter analyze` before finishing a task.

### Design-system drift warnings (avoid these)
Existing screens contain hardcoded slate/near-black literals that are NOT tokens. Match Figma to tokens where possible; when a new screen needs these, promote them to `AppColors` instead of copy-pasting literals:
- Timetable table grays: `0xFF1E293B`, `0xFF0F172A`, `0xFF64748B`, `0xFF94A3B8`, `0xFF475569`, `0xFFE2E8F0`, `0xFFF8FAFC` (`timetable_screen.dart`).
- Card/row shadows: `Colors.black.withValues(alpha: 0.04–0.1)` + blur 4–10.
- Header subtitle color: `0xFF6F5E53` (appears in `timetable_screen.dart`, `attendance_taking_screen.dart`).

---

## 7. Project Structure

Feature-first. Two top folders under `lib/`:

```
lib/
├── main.dart                      # ProviderScope + MaterialApp.router(DesignSystem.lightTheme)
├── core/
│   ├── routes/app_router.dart     # routerProvider (GoRouter) — ALL routes here
│   ├── theme_data/                # design tokens (see §1)
│   └── widgets/                   # cross-feature widgets (buttons, inputs)
└── features/
    ├── auth/        models/ providers/ repositories/ screens/ services/ widgets/
    ├── home/        screens/ widgets/ providers/
    ├── navigation/  models/ screens/ widgets/
    ├── attendance/  screens/
    ├── timetable/   models/ providers/ screens/
    ├── department/  screens/
    ├── my_class/    screens/
    ├── my_subjects/ screens/
    └── profile/     screens/ widgets/
```

Rules:
- Each feature owns its screens/widgets/providers/models/services/repositories. Create subfolders only when needed.
- Shared code goes in `core/`. Cross-feature providers (auth, timetable) may live in one feature but are watched from others.
- `TimetableSlot` (`features/timetable/models/timetable_slot.dart`) is the single source of truth model; the global `TimetableNotifier` (`features/timetable/providers/timetable_provider.dart`) is the single source of truth state. Never keep a second timetable dataset.
- Routes: full-screen flows (timetable, attendance-taking/view) are top-level `GoRoute`s OUTSIDE the `StatefulShellRoute` so the bottom nav hides. Tab pages live inside shell branches (`/home`, `/department`, `/class`, `/subjects`, `/profile`, `/profile/edit`).

### Data-layer pattern (for backend wiring later)
```dart
// repositories/xxx_repository.dart
abstract class AuthRepository { Future<CurrentUser> login(String email, String password); }

// repositories/mock_xxx_repository.dart
class MockAuthRepository implements AuthRepository { ... }

// providers/xxx_provider.dart
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) => MockAuthRepository();
```
UI never touches Dio directly. Replace mock implementations when backend lands — zero UI refactor.

---

## Non-Negotiable Figma Integration Rules

1. Map tokens, then widgets, then values. Hardcoded literals in new Figma-generated code are a defect.
2. Every screen is a feature (`features/<name>/screens/`); every new reusable piece is a widget in `core/widgets` or its feature `widgets/`.
3. Do not duplicate: `StatusBadge`, `TimeBadge`, `TimetableCard`, `HeaderSection`, `WeekCalendar`, `DateBtn`, `WhiteBox`, `BlueBtn`, `WhiteBtn`, `InputField`.
4. Attendance statuses always use the `AttendanceStatus` enum from `features/home/widgets/status_badge.dart`.
5. Keep Material 3; never introduce a second theming mechanism.
6. Routes go through `app_router.dart`. Bottom nav only exists on `MainScreen` (Home page framework).
7. Verify with `flutter analyze` and existing tests (`flutter test`) after any change.
