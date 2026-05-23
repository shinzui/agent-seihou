# Generate a project-specific Hackage release skill

You are generating a **`release` skill** tailored to *this* Haskell
repository — a Claude/agent skill that walks an operator through cutting a
release and publishing to [Hackage](https://hackage.haskell.org/) following
the Haskell **PVP** (`A.B.C.D`).

This is a blueprint, not a static module. Your job is to **inspect the actual
repository**, resolve how *this* project releases, and write a skill whose
concrete details (package names, directories, dependency order, version
strategy, check gates) match reality — not the example you were given.

## What the baseline already did

Before you were launched, seihou applied this blueprint's base module:

- `agent-gitignore` — ensured `.claude/`, `.agents/`, and `CLAUDE.local.md`
  are in `.gitignore`.

The **source of truth** for the skill is `agents/skills/{{skill.name}}/SKILL.md`
(committed), and it gets wired into both harnesses by symlinking it into
`.claude/skills/` and `.agents/skills/`. The baseline does *not* create those
symlinks (baseline applies file steps only, not module commands), so creating
them is your job — see step 3 below. Use the `link-skill` module for it,
exactly like every other skill in this project.

## Reference material

The blueprint's `files/` directory is mounted read-only and listed under
"## Reference Files" in your context. It contains
`release-skill-reference.md`: a complete, working multi-package release skill
from another project. **Use it as a structural template** — the frontmatter
shape, the versioning-strategy section, the ordered step list (determine
changes → compute PVP bump → update versions/bounds/changelogs → verify
builds → commit/tag/push → publish in dependency order → GitHub release), and
the "Important" guardrails are all worth keeping. But every project-specific
fact in it (the `shibuya-*` package names, their directories, their
dependency order, which packages are excluded) is an example — **replace all
of it** with what you discover here.

## How to proceed

### 1. Discover how this repository is built and released

Inspect the repo before writing anything. Determine:

- **Build tooling** — `cabal` vs `stack`; is there a `cabal.project`? Is this
  a Nix project (`flake.nix`, `treefmt`, `pre-commit-hooks`)? What is the
  format command (`nix fmt`, `treefmt`, `fourmolu`/`ormolu`, …) and the check
  gate (`nix flake check`, `cabal build all`, the test suites)?
- **Packages** — find every `*.cabal` file. Record each package's name,
  directory, and current version. Note whether there is a test suite,
  benchmark, or example component.
- **Single- vs multi-package** — is this one package or several? If several,
  do they share one version or version independently? (Check whether their
  cabal versions currently match.)
- **Dependency order** — for multi-package repos, read each cabal's
  `build-depends` to find inter-package dependencies and derive the
  **topological publish order** (dependencies first). Note the internal
  version bounds that must be bumped together (e.g. `pkg-b` depending on
  `pkg-a ^>=A.B.C.D`).
- **Publishable set** — which packages go to Hackage vs which are internal
  (examples, benchmarks, test-only, or split out to another repo). Infer a
  default, but confirm with the user.
- **Changelog conventions** — is there a root `CHANGELOG.md` and/or
  per-package ones? Is there an "Unreleased" section convention? What date
  format is used?
- **Tag conventions** — inspect existing tags (`git tag --list`). What is the
  tag format (`v<version>`? per-package tags?) and is it annotated?
- **GitHub releases** — is `gh` available and are releases published there?
  Look at existing GitHub releases for the format.
- **Commit conventions** — check for Conventional Commits usage and any
  `CLAUDE.md` / contributing docs that pin the release commit message style.

### 2. Resolve the decisions with the user

**Always** confirm the **publishable package set** with the user via
`AskUserQuestion` before writing the skill — never assume it. Present every
package you found, your inferred publish/internal classification *and the
reason* for each (e.g. "internal: test-support library", "internal: example
app", "internal: split out to its own repo"), and the dependency-ordered
publish list you derived, then let the user correct it. Publishing to Hackage
is irreversible, so this split is the one decision that must be explicitly
ratified, even if you are confident.

Also use `AskUserQuestion` for any of these you cannot infer with confidence:

- **Shared vs independent versioning** for multi-package repos.
- **Tag format** and whether to create a **GitHub release**.
- Which **check gates** are mandatory before publishing.

Beyond the publishable set, don't quiz the user on things the repo already
answers.

### 3. Write `agents/skills/{{skill.name}}/SKILL.md`

Create the directory and file. Model it on the reference, but specialized to
this repo. Include:

- **Frontmatter** — `name: {{skill.name}}`, a `description`, an
  `argument-hint: "[major|minor|patch]"`, `disable-model-invocation: true`,
  and an `allowed-tools` line covering what the skill needs (Read, Bash, Edit,
  Glob, Grep, Write, AskUserQuestion).
- **Versioning strategy** — PVP rules (`A.B` major / `C` minor / `D` patch),
  and whether packages share a version.
- **Packages** — the concrete publishable packages **in dependency order**,
  with their directories, plus an explicit list of what is *not* released and
  why.
- **Ordered steps** — adapt the reference's steps to this project's real
  commands: determine changes since last tag; compute the PVP bump (honoring
  a `major|minor|patch` argument when given); update cabal versions, internal
  dependency bounds, and changelogs; run this project's format + build + test
  + check gates; commit (using the project's commit convention), tag, and
  push; publish to Hackage in dependency order (`cabal sdist` +
  `cabal upload --publish`, then haddock docs upload); create the GitHub
  release if applicable.
- **Guardrails** — keep the "Important" section: confirm bump/changelogs
  before committing; always publish in dependency order; never skip the check
  gates; stop on any failure; never continue publishing dependents after an
  upstream upload fails.

For a **single-package** repo, drop the multi-package machinery (dependency
order, internal bounds) and keep the flow lean.

### 4. Wire the skill into both harnesses

Run the project's `link-skill` module to symlink the skill into both agent
harnesses:

```
seihou run link-skill --var skill.name={{skill.name}}
```

This creates `.claude/skills/{{skill.name}}` and `.agents/skills/{{skill.name}}`,
both pointing at `../../agents/skills/{{skill.name}}` (and ensures the
`.gitignore` entries). It is the same mechanism every other skill in this
project uses, so the new skill is discoverable by Claude Code and any harness
that reads `.agents/skills/`. The command is idempotent — safe to re-run.

### 5. Verify and hand off

- Confirm the symlinks resolve to your file:
  `ls -lL .claude/skills/{{skill.name}} .agents/skills/{{skill.name}}`.
- Show the user the generated `SKILL.md` for review and iterate on feedback.
- When they're happy, offer to commit with a Conventional Commits message
  (e.g. `feat(release): add project-specific Hackage release skill`). Ask
  before committing; don't push or run the release itself.
