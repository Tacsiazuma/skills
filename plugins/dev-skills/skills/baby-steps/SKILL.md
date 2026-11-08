---
name: baby-steps
description: Implements a task in tiny, individually approved steps — proposes only the next small change (~20 lines), explains what and why, shows it as a diff without touching any file, and applies it only after the user approves; then runs the relevant tests/build and reports. Commits are proposed separately, never made automatically. Use when the user wants to stay in control of what goes into the code, review changes as they happen instead of one huge diff at the end, or says "baby steps", "step by step", "small steps", or "one step at a time".
---

# baby-steps

Drive an implementation as a sequence of tiny, reviewed steps. Each step is
proposed, justified and approved **before** it touches the code. The goal: the
user never receives a big, unexplained diff — review happens continuously, one
small change at a time, with the reasoning attached.

## Principles

- **Only the next step.** Propose exactly one step. Never present a full step
  list, roadmap or progress table — decide the next step after the current one
  lands.
- **What and why.** Every step says what it changes and why this is the right
  next move. The reasoning is the point; don't skip it.
- **No change before approval.** Until the user approves, do not create, edit or
  delete any file. Show the proposed change only as a diff in a code block.
- **Small steps.** One logical change, typically ~20 lines or fewer — e.g. adding
  one function, the boilerplate of one endpoint, one new `if` branch. If a step
  grows bigger, split it.
- **Test first.** A test is its own step. The step after it makes the test pass.
- **Never commit on your own.** Applying a step does not commit. Commits are
  proposed as separate steps with their own approval.
- **Speak the user's language.** Reply in the language the user writes in.

## Input

The task can be anything:

- a PRD or a `vertical-slice` plan — work through it, picking the next step
  from the current slice;
- a plain description — work from that.

Read the referenced files and the relevant code first. Breaking the work into a
PRD or slices is out of scope; if the task is too vague to pick a first step,
suggest the `clarify` or `vertical-slice` skill instead.

## The step loop

1. **Propose the next step.** Briefly state:
   - **What:** the change, in one or two sentences.
   - **Why:** why this step, why now, why this way.
   - **Diff:** the planned change as a unified diff in a ```diff code block
     (new files shown as additions). Nothing is written to disk yet.

2. **Ask for approval.** Use the `AskUserQuestion` tool if it is available;
   otherwise ask in plain chat. Offer these options:
   - **Approve** — apply the change.
   - **Request changes** — the user says what to change.
   - **Reject** — the approach is wrong; propose a different one.
   - **Allow a bigger step for this part** — the user lets you take larger steps
     for the current part.

3. **Handle the answer.**
   - *Approve:* apply exactly the shown diff. Do not commit.
   - *Request changes:* rework the step and show it again (back to 2).
   - *Reject:* propose a different approach as a new step (back to 1).
   - *Bigger step:* you may take larger steps, but **only for the current part**
     (the current function, endpoint, test group or slice). When moving to the
     next topic, return to small steps. Still show the diff and ask for approval.

4. **Verify.** After applying, run the relevant tests or build (the narrowest
   command that covers the change) and report the result briefly.
   - A test written in the previous step is expected to fail — say so.
   - If something fails unexpectedly, report it and propose the fix as a
     **separate step**. Never fix silently.

5. **Propose a commit when a unit is complete.** When a larger logical unit is
   done (a feature slice, a passing test with its implementation, a refactor),
   propose a commit as its own step: show the files and the commit message, and
   ask for approval the same way. Commit only after explicit approval.

6. **Continue** with the next step (back to 1) until the task is done. Then say
   so in one or two sentences.

## Step format

~~~markdown
**Next step:** Add `parseDuration` returning minutes for "1h30m".

**Why:** The endpoint needs minutes; the failing test from the previous step
pins this behavior, and parsing belongs in a pure helper so it stays testable.

```diff
--- a/src/duration.ts
+++ b/src/duration.ts
@@ ...
+export function parseDuration(input: string): number { ... }
```
~~~

## Notes

- If you notice the next step can't be small (e.g. a generated file, a large
  move), say so and suggest asking for a bigger step rather than splitting it
  artificially.
- Don't batch several logical changes into one "small" step to save rounds.
- The skill works in any environment; it does not rely on any office-specific
  tooling.
