# Design System for Fahhhh Attendance App

> Category: Themed & Unique
> Mobile-first academic attendance interface with role-aware dashboards, strong blue surfaces, compact data cards, and clear attendance states.

## 1. Visual Theme & Atmosphere

Professional academic attendance interface with a bold blue identity, compact information architecture, and high-contrast status communication.

- Visual style: modern, clean, bold
- Color stance: blue-dominant with white surfaces and muted semantic states
- Design intent: Make attendance, timetable, and role-specific actions immediately scannable while keeping a consistent mobile-first visual language.
- Reference canvas: 402 × 874 px
- Primary visual reference: Admin/HOD Home screen

## 2. Color

- Primary: #136BB3 — Main brand blue and the dominant subject-card color.
- Secondary: #D0E1FB — Supporting light-blue surface.
- Success: #48AE8C — Recorded / positive attendance state.
- Warning: #D0B238 — Late attendance state.
- Danger: #E57373 — Absent attendance state.
- Missed: #775471 — Missed session state.
- Record Now: #9DB6EE — Current action-available state.
- Pending: #5F6B7A — Pending session state.
- Surface: #FFFFFF — Main page, cards, controls, and active navigation surface.
- Text: #000000 — Primary headings and strong text.
- Text Secondary: #666666 — Supporting and metadata text.
- Navigation: #262525 — Bottom navigation capsule.
- Outline: #1A1A1A — Visible borders around cards and controls.
- Gradient Top: #7198EE — Blue gradient highlight.
- Gradient Bottom: #163B8E — Blue gradient depth.

- Favor Primary (#136BB3) for brand emphasis, subject cards, and primary actions.
- Use Surface (#FFFFFF) for the main background and elevated controls.
- Use Success, Warning, Danger, Missed, Record Now, and Pending only for semantic states.
- Do not use attendance color alone to communicate meaning; pair status colors with text labels.
- Avoid unrelated accent colors when an existing token can solve the problem.

## 3. Typography

- Scale: 10/12/14/16/20/24/29
- Families: primary=Poppins, body=Inter, decorative=Itim
- Weights: 400, 500, 600, 700
- Poppins should carry headings, subject names, and major navigation labels.
- Inter should handle general UI, data, metadata, and dense information.
- Itim should be restricted to explicitly decorative content and should not be used for important attendance data.
- Keep headings strong and compact; keep metadata smaller and visually subordinate.
- Avoid very small text for important information.

## 4. Spacing & Grid

- Spacing scale: 4/8/12/16/20/24/32 px
- Keep a consistent mobile rhythm across headers, calendars, cards, and navigation.
- Use compact internal spacing inside attendance cards.
- Use larger spacing between major screen sections.
- Align repeated cards, calendar cells, and controls to predictable horizontal margins.
- Avoid ad-hoc offsets and fractional spacing values unless a reference component requires them.

## 5. Layout & Composition

- Prefer clear content blocks with consistent internal padding.
- Keep hierarchy obvious: profile/header → date selector → page heading → timetable/attendance cards → navigation.
- Use whitespace to separate sections before adding heavy dividers.
- Header: circular profile image, prominent name, muted role/department, circular notification action.
- Calendar: five compact rounded day cells with a strong selected-day state.
- Timetable heading: large `Today` label, muted date beneath, and a compact outlined `Time Table` action.
- Subject cards: blue rounded cards with dark outlines, white subject/class text, time badge, and semantic status pill.
- Bottom navigation: dark full-width rounded capsule with one white active destination.
- Use rounded geometry consistently without making every element fully pill-shaped.

## 6. Components

- Buttons: primary actions use #136BB3 or the established blue gradient; secondary actions remain white with dark outlines.
- Inputs: white surfaces, clear dark outlines, readable labels, visible focus states, and predictable validation feedback.
- Calendar cells: white outlined unselected states and blue selected state with compact shadow.
- Subject cards: #136BB3 fill, dark outline, 16–18 px radius, white typography, compact time and status badges.
- Status pills: use semantic state tokens with text labels.
- Navigation: dark capsule with a white active-state capsule and dark active icon/label.
- Cards/sections: consistent padding, visible but restrained borders, and limited elevation.
- Shared Flutter primitives should remain centralized in `core/theme_data/` and `core/widgets/`.
- Prefer reusable components such as `AppButton`, `InputField`, `AppDropdownField`, `AppDialog`, `AppSegmentedControl`, `SubjectCard`, `AttendanceStatus`, `AttendanceChart`, `Timetable`, and `RoleNavigation`.

## 7. Motion & Interaction

- Use subtle, purposeful transitions.
- Default to short feedback transitions around 150–250ms.
- Selected calendar states may use stronger elevation/shadow feedback.
- Buttons should provide clear pressed-state feedback.
- Dropdowns and controls should support default, hover, pressed, selected, disabled, and error states where applicable.
- Attendance actions should provide immediate visible state changes.
- Avoid excessive animation in data-heavy, teacher, and HOD screens.
- Motion should reinforce state changes rather than decorate the interface.

## 8. Voice & Brand

- Tone should be concise, confident, academic, and action-oriented.
- Use literal labels such as `Today`, `Time Table`, `Record Now`, `Recorded`, `Missed`, and `Pending`.
- Keep role labels clear, such as `HOD - Computer Science`.
- Avoid generic filler copy and unnecessary decorative language.
- Keep interface copy short enough for compact mobile layouts.

## 9. Anti-patterns

- Do not replace the primary blue identity with another dominant accent color.
- Do not use color alone to communicate attendance status.
- Do not introduce unrelated visual themes, gradients, or accent colors without a product need.
- Do not overuse shadows; borders and surface contrast are part of the visual identity.
- Do not use decorative fonts for important attendance, timetable, or navigation information.
- Do not create separate visual systems for Student, Teacher, Class Teacher, and HOD; role differences should come from functionality and navigation.
- Do not use arbitrary one-off spacing, radius, typography, or color values when an existing design token can solve the problem.
- Do not flatten hierarchy by making headings, metadata, labels, and data values look identical.
- Do not turn the primary page background dark; white remains the dominant surface.
- Do not ignore the reference screenshot when implementing new screens; new screens should visually belong to the same product family.

## Canonical Implementation Tokens

```text
Primary            #136BB3
Secondary          #D0E1FB
Success            #48AE8C
Warning            #D0B238
Danger             #E57373
Missed             #775471
Record Now         #9DB6EE
Pending            #5F6B7A
Surface            #FFFFFF
Text               #000000
Text Secondary     #666666
Navigation         #262525
Outline            #1A1A1A
Gradient Top       #7198EE
Gradient Bottom    #163B8E

Poppins            Headings / major labels
Inter              General UI / data
Itim               Decorative only

Radius Small       8–10 px
Radius Medium      16 px
Radius Card        16–18 px
Radius Large       24 px
Radius Pill        30 px
Radius Full        9999

Spacing            4, 8, 12, 16, 20, 24, 32 px
```

## Final Precedence Rule

Use this document as the active design direction for future frontend work.

The **Primary** brand color is `#136BB3`. The screenshot-calibrated visual language takes precedence over older contradictory token descriptions. Shared Flutter tokens and components should be updated to match this system rather than introducing screen-specific styling.
