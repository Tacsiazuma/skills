# Automatic version bump and release (GitHub workflow)

## Goal

A GitHub Actions workflow that, after every relevant change lands on `main`, automatically bumps the version of the marketplace and the plugins, and creates a GitHub release for it.

## Problem

The versions (`.claude-plugin/marketplace.json` `metadata.version`, the `version` fields of the `plugin.json` files) are maintained by hand, and they already differ (marketplace `0.2.0`, plugins `0.1.0`). There are no tags and no releases, so users can't see when and what changed.

## Users and journeys

User: the repo owner (and people installing skills from the marketplace).

1. A PR is merged into `main`.
2. The workflow runs, computes the next patch version, writes it into the marketplace and all plugins, commits, tags and creates a release.
3. Installers see the new version in the marketplace, and the changes on the release page.

## In scope

- New workflow: `.github/workflows/release.yml`.
- Trigger: push to `main`, **except** when the change touches only the `docs/` folder (`paths-ignore: docs/**`).
- Version bump: every run is a **patch** bump (X.Y.Z → X.Y.Z+1). The starting point is the marketplace `metadata.version` value (currently `0.2.0`, so the first release is `0.2.1`).
- **One shared version**: the `marketplace.json` `metadata.version` and the `version` field of every `plugins/*/.claude-plugin/plugin.json` are set to the same value (this also aligns the current mismatch).
- The bump commit goes directly to `main`, with `[skip ci]` in the commit message so it doesn't trigger a new run.
- Git tag `vX.Y.Z` and a GitHub release with automatically generated release notes (from the merged PRs).

## Out of scope

- Minor and major version bumps (conventional commits, manual selector): later, if needed.
- Release PR / separate approval step.
- Bumping versions separately per plugin.
- Maintaining a changelog file in the repo.
- Automatically adding new plugins to the `plugins` list of `marketplace.json` (the workflow only writes the versions).

## Success criteria

- After a merge that doesn't touch `docs/`, a new `vX.Y.Z` tag and GitHub release exist within a few minutes.
- `marketplace.json` and every `plugin.json` contain the same version on the new `main`.
- A docs-only push does not create a release.
- The bump commit does not trigger another workflow run (no infinite loop).
- Two consecutive merges get two separate, increasing versions, without conflicts.

## Constraints

- GitHub Actions, using the built-in `GITHUB_TOKEN` (`permissions: contents: write`), with no external secret.
- The `main` branch has no branch protection that would block the bot's push (see assumptions).
- The JSON files are modified with `jq` or similar, in a way that doesn't break the formatting.

## Open questions and assumptions

- Assumption: `main` has no branch protection that would block a push made with `GITHUB_TOKEN`. If it does, the workflow must be adapted to it (e.g. a PAT or a bypass rule).
- Assumption: a `concurrency` group protects the workflow against parallel runs, so the versions don't collide.
- Assumption: the tag format is `vX.Y.Z`, and the release title is the tag name.
- Assumption: the author of the bot commit is `github-actions[bot]`.
