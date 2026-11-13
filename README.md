# tacsiazuma-skills

A personal [Claude Code](https://claude.com/claude-code) skill collection, packaged as a plugin marketplace.

## Structure

```
.
├── .claude-plugin/
│   └── marketplace.json        # marketplace manifest (this is what Claude Code reads)
├── plugins/
│   ├── dev-skills/             # a plugin
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json     # plugin manifest
│   │   └── skills/
│   │       └── clarify/
│   │           └── SKILL.md    # a skill
│   └── product-skills/         # another plugin
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
│           └── sales-funnel-audit/
│               └── SKILL.md
└── README.md
```

- A **marketplace** groups one or more plugins.
- A **plugin** contains one or more skills (and optionally commands, agents, hooks).
- A **skill** is a `SKILL.md` with frontmatter (`name`, `description`) and instructions.

## Skills

### `dev-skills`

| Skill | What it does |
|-------|--------------|
| `clarify` | Runs an interrogation session — asks one focused question at a time to turn a vague request into a clear, actionable understanding. |
| `grug` | Channels grugbrain.dev — fights complexity, says no, favors the boring 85% solution. Plain prose, cites grug principles. |
| `grug-review` | Reviews a diff for complexity only, one line per finding (`say-no`, `cut-point`, `demon`, ...). |
| `vertical-slice` | Turns a PRD into a technical plan + task breakdown sliced into vertical, demoable increments — value-first, not layer-by-layer. |
| `baby-steps` | Implements a task in tiny, individually approved steps — proposes only the next ~20-line, single-file change with its reason, shows the diff in chat, applies it after approval, runs tests, never commits on its own. |
| `github-issue` | Creates a GitHub issue in a repo, collecting title, body, labels and assignees interactively. |

### `product-skills`

| Skill | What it does |
|-------|--------------|
| `sales-funnel-audit` | Opens a URL in a real browser (Playwright MCP), walks the conversion path on desktop + mobile, and reports what is costing sales — prioritized, evidence-backed. Takes an optional angle (audience, traffic type, worry) to narrow the lens. |
| `shall-we` | Evaluates whether an idea is worth building — asks focused questions one at a time, then delivers a yes / no / later verdict with reasoning and what would need to be true for a "yes". Moved here from the archived `Tacsiazuma/shall-we` repo. |

## Requirements

Most skills need nothing beyond the agent itself. Exception:

- `sales-funnel-audit` drives a real browser and needs the Playwright MCP server:

  ```
  claude mcp add playwright -- npx @playwright/mcp
  ```

## Installation

Every tool below reads skills in the same Agent Skills format (`<skills-dir>/<skill>/SKILL.md` with `name` + `description` frontmatter), so no conversion is needed. Paths were checked against each tool's official docs (see [Sources](#sources)).

### Any agent: `npx skills` (Vercel)

[Vercel's `skills` CLI](https://github.com/vercel-labs/skills) ([skills.sh](https://skills.sh)) finds every skill under `plugins/*/skills/*` and installs it for one or more agents (Claude Code, Copilot, Codex, Cursor and many more). Tested with `skills` 1.8.1.

```
npx skills add Tacsiazuma/skills                          # all skills; prompts for agents in a terminal
npx skills add Tacsiazuma/skills --list                   # list available skills, install nothing
npx skills add Tacsiazuma/skills --skill clarify --skill grug   # only some skills
```

Target and scope:

```
npx skills add Tacsiazuma/skills -a claude-code -a cursor -y   # specific agents, no prompts
npx skills add Tacsiazuma/skills -g -a codex                    # global (user-level)
npx skills add Tacsiazuma/skills --all                          # all skills, all agents, no prompts
```

Project scope (the default) writes into the current directory (`.agents/skills/`, plus symlinks such as `.claude/skills/` for agents that need their own folder) and a `skills-lock.json`; `-g` installs to your home directory instead. `--copy` copies instead of symlinking. Agent ids include `claude-code`, `github-copilot`, `codex`, `cursor`; an invalid id prints the full list. Later: `npx skills update`, `npx skills remove`.

Use this when you want one command for any agent or several at once; use the plugin marketplace for Claude Code/Copilot updates through the tool itself, or `install.sh` if you don't want a Node/npx dependency.

### Claude Code

**Marketplace** (once pushed to GitHub, e.g. `tacsiazuma/skills`):

```
/plugin marketplace add tacsiazuma/skills
/plugin install dev-skills@tacsiazuma-skills
/plugin install product-skills@tacsiazuma-skills
```

Or locally, while developing: `/plugin marketplace add /path/to/skills`

**Manual** (no marketplace): `./install.sh --tool claude` → `~/.claude/skills/` (user) or `.claude/skills/` (project, `--scope project`).

### GitHub Copilot

**Marketplace** (Copilot CLI reads the same `.claude-plugin/marketplace.json`):

```
copilot plugin marketplace add tacsiazuma/skills
copilot plugin install dev-skills@tacsiazuma-skills
copilot plugin install product-skills@tacsiazuma-skills
```

**Manual:** `./install.sh --tool copilot` → `~/.copilot/skills/` (user) or `.github/skills/` (project). Works in Copilot CLI, VS Code agent mode, and the cloud agent (project skills only there; personal skills are not automatically available in the cloud).

### Codex

**Marketplace:** the Codex docs I could read describe plugin import from GitHub only in the ChatGPT admin UI (Admin → Plugins, which accepts `.claude-plugin/marketplace.json`), and a `/plugins` browser in the CLI. I could not verify a documented CLI command to add this repo as a marketplace, so use the manual install below.

**Manual:** `./install.sh --tool codex` → `~/.agents/skills/` (user) or `.agents/skills/` (project). Codex follows symlinked skill folders. Restart Codex if a new skill does not show up.

### Cursor

**Marketplace:** this repo ships `.cursor-plugin/marketplace.json` and a `.cursor-plugin/plugin.json` per plugin. In Cursor: Dashboard → Plugins & MCPs → Add Marketplace → Import from Repo → paste the repo URL (team marketplaces). *Not tested by me; written from the Cursor docs, which document no CLI command.*

**Manual:** `./install.sh --tool cursor` → `~/.cursor/skills/` (user) or `.cursor/skills/` (project).

### `install.sh`

One-liner (no clone; downloads the repo to a temp dir; options go after `-s --`):

```
curl -fsSL https://raw.githubusercontent.com/Tacsiazuma/skills/main/install.sh | bash -s -- --tool copilot
curl -fsSL https://raw.githubusercontent.com/Tacsiazuma/skills/main/install.sh | bash -s -- --tool cursor --scope project clarify grug
```

Set `SKILLS_REF=<branch|tag>` to install from something other than `main`. `--mode symlink` needs a local clone. Overwrite prompts read from the terminal (`/dev/tty`); without one, existing skills are skipped unless `--force`.

Or from a clone:

```
git clone https://github.com/tacsiazuma/skills && cd skills
./install.sh --tool copilot --scope project --project-dir ~/code/myapp
./install.sh --tool codex clarify grug        # only some skills
./install.sh --tool cursor --mode symlink     # stay in sync with this checkout
./install.sh --list
```

Options: `--tool claude|copilot|codex|cursor` (required), `--scope user|project` (default `user`), `--mode copy|symlink` (default `copy`), `--project-dir DIR` (default: current dir), `--force`, `--list`, then an optional list of skills (default: all). An existing skill is never overwritten without confirmation; non-interactively it is skipped unless `--force` is given.

### `sales-funnel-audit` needs Playwright MCP

Whichever tool you use, `sales-funnel-audit` drives a real browser and needs the Playwright MCP server configured in that tool (command: `npx @playwright/mcp`):

- Claude Code: `claude mcp add playwright -- npx @playwright/mcp`
- Copilot (CLI): add it with `/mcp add`, or in `~/.copilot/mcp-config.json`; VS Code: `.vscode/mcp.json`
- Codex: `codex mcp add playwright -- npx @playwright/mcp`
- Cursor: `.cursor/mcp.json` (project) or `~/.cursor/mcp.json` (user), with `"command": "npx", "args": ["@playwright/mcp"]`

*The MCP configuration commands/paths above are from my knowledge of those tools and were not verified against the docs; check each tool's MCP docs.*

### Sources

- Copilot: docs.github.com — "About agent skills", "Creating agent skills", Copilot CLI plugin reference; VS Code "Agent Skills"
- Codex: learn.chatgpt.com/docs/build-skills (formerly developers.openai.com/codex/skills)
- Cursor: cursor.com/docs/context/skills, cursor.com/docs/plugins

## Adding a new skill

1. Create a directory: `plugins/<plugin-name>/skills/<skill-name>/`
2. Add a `SKILL.md`:

   ```markdown
   ---
   name: skill-name
   description: What it does and when Claude should use it. Be specific — this drives invocation.
   ---

   # Skill name

   Instructions for Claude...
   ```

3. The `description` is the most important field: it decides when Claude invokes the skill.

## Adding a new plugin

1. Create `plugins/<plugin-name>/` with a `.claude-plugin/plugin.json`.
2. Add it to the `plugins` array in `marketplace.json`.
