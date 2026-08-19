---
name: sales-funnel-audit
description: Audits a live web page or funnel from a SALES perspective — opens it in a real browser with Playwright, walks the conversion path (landing → offer → CTA → form/checkout) on desktop and mobile, and reports what is costing conversions, prioritized, each finding backed by evidence from the page. Accepts an optional angle (audience, traffic type, price sensitivity, a specific funnel stage) to narrow the lens. Use when the user wants a landing page, sales page, pricing page, or funnel reviewed, asks "why doesn't this convert", or wants a conversion/CRO audit of a URL.
---

# sales-funnel-audit

Open a real page in a real browser, walk it the way a prospect would, and report
what is losing the sale. The output is **not** a generic CRO checklist — it is a
prioritized list of concrete problems found **on this page**, each one quoting
what is actually there.

## Principles

- **Evidence or it didn't happen.** Every finding must cite something you
  actually observed: a quoted headline, a button label, a form field count, a
  measured load time. Never report a problem you did not see on the page. If you
  could not verify something, say so instead of assuming it.
- **Sales lens, not design lens.** You are not reviewing aesthetics. Every
  finding answers: *why does this cost a sale?* Beautiful pages that don't sell
  are still broken; ugly pages that convert are fine.
- **The visitor is impatient, skeptical, and distracted.** Judge the page as
  someone who arrived 4 seconds ago, doesn't trust you, and has a competitor tab
  open.
- **Prioritize brutally.** Three problems that cost real money beat twenty
  observations. Lead with what matters.
- **Match the input language.** Write the audit in the language the user is
  speaking, regardless of the page's language.

## 1. Get the inputs

Required: **the URL**.

Optional: **the angle** — if the user supplies one, it narrows the lens and
sharpens every finding. Angles worth supporting:

- **Audience** — who the visitor is (e.g. "technical founder", "HR manager at a
  200-person company", "complete beginner").
- **Traffic type** — cold ad traffic, warm newsletter, organic search, referral.
  Cold traffic needs far more context and trust-building than warm.
- **Specific worry** — "the price feels too high", "nobody fills the form",
  "high bounce on mobile".
- **Funnel stage** — audit only the pricing page, only the checkout, etc.

If no angle is given, **do not interrogate the user**. Ask at most one question
— who the intended visitor is — and if they don't care, audit for cold traffic
(the harshest realistic case) and state that assumption in the output.

## 2. Open the page

Use the **Playwright MCP tools** (`browser_navigate`, `browser_snapshot`,
`browser_take_screenshot`, `browser_resize`, `browser_click`, `browser_fill_form`).

If those tools are not available in the session, stop and tell the user to add
the server, then continue once it's there:

```
claude mcp add playwright -- npx @playwright/mcp
```

Do **not** fall back to plain HTML fetching and pretend it's equivalent —
modern landing pages render in JS, and a fetch would make you audit an empty
shell. If the user insists on no browser, tell them what you can't verify
(rendering, mobile layout, interactions, load feel) and audit only the copy.

Walk the page:

1. **Desktop first.** Navigate, take a snapshot and a screenshot. Read what is
   above the fold before scrolling.
2. **Scroll the whole page.** Capture the sections in order — the sequence of
   the argument matters as much as its content.
3. **Mobile.** Resize to a phone viewport (e.g. 390×844) and repeat. Most
   traffic is mobile and most funnels break there: stacked CTAs pushed below
   three screens, unreadable tables, sticky bars covering the button.
4. **Follow the path.** Click the primary CTA and see where it leads. Count the
   steps and form fields between "interested" and "converted". Do not submit
   real data or complete a purchase — stop at the last step before commitment.
5. **Note the feel.** Slow loads, layout shift, cookie walls, popups firing
   instantly — these kill conversions before a word is read.

## 3. Audit the funnel

Go through these stages. Skip any that don't apply; add whatever the page
demands.

- **First 5 seconds** — from the fold alone, is it clear *what this is*, *who
  it's for*, and *what to do next*? A visitor who has to scroll to find out what
  you sell is already half gone.
- **Offer clarity** — what exactly is being sold, at what price, with what
  outcome? Vague benefits ("boost your productivity") vs. concrete promises.
- **Relevance to the visitor** — does it name the prospect's problem in their
  own words, or does it talk about the company ("we are a leading provider")?
- **Trust** — social proof, real names and faces, numbers, logos, guarantees,
  refund policy, security signals. Are testimonials specific and credible, or
  generic filler?
- **Objection handling** — price, time, effort, risk, "will this work for *my*
  case?", "what happens after I buy?". Which objections go unanswered?
- **The CTA** — is there one obvious primary action? Is the label about the
  visitor's outcome ("Get my audit") or the mechanism ("Submit")? Is it visible
  without hunting on both desktop and mobile? Are there competing CTAs?
- **Friction** — form field count (every extra field costs), forced account
  creation, unexplained required data, unclear pricing until checkout,
  surprise fees, no guest checkout.
- **Leaks** — links that carry the visitor away at the moment of decision
  (nav menu, blog, social icons, footer sprawl on a dedicated landing page).
- **Next step clarity** — after converting, does the visitor know what happens?
  Ambiguity here causes hesitation before the click, not after.

## 4. Write the audit

Write a markdown file at `sales-audits/<domain>-<YYYY-MM-DD>.md`, in the user's
language. Create the folder if needed.

```markdown
# Sales funnel audit — <page/site> (<date>)

**URL:** ...
**Angle:** <the angle used, or "cold traffic, assumed">
**What I checked:** desktop + mobile, path up to <where you stopped>

## Verdict
Two or three sentences: does this page sell, and what is the single biggest
thing standing in the way?

## Top problems (in priority order)

### 1. <Short problem name> — <impact: high/medium/low>
**What's there:** "<quoted headline / button label / observed fact>"
**Why it costs sales:** ...
**Fix:** <concrete, specific — a rewritten headline, a removed field, a moved
CTA. Not "improve the messaging".>

### 2. ...

## What already works
Short list — do not let the user break the parts that are doing the selling.

## Not verified
What you could not check (paid flow, logged-in state, A/B variant you may have
landed in, analytics you don't have access to).
```

Then give a short chat summary: the verdict, the top 3 problems in one line
each, and the file path.

## Notes

- **You saw one visit, not the data.** You can spot broken persuasion; you
  cannot know the conversion rate. Frame findings as hypotheses to test where
  the impact is genuinely uncertain, and say plainly when something is simply
  broken.
- You may have landed in one variant of an A/B test, or a geo/language-targeted
  version. Note it if the page hints at it.
- If the page is behind a login, paywall, or bot wall, say what blocked you and
  ask for credentials or a screenshot rather than auditing the error page.
- Don't submit forms with fake data on a live site — it pollutes the user's CRM
  and may trigger real emails. Stop at the final step and describe it.
- If the user wants the copy rewritten rather than audited, that's a different
  job — offer it as a follow-up.
