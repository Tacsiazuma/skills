---
name: github-issue
description: Creates a GitHub issue in a repository. If the current directory is a git repo, defaults to that repo. Collects title, body, labels, and assignees interactively. Use when asked to open/create a GitHub issue, file a bug, or log a feature request on GitHub.
---

# github-issue

Create a GitHub issue in a target repository — interactively if details are missing,
or directly if the user already provided everything.

## Ground rules

- **Ask ONE question at a time**, wait for the answer before moving on.
- **Follow the input language.** If the user spoke Hungarian, ask in Hungarian.
- **Prefer defaults.** If a value can be inferred (e.g. current repo from `git remote`),
  use it as the pre-selected option rather than asking blindly.
- Never create the issue until you have at least a **repo** and a **title**.

## 1. Determine the repository

Run `gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null` to detect the
current repo.

- If it succeeds, offer it as the default via `AskUserQuestion` (with "Use this repo"
  and "Enter a different repo" options).
- If it fails (not a git repo, or no remote), ask the user to provide the repo in
  `owner/repo` format.

## 2. Collect issue details

Ask for any fields not already provided by the user when invoking the skill:

1. **Title** — short, imperative sentence describing the issue.
2. **Body** — Use `AskUserQuestion` to ask whether they want a body or skip.
   If they want one, **draft it yourself** from the conversation context before asking.
   A good body includes: background/current state, exact changes with file paths,
   acceptance criteria or step-by-step task list, and any technical constraints.
   Present the draft as the pre-selected option — the user can override via "Other".
   The body must be detailed enough for someone with no prior context to implement it.
   Never offer a one-liner summary as the body.
3. **Labels** (optional) — run `gh label list -R <repo> --json name -q '.[].name'`
   to list available labels; offer them as multi-select options plus a "Skip" option.
4. **Assignees** (optional) — ask if they want to assign someone; accept a GitHub
   username or "Skip".

## 3. Confirm before creating

Before running `gh issue create`, show a brief summary:

```
Repo:      owner/repo
Title:     <title>
Labels:    <labels or none>
Assignees: <assignee or none>
Body:
  <first 3 lines…>
```

Ask "Create this issue?" (Yes / Edit / Cancel).

- **Yes** → proceed.
- **Edit** → loop back and ask which field to change.
- **Cancel** → abort with a message.

## 4. Create the issue

```bash
gh issue create \
  --repo <owner/repo> \
  --title "<title>" \
  --body "<body>" \
  [--label "<label>"] \
  [--assignee "<assignee>"]
```

Repeat `--label` for each label. Omit `--body` if the user skipped it (GitHub
will use an empty body). Do not use `--editor` or `--web` flags.

## 5. Output

After the command succeeds, print the returned issue URL in the chat and nothing else.
If `gh issue create` fails, show the error and ask how to proceed.
