---
type: SeihouPrompt
title: fix-prelude-import-conflicts
description: Reusable agent-session prompt that fixes custom-prelude import-conflict
  violations in a Haskell repo — hide clashing names from the prelude import (never
  the other import) and never qualify operators. Tunable per project via first-class
  guidance blocks (prelude module, build tool/command, free-form guidance).
resource: seihou://agent-seihou/prompts/fix-prelude-import-conflicts
tags:
- haskell
- refactoring
- prelude
- imports
status: stable
generated:
  by: seihou-okf-extension/0.8.0.0
version: 0.1.0
---

# fix-prelude-import-conflicts

Reusable agent-session prompt that fixes custom-prelude import-conflict violations in a Haskell repo — hide clashing names from the prelude import (never the other import) and never qualify operators. Tunable per project via first-class guidance blocks (prelude module, build tool/command, free-form guidance).

**Version:** 0.1.0

## Agent prompt

# Fix custom-prelude import-conflict violations

```text
# Fix custom-prelude import-conflict violations

Fix custom-prelude import-conflict violations in this Haskell repo.

This project uses a custom prelude module (named `<Project>.Prelude`, imported in
nearly every module). Two rules govern import conflicts:

1. **Conflicts are resolved by hiding the clashing name from the prelude import —
   never from the other import.** The correct form is
   `import <Project>.Prelude hiding ((:=))` while the other module imports the
   name it wants normally.
2. **Operators are never qualified.** No `M.<>`, `Map.!`, `T.<>`, etc. Operators
   must be imported unqualified; conflicts are resolved by hiding (per rule 1),
   not by qualifying.

## Do the following

1. **Find the prelude module name** — look for a module ending in `.Prelude` in
   the core library package (check the `.cabal` files / `mori show --full` if
   available). Call it `P`.
2. **Detect violations** across all `.hs` files:
   - *Qualified operators* — any use of a qualified operator, e.g. `Qual.<>`,
     `Qual.!`, `Qual.:|`. Search for the pattern of an identifier-dot immediately
     followed by an operator symbol.
   - *Wrong-side hiding* — a non-prelude import using `hiding (...)` to dodge a
     clash with `P`, instead of `P` itself carrying the hiding.
   - *Qualified prelude imports used to avoid clashes* — `import qualified P` or
     `import P as <X>` where the intent was to sidestep a name conflict.
3. **Fix each violation:**
   - Replace qualified-operator uses with the unqualified operator, and adjust
     imports so the right operator is in scope. If the unqualified operator would
     clash with a prelude re-export, add the clashing name to a `hiding (...)`
     clause on the `P` import of that module (create the hiding clause if absent,
     or extend it), and import the wanted operator unqualified from its source
     module.
   - Move any misplaced `hiding` clause off the third-party import and onto the
     `import P` line.
   - Preserve qualified imports for ordinary (non-operator) identifiers — those
     are fine; only operators and prelude-conflict handling change.
4. **Verify:** build the project and confirm it still compiles after each batch
   of edits. Report any conflict that can't be resolved by these rules (e.g. two
   non-prelude modules exporting the same operator) instead of guessing.
5. **Summarize** the files changed and the violations fixed, grouped by rule.

Do not reformat unrelated code or touch the prelude module's own contents.
```

## Guidance

### Custom-prelude invariants

These two rules are non-negotiable and override any local habit:

1. Resolve a name clash by hiding the name from the **prelude** import
   (`import P hiding (name)`), never from the other import.
2. Never qualify an operator. Import operators unqualified and resolve
   clashes by hiding (rule 1).

Keep edits scoped to imports and operator call sites. Do not reformat
unrelated code and do not touch the prelude module's own contents.

### Verify with cabal

Verify with `cabal build all` (and focused `cabal build <pkg>` while iterating). Build after each batch of edits and do not consider a batch done until it compiles.

### Project-specific guidance

(Replace this with guidance for the current project. For example:
the prelude module is `Acme.Prelude`; skip the `vendored/` directory;
the `<+>` operator comes from `Data.Semigroup.Foldable`, not the
prelude.)

## Reference files

No reference files declared.

## Tools

No tool restrictions declared.
