#!/usr/bin/env bash
# Install skills from this repo into Claude Code, GitHub Copilot, Codex or Cursor
# without the Claude marketplace. Every supported tool reads the same
# <dir>/<skill>/SKILL.md (Agent Skills) format, so no conversion is needed.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<USAGE
Usage: install.sh --tool claude|copilot|codex|cursor [--scope user|project]
                  [--mode copy|symlink] [--project-dir DIR] [--force]
                  [--list] [skill ...]

  --tool         target tool (required)
  --scope        user (home dir, default) or project (inside --project-dir)
  --mode         copy (default) or symlink (stays in sync with this checkout)
  --project-dir  project root for --scope project (default: current dir)
  --force        overwrite existing skills without asking
  --list         list available skills and exit
  skill ...      skills to install (default: all)

Targets (user / project):
  claude   ~/.claude/skills    / .claude/skills
  copilot  ~/.copilot/skills   / .github/skills
  codex    ~/.agents/skills    / .agents/skills
  cursor   ~/.cursor/skills    / .cursor/skills
USAGE
}

tool="" scope="user" mode="copy" pdir="$PWD" force=0 list=0
skills=()
while [ $# -gt 0 ]; do
  case "$1" in
    --tool) tool="${2:-}"; shift 2 ;;
    --scope) scope="${2:-}"; shift 2 ;;
    --mode) mode="${2:-}"; shift 2 ;;
    --project-dir) pdir="${2:-}"; shift 2 ;;
    --force) force=1; shift ;;
    --list) list=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    *) skills+=("$1"); shift ;;
  esac
done

available() { for f in "$REPO"/plugins/*/skills/*/SKILL.md; do basename "$(dirname "$f")"; done; }
find_skill() { for d in "$REPO"/plugins/*/skills/"$1"; do [ -f "$d/SKILL.md" ] && { echo "$d"; return 0; }; done; return 1; }

if [ "$list" = 1 ]; then available; exit 0; fi

case "$tool" in
  claude)  user_dir="$HOME/.claude/skills";  proj_rel=".claude/skills" ;;
  copilot) user_dir="$HOME/.copilot/skills"; proj_rel=".github/skills" ;;
  codex)   user_dir="$HOME/.agents/skills";  proj_rel=".agents/skills" ;;
  cursor)  user_dir="$HOME/.cursor/skills";  proj_rel=".cursor/skills" ;;
  *) echo "--tool must be claude, copilot, codex or cursor" >&2; usage >&2; exit 2 ;;
esac
case "$mode" in copy|symlink) ;; *) echo "--mode must be copy or symlink" >&2; exit 2 ;; esac
case "$scope" in
  user) dest="$user_dir" ;;
  project) dest="$pdir/$proj_rel" ;;
  *) echo "--scope must be user or project" >&2; exit 2 ;;
esac

if [ ${#skills[@]} -eq 0 ]; then
  while IFS= read -r s; do skills+=("$s"); done < <(available)
fi

mkdir -p "$dest"
for s in "${skills[@]}"; do
  src="$(find_skill "$s")" || { echo "Unknown skill: $s (see --list)" >&2; exit 1; }
  target="$dest/$s"
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ "$force" = 0 ]; then
      if [ -t 0 ]; then
        read -r -p "$target exists. Overwrite? [y/N] " ans
        case "$ans" in y|Y) ;; *) echo "skipped $s"; continue ;; esac
      else
        echo "skipped $s ($target exists; use --force to overwrite)"; continue
      fi
    fi
    rm -rf "$target"
  fi
  if [ "$mode" = symlink ]; then ln -s "$src" "$target"; else cp -R "$src" "$target"; fi
  echo "installed $s -> $target ($mode)"
done

if printf '%s\n' "${skills[@]}" | grep -qx sales-funnel-audit; then
  echo "note: sales-funnel-audit needs the Playwright MCP server configured in $tool (see README)."
fi
