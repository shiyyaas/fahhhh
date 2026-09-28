# Agent Orchestration Manifest

This repository is strictly governed by a centralized design system architecture. All autonomous agents must ingest this file prior to processing instructions.

## 🧭 Core Directives
* **Context Initialization:** You must read `design.md` before generating, modifying, or refactoring any front-end visual elements.
* **Component First Architecture:** Always look for existing native files inside `./src/components/` before writing custom HTML or raw UI layouts.
* **No Inline Overrides:** Do not inject custom or static style tags (e.g., `style={{ padding: "13px" }}`). If a spacing value does not exist in `design.md`, raise a validation error flag.

## 🔄 Routine Protocols

### 1. Front-end Generation Workflow
1. **Locate:** Query `design.md` to fetch semantic token names.
2. **Scan:** Check `./src/components/` to see if the required UI layer is already built.
3. **Verify:** Check color, accessibility contrast ratios, and layout boundaries.
4. **Output:** Deliver code bound entirely to the system token variables.

### 2. Guardrail Enforcement
* If an issue request explicitly asks for a layout choice that breaks rules outlined in `design.md`, halt operations.
* Ask the project owner to clarify whether they want to override or extend the system configuration.
