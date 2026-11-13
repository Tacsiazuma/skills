# baby-steps skill

## Goal

A new skill in the `dev-skills` plugin, named `baby-steps`: it lets the user carry an implementation through with the agent in tiny, individually approved steps, each with its rationale. At the end there is no 600-line diff that has to be reviewed in one go.

## Problem

When the agent writes the change in one go, the user only meets it at the end, during review, and two problems show up at once:

- the diff is too large to review meaningfully;
- it is not visible why the code is the way it is: the reasoning behind the decisions is lost.

The goal of the skill is for the review to happen along the way, step by step, together with the whys.

## Users and journeys

User: the developer who works with an agent on an implementation and wants to stay in control of what goes into the code.

How a step goes:

1. The skill's input is an arbitrary task. If there is a PRD or a vertical-slice plan, it works from that; if not, from the description.
2. The agent proposes **only the next step**, without a full list of steps.
3. It describes **what it will do and why**.
4. It shows the planned change (diff), but **does not modify anything** until it is approved.
5. The user responds:
   - **Approve**: the agent applies the change. No commit is made at this point.
   - **Request changes**: the agent reworks it and shows it again.
   - **Reject**: the agent proposes a different approach.
   - **Skip / allow a bigger step for this part**: the agent may take a bigger step for that part.
6. After applying, the relevant test or build runs, and the agent reports the result.
7. When a larger logical unit has come together, the agent **proposes a commit**. The commit is a separate step, with separate approval.
8. The cycle continues with the next step **without interruption**: after applying and verifying a step, the agent shows the next step **on its own, in the same turn**, without waiting for a separate prompt.
9. The cycle ends when **every item** of the task (or of the current slice of the PRD / plan) is done. If the agent is unsure what the next step is, it **does not stop silently**; instead it asks the user a targeted question.

## In scope

- A new `SKILL.md`: `plugins/dev-skills/skills/baby-steps/SKILL.md`, in English, like the other skills. The agent communicates in the user's language.
- An entry in the skill table of `README.md`.
- Step size: one logical change, typically 20 lines or fewer. Examples: adding a function, the boilerplate of an endpoint, a new `if` branch.
- Test-first mindset: the test is typically a separate baby step, and the next step makes it green. The steps **do not strictly follow the TDD phases**, and not every one has to end with a green test: an intermediate red state is acceptable.
- After every applied step, running the relevant tests or the build and reporting the result (a red result is just information too, not an error).
- Asking for approval in whatever form is available in the given environment. `AskUserQuestion` is preferred when available.
- Proposing a commit after a larger logical unit, as a separate step.

- Continuity: the agent stops in only two situations: it is waiting for approval, or the task is done. After approval and applying, it never sits there waiting for the user to say something before continuing.

## Out of scope

- Turning the task into a PRD or breaking it into vertical slices (that is done by the `clarify` and `vertical-slice` skills).
- Maintaining a full, predefined list of steps or a progress table.
- Automatic commit after approval.
- Code review at the end (the very purpose of the skill is to replace it).

## Success criteria

- There is no diff the user receives in one go, without rationale: every change arrives as a proposed, justified step.
- The file system does not change before approval.
- The diff of a typical step is roughly 20 lines or smaller, even if this leaves the test temporarily red.
- The user sees the why at every step, and each of the four responses (approve, request changes, reject, bigger step) is handled.
- During development the agent does not stop before the task is finished: after an applied step there is always either the next step, a targeted question, or the "done" signal with no missing items.
- A commit is only made upon a separate proposal and after separate approval.

## Constraints

- The repo convention: `plugins/<plugin>/skills/<name>/SKILL.md`, with frontmatter (`name`, `description`).
- The skill is environment-independent: it must also work outside the office, so it cannot depend on `office-ask`.

## Open questions and assumptions

Assumptions (decided by the code or a reasonable default, not open questions):

- "Allow a bigger step" applies to the given part; on the next topic the agent returns to small steps.
- If the test is red after a step, the agent reports it and proposes the next small step (either the fix or the planned continuation); it does not change things silently. **It never proposes a bigger change because of a red test**: the principle of small, easily reviewable steps is stronger than a green state.
- The diff is shown as text (a code block); no separate tool is needed for it.
- For this request there are no open questions left that the user could still answer.
