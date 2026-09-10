# agent-seihou

A [Seihou](https://github.com/shinzui/seihou) registry of modules, blueprints, and
agent-session prompts for scaffolding Claude skills and agent recipes.

`seihou-registry.dhall` is the authoritative index of everything published here.

## Modules

Modules are deterministic: a fixed set of variables produces the same generated files
every time. Run them with `seihou run`.

| Module | Version | Description |
|--------|---------|-------------|
| [`claude-gitignore`](modules/claude-gitignore) | `0.2.0` | Ensure `.claude/` and `CLAUDE.local.md` are in `.gitignore` |
| [`agent-gitignore`](modules/agent-gitignore) | `0.1.0` | Ensure `.claude/`, `.agents/`, and `CLAUDE.local.md` are in `.gitignore` |
| [`claude-skill-link`](modules/claude-skill-link) | `0.1.0` | Symlink a Claude skill from `claude/skills/` into `.claude/skills/` |
| [`link-skill`](modules/link-skill) | `0.2.0` | Symlink a skill from `claude/skills/` into both `.claude/skills/` and `.agents/skills/` |
| [`update-docs`](modules/update-docs) | `0.1.0` | Claude skill that keeps project documentation in sync with code changes |
| [`exec-plan`](modules/exec-plan) | `0.10.0` | Claude skill for creating and managing execution plans (ExecPlans) |
| [`exec-plan-digest`](modules/exec-plan-digest) | `0.1.0` | Claude skill that emits a standardized JSON digest of ExecPlans |
| [`master-plan`](modules/master-plan) | `0.10.0` | Claude skill for creating and managing master plans (MasterPlans) |
| [`master-plan-digest`](modules/master-plan-digest) | `0.1.0` | Claude skill that emits a standardized JSON digest of MasterPlans |

Each module directory contains its own `README.md` with full variable, prompt,
dependency, and generated-file reference. `module.dhall` is the authoritative source.

## Blueprints

Blueprints are agent-driven runnables: instead of producing deterministic output from a
fixed set of variables, they capture authoring intent in a prompt and let a coding agent
tailor the result to the target repository. Run them with `seihou agent run`, not
`seihou run`.

| Blueprint | Version | Description |
|-----------|---------|-------------|
| [`hackage-release`](blueprints/hackage-release) | `0.1.0` | Generate a project-specific `release` skill that publishes Haskell packages to Hackage (PVP versioning, changelogs, dependency-ordered publishing, GitHub releases), tailored to the repo's actual package layout and linked into both `.claude/skills` and `.agents/skills` |
| [`docs-sync`](blueprints/docs-sync) | `0.1.0` | Discover local docs, CLI help, embedded agent context, and confirmed sibling kit/docs repositories, then audit stale surfaces against code with a baseline-SHA ledger |
| [`migrate-keiro-stack`](blueprints/migrate-keiro-stack) | `0.2.0` | Migrate a Haskell/PostgreSQL project to the current runtime cohort, adopting shared haskell-nix when active, the fleet vertical structure, and Settei configuration before a guarded disposable or restored-clone persistent database cutover |

Use `docs-sync` for adaptive, multi-surface audits. The deterministic `update-docs` module remains
available for projects that only need a preconfigured single-repository skill scaffold.

## Prompts

Prompts are reusable agent-session templates: they render a task prompt (tunable through
first-class guidance blocks and variables) and launch the configured provider. Run them
with `seihou prompt run`.

| Prompt | Version | Description |
|--------|---------|-------------|
| [`fix-prelude-import-conflicts`](prompts/fix-prelude-import-conflicts) | `0.1.0` | Fix custom-prelude import-conflict violations in a Haskell repo — hide clashing names from the prelude import (never the other import) and never qualify operators |

## Usage

Browse:

```sh
seihou browse https://github.com/shinzui/agent-seihou.git
```

Install:

```sh
# Every module, blueprint, and prompt in the registry
seihou install https://github.com/shinzui/agent-seihou.git --all

# A specific artifact (repeat --module for several)
seihou install https://github.com/shinzui/agent-seihou.git --module update-docs
```

Run a module (with overrides):

```sh
seihou run <module> --var key=value
```

Run a blueprint (launches an agent in the current project):

```sh
seihou agent run hackage-release
seihou agent run docs-sync
seihou agent run migrate-keiro-stack
seihou agent run migrate-keiro-stack --var database.policy=disposable
seihou agent run migrate-keiro-stack --var database.policy=preserve
```

Run a prompt (renders the session prompt and starts the provider):

```sh
seihou prompt run fix-prelude-import-conflicts

# Preview the rendered prompt without contacting a provider
seihou prompt run fix-prelude-import-conflicts --debug
```

See `seihou run --help`, `seihou agent run --help`, `seihou prompt run --help`, and the
target module, blueprint, or prompt README for available variables.

## Documentation

[`okf-docs/`](okf-docs/index.md) is an Open Knowledge Format documentation bundle
(`mori://shinzui/okf`) generated from `seihou-registry.dhall` — one concept document per
published artifact, each naming the `seihou://` resource it was derived from.

| Bundle section | Contents |
|----------------|----------|
| [`okf-docs/registry/`](okf-docs/registry/index.md) | The registry itself, linking every artifact it publishes |
| [`okf-docs/modules/`](okf-docs/modules/index.md) | One concept per module: variables, prompts, dependencies, generation steps, commands |
| [`okf-docs/blueprints/`](okf-docs/blueprints/index.md) | One concept per blueprint |
| [`okf-docs/prompts/`](okf-docs/prompts/index.md) | One concept per agent-session prompt |
| [`okf-docs/profile.dhall`](okf-docs/profile.dhall) | House profile the bundle is validated against |

The bundle is derived, not hand-written: regenerate it after changing the registry or any
artifact, rather than editing it in place. `seihou-okf-extension` ships with Seihou, so
either invocation works:

```sh
seihou-okf-extension docs --force
seihou extension run okf -- docs --dir . --out okf-docs --force
```

Regeneration is byte-stable (no timestamp is recorded unless `--generated-at` is passed),
so a clean `git status` after running it means the bundle is current.

## Repository Layout

```
agent-seihou/
├── seihou-registry.dhall   # module, recipe, blueprint, and prompt index
├── mori.dhall              # Mori project identity (mori://shinzui/agent-seihou)
├── modules/<name>/
│   ├── module.dhall        # module definition
│   ├── README.md           # per-module reference
│   └── files/              # template sources (omitted by command-only modules)
├── blueprints/<name>/
│   ├── blueprint.dhall     # blueprint definition
│   ├── prompt.md           # agent task prompt
│   ├── README.md           # per-blueprint reference
│   └── files/              # read-only reference material
├── prompts/<name>/
│   ├── prompt.dhall        # prompt definition, variables, and guidance blocks
│   ├── prompt.md           # prompt body
│   └── files/              # read-only reference material
├── okf-docs/               # generated OKF documentation bundle
├── docs/                   # ADRs and ExecPlans for this repository
└── tests/                  # Bun tests for scripts shipped inside modules
```

## Development

Run the test suite (covers the helper scripts modules ship in their `files/`):

```sh
bun test
```

Validate an artifact before publishing it, and keep the generated bundle in step:

```sh
seihou validate-module modules/<name>
seihou validate-blueprint blueprints/<name>
seihou validate-prompt prompts/<name>
seihou-okf-extension docs --force
```
