# Design System for Fahhhh Frontend

## Overview
This design system is built for a Flutter-based attendance management application used by college students, teachers, class teachers, and department heads. The product is role-aware, with a shared base experience that adapts to different responsibilities while preserving a consistent visual language.

The current app already contains a strong early foundation for a system: centralized theme tokens, reusable buttons and form controls, Material 3 styling, and role-based navigation patterns. This document formalizes those patterns into a scalable design system for future screens and product growth.

## Product Context
The app supports:
- Student attendance viewing and schedule access
- Teacher attendance recording and timetable management
- Class teacher coordination and class oversight
- HOD department-level visibility and administrative actions

Core user needs:
- Fast login and role recognition
- Clear schedule and attendance views
- Consistent forms and actions
- Trust through visible states and feedback
- Mobile-friendly, action-first interfaces

## Design Principles
1. Clarity over decoration
   - Information must be easy to scan, especially attendance data and class schedules.
   - Use spacing, hierarchy, and color intentionally to reduce ambiguity.

2. Role-aware but consistent
   - Each user type gets relevant functionality, but all views should follow the same token system.
   - Shared components should behave consistently regardless of role.

3. Trust and certainty
   - Attendance status should be visually obvious: present, absent, ongoing, pending.
   - Validation and feedback must be explicit and timely.

4. Mobile-first ergonomics
   - Large tap targets, clear spacing, and familiar patterns are preferred over dense layouts.
   - Forms should remain simple and easy to complete on small screens.

5. Structured scalability
   - The system should support new features without creating one-off UI decisions.
   - Shared tokens and component patterns reduce inconsistency across modules.

## Design System Foundations
The app is already structured around a clear design layer:
- `lib/core/theme_data/` contains visual tokens and theme configuration
- `lib/core/widgets/` contains reusable UI components
- `lib/features/` contains feature screens and role-specific flows

This is the right base for a formal design system because it keeps tokens and components centralized rather than embedded in feature screens.

## Visual Language
### Brand direction
The product uses a professional academic/education palette with a primary blue as the dominant brand color. It feels trustworthy, clean, and institutional while remaining modern.

### Core colors
From `AppColors`:

- Primary: `#136BB3`
- Background: white
- Gradient top: `#7198EE`
- Gradient bottom: `#163B8E`
- Navigation bar: `#262525`
- Heading text: black
- Body text: dark gray / muted gray
- Border: black / soft gray

Status colors:
- Present: `#4CAF50`
- Absent: `#E57373`
- Ongoing: `#7986CB`
- Pending: `#757575`

Attendance badge colors:
- Good attendance background: `#9EEDBB`
- Bad attendance background: `#FFCDCE`

Use these colors as semantic tokens, not arbitrary values:
- `primary`: main actions and brand emphasis
- `background`: app surfaces
- `border`: standard dividers and form outlines
- `present/absent/ongoing/pending`: status semantics

### Typography
The app uses Google Fonts and a restrained type system:

- Headings: `Poppins` / `AppTextStyles.heading`
- Small detail text: `Itim` / `AppTextStyles.small`
- General UI text: `Inter` / `AppTextStyles.sfPRO`

Typography intent:
- Headings should create order and vertical rhythm.
- Small text should support secondary information, labels, and helper copy.
- Body text should stay readable and uncluttered.

Suggested hierarchy:
- Display / page title: large, semibold, strong contrast
- Section heading: medium-large, semibold
- Label: compact, medium-weight
- Meta/helper text: smaller, muted color

### Radius and shape
From `AppRadius`:
- Small: `12`
- Medium: `16`
- Large: `24`
- Card: `17`
- Pill: `30`
- Full: `9999`

Shape rules:
- Inputs and form fields: large radius for comfort and consistency
- Buttons: medium to large radius depending on emphasis
- Cards: medium radius for a clean mobile surface
- Pills / tags: full radius for status labels and chips

### Elevation and shadows
The app uses subtle depth to make controls feel tactile without being heavy.

Visual pattern:
- Buttons use soft shadow with low blur and slight vertical offset
- Elevated surfaces should remain subtle and restrained
- Avoid over-shadowing to prevent visual noise

## Design Tokens
The current implementation already exposes a good set of foundation tokens. These should be treated as the canonical source of truth for future work.

### Color tokens
- `AppColors.primary`
- `AppColors.background`
- `AppColors.border`
- `AppColors.headingText`
- `AppColors.smallText`
- `AppColors.labelText`
- `AppColors.hintText`
- `AppColors.present`
- `AppColors.absent`
- `AppColors.ongoing`
- `AppColors.pending`

### Typography tokens
- `AppTextStyles.heading`
- `AppTextStyles.small`
- `AppTextStyles.sfPRO`

### Radius tokens
- `AppRadius.small`
- `AppRadius.medium`
- `AppRadius.large`
- `AppRadius.card`
- `AppRadius.pill`
- `AppRadius.full`

### Theme token
- `DesignSystem.lightTheme`

This theme sets:
- Material 3 enabled
- White scaffold background
- Blue primary color
- Poppins-based text theming
- Large rounded input decorations
- Full-width elevated button defaults

## Component Library
The app already includes several reusable components worth formalizing as the initial component set.

### 1. Primary and secondary buttons
Implemented in `app_button.dart`

Properties:
- `text`
- `icon`
- `variant` (`primary`, `secondary`)
- `onPressed`
- `height`, `width`, `padding`
- `borderRadius`, `backgroundColor`, `textColor`

Usage guidance:
- Use primary buttons for the main action on a screen.
- Use secondary buttons for less prominent actions or alternatives.
- Keep button labels short and specific.
- Preserve an obvious pressed state using the existing animated feedback pattern.

### 2. Input fields
Implemented in `input_fields.dart`

Usage guidance:
- Use for email, password, search, text entry, and filters.
- Labels should be short and descriptive.
- Maintain a clear focus state using the theme color.
- Provide validation text or inline messages when needed.

### 3. Dropdown fields
Implemented in `app_dropdown_field.dart`

Usage guidance:
- Use for selecting roles, filters, class names, or teacher options.
- Keep the triggering label readable and consistent with surrounding form controls.

### 4. Segmented control
Implemented in `app_segmented_control.dart`

Usage guidance:
- Use for switching between alternate views or filters within a single screen.
- Examples: timetable view modes or attendance categories.
- Use clearly distinct labels and a strong selected state.

### 5. Dialogs and modals
Implemented in `app_dialog.dart`

Usage guidance:
- Use for confirmations, destructive actions, and quick task-specific prompts.
- Keep content minimal and action-focused.
- Ensure buttons follow the same primary/secondary hierarchy.

### 6. Back header
Implemented in `app_back_header.dart`

Usage guidance:
- Use for detail pages and nested flows.
- Maintain a predictable title area and navigation affordance.

## Screen Patterns
### Authentication flow
The login screen is the primary app entry and already reflects the design direction clearly:
- Large welcome heading
- Muted subtitle
- Full-width form fields
- Blue primary action button
- Focus on validation and quick access

Recommended enhancements for the design system:
- Add an explicit login card container or panel on larger screens
- Introduce error states for each field
- Standardize spacing between form elements

### Role-based dashboard patterns
The app uses different feature modules by role but should maintain a consistent UI rhythm across them:
- Top-level navigation shell
- Cards / lists for schedules and data summaries
- Status chips or badges for attendance outcomes
- Detail screens with clear hierarchy and action buttons

### Attendance information patterns
Attendance data is highly visual and should remain easy to interpret.

Recommended pattern:
- Use green/red status coloring intentionally, not as decoration alone
- Pair color with text labels for accessibility
- Maintain a consistent card layout for dates, subjects, and attendance states

## Accessibility Expectations
The design system should follow strong accessibility standards.

Required baseline:
- Minimum readable contrast for text and controls
- Buttons with minimum tap target comfort
- Clear focus states for keyboard and assistive tech users
- Labels for all input controls
- Meaningful color not relied on as the only indicator of state

Important note:
The app currently uses color-coded status states, so text labels and semantics must accompany those colors to remain accessible and understandable.

## Layout and Spacing System
Use a consistent spacing scale throughout screens.

Recommended scale:
- 4, 8, 12, 16, 20, 24, 32

Rules:
- Tight spacing around dense UI clusters
- More generous spacing between sections and screen groups
- Use consistent padding within forms and cards
- Align controls and typography to a shared baseline

The app already follows this pattern in many screens: padded forms, spaced vertical sections, and button-group rhythm.

## Interaction and Motion
The existing button implementation uses short press feedback and transitions, which is a strong foundation.

Recommended motion rules:
- Keep micro-interactions under 150ms for pressed state feedback
- Use simple fade/transform transitions where needed
- Avoid over-animation in admin or data-heavy screens
- Motion should support clarity, not distract from content

## Naming and File Structure
The current structure creates a good foundation for a token/component architecture:

```text
frontend/
  lib/
    core/
      theme_data/
        app_colors.dart
        app_text_styles.dart
        app_radius.dart
        design_system.dart
      widgets/
        app_button.dart
        app_dialog.dart
        app_dropdown_field.dart
        app_segmented_control.dart
        input_fields.dart
    features/
      auth/
      home/
      timetable/
      attendance/
      department/
      my_class/
      my_subjects/
      profile/
      inbox/
      navigation/
```

This structure should remain the basis of the design system as it grows.

## Design System Governance
To keep this design system healthy, future UI decisions should follow these rules:

1. Prefer token-based colors, typography, and spacing over custom one-off values.
2. Reuse existing shared widgets before creating custom screen-specific controls.
3. Add new design tokens only when a real need exists across multiple screens.
4. Keep consistency between role-based views and the core app shell.
5. Validate new features against accessibility and mobile usability.

## Recommended Next Milestones
1. Formalize a complete component inventory from the existing widgets
2. Add documentation for state styles (default, hover, pressed, disabled, error, success)
3. Define a spacing scale and card layout pattern for all feature modules
4. Create a small icon and status-label system for attendance screens
5. Expand the system to support dark mode or future product surfaces if needed

## Summary
The frontend already contains the early skeleton of a strong design system: styled theme tokens, reusable controls, Material 3 patterns, and role-aware navigation. The core direction is clear and consistent: professional blue branding, readable academic UI, strong information hierarchy, and mobile-first usability.

This system is ready to evolve into a durable product design language by formalizing tokens, component usage rules, and accessibility expectations.

## Suggested Implementation Rule
For future feature work, use this default pattern:
- `DesignSystem.lightTheme` for app theme
- `AppColors` for color references
- `AppTextStyles` for typography
- `AppRadius` for shape values
- `AppButton`, `InputField`, `AppDropdownField`, `AppDialog`, `AppSegmentedControl` as shared primitives

This ensures the app remains consistent as it grows beyond the current attendance management screens.

## Source References
The design system is derived from the current Flutter implementation in:
- `frontend/lib/core/theme_data/`
- `frontend/lib/core/widgets/`
- `frontend/lib/features/auth/screens/login_screen.dart`
- `frontend/lib/main.dart`

These files should be treated as the canonical starting point for future design system refinements.

---

This document should be treated as the baseline design system definition for the Fahhhh frontend and updated whenever new reusable patterns emerge.
