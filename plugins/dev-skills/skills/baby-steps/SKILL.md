---
name: baby-steps
description: Implements a task in tiny, individually approved steps — proposes only the next small change (one file, ~20 lines), explains what and why, shows the full diff in the chat without touching any file, and applies it only after the user approves; then runs the relevant tests/build and reports. Commits are proposed separately, never made automatically. Use when the user wants to stay in control of what goes into the code, review changes as they happen instead of one huge diff at the end, or says "baby steps", "step by step", "small steps", or "one step at a time".
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
- **One file per step.** A step creates, edits or deletes exactly one file. If
  a logical change touches several files (e.g. a new function and its import
  elsewhere), it is several consecutive steps. The only exception is the
  optional steps markdown (see *Step documentation*), which is updated
  together with each accepted step.
- **No change before approval.** Until the user approves, do not create, edit or
  delete any file. Show the proposed change only as a diff in a code block.
- **Diff first, then ask.** Write the What, Why, file and full diff in a chat
  message right before asking for approval. Do not put the diff in an
  `AskUserQuestion` preview — it doesn't fit there. The approval question
  itself names the file and says in one sentence what the change does, so the
  user knows what they are deciding even if the dialog covers the chat.
- **Show it all, verbatim.** Never summarize or abbreviate the diff (no `...`,
  no `{ ... }`, no "rest unchanged"). Apply only what was shown verbatim. If
  the diff is too long to show in full, the step is too big — split it.
- **Small steps.** One logical change in one file, typically ~20 lines or
  fewer — e.g. adding one function, the boilerplate of one endpoint, one new
  `if` branch. If a step grows bigger, split it.
- **Test first, typically.** A new test is usually its own step, and the next
  step usually makes it pass — but this is a habit, not a rule. Steps don't
  strictly follow TDD phases.
- **Red is fine between steps.** A step does not have to end with green tests;
  a temporarily failing test is accepted. Never make a step bigger just to get
  back to green — small, reviewable steps beat a green state.
- **Keep going until done.** After a step is applied and verified, show the
  next step (diff + approval prompt) in the same turn — never wait to be told
  to continue. Stop only when waiting for approval, or when the task (or the
  current PRD/plan slice) is fully done. Unsure what comes next? Ask the user
  a focused question — never stop silently.
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

## Step documentation (optional)

**At the very start, once — before the first step** — ask whether to document
the steps as they are accepted (`AskUserQuestion` when available, otherwise in
plain chat). Ask it once per task, never per step.

- **Yes:** also ask where the markdown should live. Default:
  `docs/steps/<slug>.md`, one file per task (`<slug>` is a short kebab-case
  name of the task).
- **No:** nothing is documented; the rest of the flow is unchanged.

When documentation is on:

- Every **accepted** step automatically appends an entry to the steps markdown
  in the same moment the step is applied: **what**, **why**, the touched
  **file** and the **full diff**. No separate approval for the entry — it is
  an explicit exception to the "one file per step" rule.
- Only the final accepted version of a step is recorded. Rejected or reworked
  variants are not.
- Entries are written in the user's language.
- The steps markdown is part of the commit: the commit proposal lists it among
  the files, so a reviewer can read the logical steps there.

## The step loop

0. **Ask about step documentation** — once, before the first step (see
   *Step documentation*).

1. **Show the next step in the chat.** In one message, state:
   - **What:** the change, in one or two sentences.
   - **Why:** why this step, why now, why this way.
   - **File:** the single file the step touches.
   - **Diff:** the planned change as a unified diff in a ```diff code block
     (new files shown as additions), complete and verbatim. Nothing is
     written to disk yet.

2. **Ask for approval — right after the diff.**
   - **With `AskUserQuestion`:** call it immediately after the message above,
     single-select, **no `preview`**. The `question` names the file, sums up
     the change in one sentence and says the full diff is above.
   - **In plain chat (fallback):** the approval question goes at the end of the
     same message as the diff. Stop right after it and wait for the answer.

   Offer these options:
   - **Approve** — apply the change.
   - **Request changes** — the user says what to change.
   - **Reject** — the approach is wrong; propose a different one.
   - **Allow a bigger step for this part** — the user lets you take larger steps
     for the current part.

3. **Handle the answer.**
   - *Approve:* apply exactly the shown diff — nothing more, nothing less. If
     documentation is on, append the step's entry to the steps markdown in the
     same moment. Do not commit.
   - *Request changes:* rework the step and show it again (back to 1).
   - *Reject:* propose a different approach as a new step (back to 1).
   - *Bigger step:* you may take larger steps, but **only for the current part**
     (the current function, endpoint, test group or slice). When moving to the
     next topic, return to small steps. Still one file per step, still show the
     diff and ask for approval.

4. **Verify.** After applying, run the relevant tests or build (the narrowest
   command that covers the change) and report the result briefly.
   - Red tests are information, not an alarm: report what fails and why (e.g.
     a test written in the previous step, or an expected gap).
   - Then propose the next **small** step — either the fix or the planned
     continuation, whichever is the better next move. Never fix silently.
   - **Never** propose a bigger change just to get back to green; that defeats
     the point of small, easy-to-review steps.

5. **Propose a commit when a unit is complete.** When a larger logical unit is
   done (a feature slice, a test with its implementation, a refactor),
   propose a commit as its own step: list the files (including the steps
   markdown, if documentation is on) and the commit message in the chat, then ask for approval the same way. Commit only after explicit
   approval.

6. **Continue — in the same turn.** Right after applying and verifying, show
   the next step (back to 1: diff + approval prompt) in the same response.
   Never end the turn with only a verification report, and never wait for the
   user to say "go on".
   - You may stop only in two situations: you are **waiting for approval**,
     or the task (or the current slice of the PRD/plan) is **fully done** —
     every point is covered.
   - If you are unsure what the next step is, do **not** stop silently: ask
     the user one focused question (e.g. which of two options, or whether a
     point is in scope), then continue from the answer.
   - When you think you are done, check the task/PRD points one by one and
     state for each what covers it (file, test or commit). If any point is
     not covered, it's not done — propose the next step for it. Otherwise say
     the task is done in one or two sentences.

## Step format

First, the chat message with the step:

~~~markdown
**Next step:** Add `parseDuration` returning minutes for "1h30m".

**Why:** The endpoint needs minutes; the failing test from the previous step
pins this behavior, and parsing belongs in a pure helper so it stays testable.

**File:** `src/duration.ts`

```diff
--- a/src/duration.ts
+++ b/src/duration.ts
@@ -0,0 +1,5 @@
+export function parseDuration(input: string): number {
+  const m = /^(?:(\d+)h)?(?:(\d+)m)?$/.exec(input);
+  if (!m) throw new Error(`Invalid duration: ${input}`);
+  return Number(m[1] ?? 0) * 60 + Number(m[2] ?? 0);
+}
```
~~~

Then, right after it, the approval dialog — short, no preview:

~~~json
{
  "questions": [{
    "header": "Next step",
    "multiSelect": false,
    "question": "src/duration.ts: add parseDuration, which turns \"1h30m\" into minutes. The full diff is shown above. Apply it?",
    "options": [
      { "label": "Approve", "description": "Apply exactly the diff shown above." },
      { "label": "Request changes", "description": "Tell me what to change." },
      { "label": "Reject", "description": "Wrong approach; propose another." },
      { "label": "Allow a bigger step", "description": "Larger steps for the current part only." }
    ]
  }]
}
~~~

Plain-chat fallback: the same message as above, ending with
"Approve, request changes, reject, or allow a bigger step for this part?" —
then stop.

If step documentation is on, approving the step above also appends this entry
to the steps markdown (e.g. `docs/steps/duration-endpoint.md`):

~~~markdown
## Step 3: Add `parseDuration` returning minutes for "1h30m"

**Why:** The endpoint needs minutes; the failing test from the previous step
pins this behavior, and parsing belongs in a pure helper so it stays testable.

**File:** `src/duration.ts`

```diff
--- a/src/duration.ts
+++ b/src/duration.ts
@@ -0,0 +1,5 @@
+export function parseDuration(input: string): number {
+  const m = /^(?:(\d+)h)?(?:(\d+)m)?$/.exec(input);
+  if (!m) throw new Error(`Invalid duration: ${input}`);
+  return Number(m[1] ?? 0) * 60 + Number(m[2] ?? 0);
+}
```
~~~

## Notes

- If you notice the next step can't be small (e.g. a generated file, a large
  move), say so and suggest asking for a bigger step rather than splitting it
  artificially.
- If a change only works when several files change together (e.g. a rename),
  still go one file per step, and say up front that the code won't build until
  the last of those steps lands.
- Don't chase green: if tests are red after a step, the next step is still
  one small change, not a catch-up batch.
- Don't batch several logical changes into one "small" step to save rounds.
- The skill works in any environment; it does not rely on any office-specific
  tooling.
