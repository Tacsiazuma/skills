---
name: clarify
description: Runs an interrogation session — asks the user one focused question at a time to turn a vague request, idea, or problem into a clear, actionable understanding, then writes a short summary of what was settled. Use when a request is ambiguous, underspecified, or could be interpreted multiple ways, and you need to pin down scope, intent, and constraints before acting.
---

# clarify

Drive a back-and-forth interrogation session that turns a fuzzy request into a precise, agreed-upon understanding. The goal is not to gather every possible detail — it is to remove the ambiguity that would otherwise lead to building the wrong thing.

## Principles

- **One question at a time.** Ask a single, focused question, wait for the answer, then decide the next one based on it. Never dump a numbered list of questions.
- **Follow the uncertainty.** Each question should target the thing you are currently least sure about and that most changes what you would do next.
- **Cheapest clarification first.** Resolve high-impact ambiguities (scope, intent, success criteria) before low-impact details (naming, formatting).
- **Don't ask what you can infer.** If the codebase, context, or sensible defaults already answer something, state your assumption instead of asking. Only ask when the answer would actually change your approach.
- **Reflect, don't interrogate blindly.** Briefly play back what you heard before moving on, so misunderstandings surface early.

## Process

1. **Restate the request** in one or two sentences as you currently understand it. This anchors the session and exposes obvious misreadings immediately.

2. **Probe the dimensions that matter**, one question per turn, roughly in this order of leverage:
   - **Intent / problem** — what is the user actually trying to achieve, and why? What's the underlying need behind the stated request?
   - **Scope** — what's in, what's explicitly out? How big is this?
   - **Success criteria** — how will we know it's done and correct? What does "good" look like?
   - **Constraints** — deadlines, tech/stack limits, things that must not change, non-negotiables.
   - **Security & trust** — who can access or trigger this? Is there auth/authz involved? What data is sensitive? What happens if it's abused or called by an untrusted party? Even if security seems out of scope, name the assumption explicitly.
   - **Edge cases & failure modes** — what should happen when things go wrong or input is unexpected?
   - **Audience / context** — who uses or reads the result, and in what environment?

   Skip any dimension that's already clear. Add others if the topic demands it.

3. **Stop when it's clear enough.** End the session once you could confidently act without guessing on anything that matters. Don't pad it with low-value questions — over-interrogation is a failure mode too.

4. **Resolve before you close.** Before writing the summary, scan for anything still unresolved. If something is genuinely unresolvable without the user, ask one more targeted question rather than leaving it open. Only record a remaining open question if it truly cannot be answered now and does not block starting work.

5. **Write a summary.** Produce a short, structured recap of what was settled:

   ```markdown
   ## Clarified understanding

   **Goal:** ...
   **In scope:** ...
   **Out of scope:** ...
   **Success criteria:** ...
   **Constraints:** ...
   **Security assumptions:** ...
   **Assumptions made:** ...
   **Remaining open questions:** ...
   ```

   `Remaining open questions` should be empty or near-empty. If it isn't, the session ended too early. Each assumption should be explicit enough that the user can contradict it if wrong.

## Notes

- This skill produces *understanding*, not implementation. After the summary, ask whether the user wants to proceed with the work.
- If the user gives a short or vague answer, ask a sharper follow-up rather than moving on with a guess.
- If at any point the request turns out to be clear and unambiguous, say so and skip straight to the summary — don't manufacture questions.
