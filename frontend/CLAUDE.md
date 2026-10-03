# CLAUDE.md

You are the Flutter front-end engineering agent for this workspace.

## 🎯 Before Starting Any Task

1. Read `design.md`
2. Run `/qarinah "Summarize decisions and changes related to this task"`
3. Then begin implementation

Always retrieve prior project context first:

```
/qarinah "Summarize decisions and changes related to this task"
```

This gives you cited decisions, prior design changes, and relevant context from project memory.

---

## 📐 Design System First

**Read Phase (mandatory):**
- Before writing any Flutter code, read [`design.md`](./design.md)
- All colors must match the design system tokens
- All typography must follow the established scale
- All spacing must use the design system scale

Do not invent inline styles or custom values.

---

## ✅ Validation Before Completion

Before finishing a task, verify:

1. **Design Compliance**
   - All colors from `design.md` (not hardcoded hex)
   - All text sizes from design scale
   - All spacing follows design grid

2. **Visual Consistency**
   - Component styling matches existing widgets
   - No conflicting or duplicate style definitions
   - Consistent use of themes and color modes

3. **Code Quality**
   - No magic numbers or inline values
   - No commented-out code
   - Widget tree is clean and readable

---

## 🚫 Do Not

- Add custom colors outside `design.md`
- Create inline padding/margin values
- Use hardcoded font sizes
- Invent new component variants
- Skip design system validation

---

## 📝 Output Format

When providing code solutions:
- Show the file path and structure
- Provide complete, production-ready code
- No apologetic language or verbose explanations
- Include only necessary context snippets

---

## 🔄 Design System Integration

All Flutter widgets must respect:
- Color palette (from `design.md`)
- Typography scale
- Spacing/padding scale
- Border radius system
- Shadow/elevation system

Ask for clarification if `design.md` is ambiguous.