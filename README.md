# tacsiazuma-skills

A personal [Claude Code](https://claude.com/claude-code) skill collection, packaged as a plugin marketplace.

## Structure

```
.
├── .claude-plugin/
│   └── marketplace.json        # marketplace manifest (this is what Claude Code reads)
├── plugins/
│   └── dev-skills/             # a plugin
│       ├── .claude-plugin/
│       │   └── plugin.json     # plugin manifest
│       └── skills/
│           └── clarify/
│               └── SKILL.md    # a skill
└── README.md
```

- A **marketplace** groups one or more plugins.
- A **plugin** contains one or more skills (and optionally commands, agents, hooks).
- A **skill** is a `SKILL.md` with frontmatter (`name`, `description`) and instructions.

## Skills

| Skill | What it does |
|-------|--------------|
| `clarify` | Runs an interrogation session — asks one focused question at a time to turn a vague request into a clear, actionable understanding. |
| `grug` | Channels grugbrain.dev — fights complexity, says no, favors the boring 85% solution. Plain prose, cites grug principles. |
| `grug-review` | Reviews a diff for complexity only, one line per finding (`say-no`, `cut-point`, `demon`, ...). |
| `vertical-slice` | Turns a PRD into a technical plan + task breakdown sliced into vertical, demoable increments — value-first, not layer-by-layer. |

## Installation

Once pushed to GitHub (e.g. `tacsiazuma/skills`):

```
/plugin marketplace add tacsiazuma/skills
/plugin install dev-skills@tacsiazuma-skills
```

Or locally, while developing:

```
/plugin marketplace add /home/tacsiazuma/work/skills
```

## Adding a new skill

1. Create a directory: `plugins/dev-skills/skills/<skill-name>/`
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
