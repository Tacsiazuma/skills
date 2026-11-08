# Automatikus verzióemelés és release (GitHub workflow)

## Goal

Egy GitHub Actions workflow, ami minden releváns `main`-re kerülő változás után automatikusan emeli a marketplace és a pluginok verzióját, és létrehoz hozzá egy GitHub release-t.

## Problem

A verziók (`.claude-plugin/marketplace.json` `metadata.version`, a `plugin.json`-ok `version` mezői) kézzel vannak karbantartva, és már most eltérnek (marketplace `0.2.0`, pluginok `0.1.0`). Nincs tag és nincs release, így a felhasználók nem látják, mikor és mi változott.

## Users and journeys

Felhasználó: a repo gazdája (és a marketplace-ről skilleket telepítők).

1. Egy PR merge-elődik a `main`-re.
2. A workflow lefut, kiszámolja a következő patch verziót, beírja a marketplace-be és az összes pluginba, commitol, taggel és release-t készít.
3. A telepítők a marketplace-ben az új verziót látják, a release oldalon pedig a változásokat.

## In scope

- Új workflow: `.github/workflows/release.yml`.
- Trigger: push a `main`-re, **kivéve** ha a változás kizárólag a `docs/` mappát érinti (`paths-ignore: docs/**`).
- Verzióemelés: minden futás **patch** emelés (X.Y.Z → X.Y.Z+1). Kiindulás a marketplace `metadata.version` értéke (jelenleg `0.2.0`, tehát az első release `0.2.1`).
- **Egy közös verzió**: a `marketplace.json` `metadata.version` és az összes `plugins/*/.claude-plugin/plugin.json` `version` mezője ugyanarra az értékre kerül (ez egyúttal összehangolja a jelenlegi eltérést).
- A bump commit közvetlenül a `main`-re megy, a commit üzenetben `[skip ci]`, hogy ne indítson új futást.
- Git tag `vX.Y.Z` és GitHub release automatikusan generált release notes-szal (a merge-elt PR-ekből).

## Out of scope

- Minor és major verzióemelés (conventional commits, kézi választó): később, ha kell.
- Release PR / külön jóváhagyási lépés.
- Verzió emelése pluginonként külön-külön.
- Changelog fájl vezetése a repóban.
- Új plugin automatikus felvétele a `marketplace.json` `plugins` listájába (a workflow csak a verziókat írja).

## Success criteria

- Egy nem `docs/`-ot érintő merge után néhány percen belül van új `vX.Y.Z` tag és GitHub release.
- A `marketplace.json` és minden `plugin.json` ugyanazt a verziót tartalmazza az új `main`-en.
- Docs-only push nem hoz létre release-t.
- A bump commit nem indít újabb workflow futást (nincs végtelen ciklus).
- Két egymás utáni merge két külön, növekvő verziót kap, ütközés nélkül.

## Constraints

- GitHub Actions, a beépített `GITHUB_TOKEN`-nel (`permissions: contents: write`), külső secret nélkül.
- A `main` ágon nincs olyan branch protection, ami a bot push-t tiltaná (lásd feltevések).
- A JSON fájlok módosítása `jq`-val vagy hasonló, a formázást nem borító módon.

## Open questions and assumptions

- Feltevés: a `main`-en nincs branch protection, amely a `GITHUB_TOKEN`-es push-t blokkolná. Ha van, a workflow-t ehhez kell igazítani (pl. PAT vagy bypass szabály).
- Feltevés: párhuzamos futások ellen `concurrency` csoport védi a workflow-t, hogy a verziók ne ütközzenek.
- Feltevés: a tag formátuma `vX.Y.Z`, a release címe a tag neve.
- Feltevés: a bot commit szerzője a `github-actions[bot]`.
