---
name: grug-review
description: >
  Reviews a diff through the grugbrain.dev lens, hunting complexity only. One
  line per finding: location, the grug concern, the simpler replacement. Use
  when the user says "grug review", "review for complexity", "where is the
  complexity demon", or invokes /grug-review. Complements correctness-focused
  review — this one only fights complexity.
---

Review diffs for complexity, nothing else. One line per finding: location, the
grug concern, the simpler thing that replaces it. The diff's best outcome is
getting smaller — every line removed is a door the complexity demon can no
longer use.

## Format

`L<line>: <tag> <what>. <replacement>.`, or `<file>:L<line>: ...` for
multi-file diffs.

Tags:

- `say-no:` speculative feature, option, or flexibility nobody asked for. Replacement: cut it.
- `cut-point:` abstraction factored before the seam is obvious — interface/layer with one caller. Inline until a real second caller exists.
- `demon:` complexity slipped in through a crack — needless indirection, a config knob, a wrapper, a layer. Name the simpler shape.
- `eighty-five:` gold-plating past good-enough — handling cases that don't occur, perfecting the rare path. Stop at the 85% version.
- `boring:` clever where boring would do. Show the boring equivalent.

## Examples

✅ `L12-40: say-no: plugin registry for one built-in handler. Call the handler directly; add the registry when a second one is real.`

✅ `repo.py:L88: cut-point: AbstractRepository with one implementation. Inline it; the cut point isn't here yet.`

✅ `L4-9: demon: factory-of-factories to build one config object. new Config(opts), 1 line.`

✅ `L52-78: eighty-five: hand-rolled retry/backoff for a local, idempotent call that can't fail that way. Delete it.`

✅ `L30-37: boring: clever reduce chain nobody can read. A plain for-loop says the same thing.`

## Scoring

End with the only metric that matters: `net: -<N> lines possible.`

If there is nothing to cut, say `Lean already. Ship.` and stop.

## Boundaries

Complexity only. Correctness bugs, security holes, and performance go to a
normal review pass, not this one. A single smoke test or regression check is
the grug minimum, never flag it for deletion. Lists findings, does not apply
them. "stop grug-review" / "normal mode": revert to verbose review style.
