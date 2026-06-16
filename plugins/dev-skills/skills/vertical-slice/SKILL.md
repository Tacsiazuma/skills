---
name: vertical-slice
description: Turns a PRD (or feature spec) into a technical implementation plan and a task breakdown sliced into VERTICAL SLICES — each slice cuts through the whole stack (UI → API → domain → data) and delivers value on its own; we do NOT build layer by layer. Use when the user wants a PRD/spec turned into a technical plan and a value-driven, sliced task list.
---

# vertical-slice

From a PRD (or feature spec) you produce two things: **(1) a concise technical
implementation plan**, and **(2) a task breakdown sliced into vertical slices.**
The guiding rule: **every slice cuts through the whole stack and delivers
demoable value on its own** — we do not proceed layer by layer (all the DB
first, then all the backend, then all the UI).

## Principles

- **Vertical, not layered.** A slice is a thin, end-to-end cut through the stack
  (UI → API → domain/logic → data → integration) that produces one concrete,
  observable user or business value. A "backend only" or "data model only" task
  is NOT a slice — it is a layer.
- **Walking skeleton first.** The first slice is the thinnest possible
  end-to-end path that runs through the whole chain (hardcoded parts are fine)
  and proves the architecture holds together. It de-risks the rest.
- **Order by value + risk.** Sequence slices so the biggest value and the
  biggest technical risk are pulled forward. Fail early if you are going to fail.
- **Every slice is demoable.** A slice is "done" when you can demonstrate a
  user/business scenario. If there is nothing to demo, it is not a standalone
  slice — fold it into the slice that needs it.
- **Thin slices.** Prefer many small ones that each ship something over one big
  one. If a slice is too big, split it along a narrower scenario (e.g. the happy
  path for one user type first, edge cases and other types later).
- **Match the input language.** Write the plan in the language the PRD was
  given in.

## 1. Read the input

- If the user provided the PRD (text or file), start from it. If they reference
  a file, read it. If there is no PRD, ask for it with one short question.
- Extract from the PRD the **goal / business value**, the **user journeys**, and
  the **success criteria**. These define the slice boundaries.
- Look at the codebase if there is one: the existing architecture, stack and
  patterns decide what is a realistic technical approach and what can be reused.

## 2. Clarify (only what is blocking)

Do not interrogate the user — the goal is the plan, not a grilling. **Only ask**
(`AskUserQuestion`) when, without the answer, the technical approach or the
slicing would be materially different (e.g. a key integration, scale, or
constraint is unclear). Record everything else as a **stated assumption** in the
plan and move on.

## 3. Sketch the technical approach

Concise and decision-oriented — not a book. It covers:

- **Architecture in a nutshell** — main components and how they fit together;
  what is reused from the existing system, what is new.
- **Data model changes** — new/changed entities, key fields.
- **Key technical decisions** — the important choices and a short rationale (not
  every detail, only what matters).
- **Risks / unknowns** — what is most uncertain, and which slice validates it.
- **Assumptions** — everything the PRD did not state but the plan relied on.

## 4. Identify vertical slices

- Start from the user journeys / scenarios, not the components. Each slice is one
  concrete capability a user/system can carry through.
- The **first slice is the walking skeleton**: the thinnest end-to-end happy path.
- Order slices by value + risk. Mark dependencies between them.
- Keep slices thin and independently demoable (INVEST-style: independent,
  valuable, small, testable).

## 5. Task breakdown per slice

- For each slice, list the tasks that **cut through the whole stack** (data,
  backend, API, frontend, tests — as much as the slice needs).
- Tasks should be concrete and, within a slice, fulfill the demoable scenario.
  Put purely technical work (e.g. migration, infra) into the slice that first
  needs it — do not create a standalone "layer 0" slice.
- Give each slice a **demo / acceptance** line: what can be shown when it is done.

## 6. Output: the plan document

Write a markdown file, **in the input language**, here:
`implementation-plans/<short-kebab-slug>.md` (the slug from the feature title).
Create the folder if it does not exist.

Sections:

```markdown
# <Feature> — technical plan and slicing

## Overview / business value
What and why — from the PRD.

## Technical approach
- Architecture in a nutshell
- Data model changes
- Key technical decisions (+ short rationale)
- Risks / unknowns
- Assumptions

## Vertical slices (in order)
Table or list: slice name · value delivered · demo · dependency.

## Slices in detail
### Slice 1 — <name> (walking skeleton)
**Value:** ...
**Demo / acceptance:** ...
**Tasks (across the stack):**
- [ ] ...
- [ ] ...

### Slice 2 — <name>
...

## Ordering rationale
Why this order (value + risk).

## Open questions
```

Only fill in the sections you have content for. After writing the file, give a
short summary in the chat (number of slices, what the first demoable thing is),
and provide the file path.

## Notes

- This skill produces a *plan*, not code. At the end, ask whether to start
  implementing the first slice.
- If the PRD is still vague or contradictory, say so and suggest the `clarify`
  or `feature-grill` skill as a prerequisite.
- If the plan looks complexity-prone, trim it in the spirit of `grug`: the
  thinnest slice that ships always beats full up-front planning.
