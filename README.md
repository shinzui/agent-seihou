# agent-seihou

A [Seihou](https://github.com/shinzui/seihou) registry of modules for scaffolding Claude
skills and agent recipes.

## Modules

| Module | Version | Description |
|--------|---------|-------------|
| [`claude-gitignore`](modules/claude-gitignore) | `0.2.0` | Ensure `.claude/` and `CLAUDE.local.md` are in `.gitignore` |
| [`claude-skill-link`](modules/claude-skill-link) | `0.1.0` | Symlink a Claude skill from `claude/skills/` into `.claude/skills/` |
| [`update-docs`](modules/update-docs) | `0.1.0` | Claude skill that keeps project documentation in sync with code changes |
| [`exec-plan`](modules/exec-plan) | `0.1.3` | Claude skill for creating and managing execution plans (ExecPlans) |
| [`exec-plan-digest`](modules/exec-plan-digest) | `0.1.0` | Claude skill that emits a standardized JSON digest of ExecPlans |
| [`master-plan`](modules/master-plan) | `0.1.0` | Claude skill for creating and managing master plans (MasterPlans) |
| [`master-plan-digest`](modules/master-plan-digest) | `0.1.0` | Claude skill that emits a standardized JSON digest of MasterPlans |

Each module directory contains its own `README.md` (where present) with full variable,
prompt, dependency, and generated-file reference. `module.dhall` is the authoritative
source.

## Blueprints

Blueprints are agent-driven runnables: instead of producing deterministic output from a
fixed set of variables, they capture authoring intent in a prompt and let a coding agent
tailor the result to the target repository. Run them with `seihou agent run`, not
`seihou run`.

| Blueprint | Version | Description |
|-----------|---------|-------------|
| [`hackage-release`](blueprints/hackage-release) | `0.1.0` | Generate a project-specific `release` skill that publishes Haskell packages to Hackage (PVP versioning, changelogs, dependency-ordered publishing, GitHub releases), tailored to the repo's actual package layout and linked into both `.claude/skills` and `.agents/skills` |
| [`migrate-keiro-stack`](blueprints/migrate-keiro-stack) | `0.1.0` | Migrate a Haskell/PostgreSQL project to a coherent pg-migrate, PGMQ, Kiroku, Keiro, Kioku, and Shibuya cohort through either a confirmed disposable reset or a backup-and-restored-clone persistent cutover |

## Usage

Browse:

```sh
seihou browse https://github.com/shinzui/agent-seihou.git
```

Install:

```sh
# All modules
seihou install https://github.com/shinzui/agent-seihou.git --all

# A specific module
seihou install https://github.com/shinzui/agent-seihou.git --module update-docs
```

Run a module (with overrides):

```sh
seihou run <module> --var key=value
```

Run a blueprint (launches an agent in the current project):

```sh
seihou agent run hackage-release
seihou agent run migrate-keiro-stack
seihou agent run migrate-keiro-stack --var database.policy=disposable
seihou agent run migrate-keiro-stack --var database.policy=preserve
```

See `seihou run --help`, `seihou agent run --help`, and the target module or blueprint README for
available variables.

## Repository Layout

```
agent-seihou/
├── seihou-registry.dhall   # module, recipe, and blueprint index
├── modules/<name>/
│   ├── module.dhall        # module definition
│   ├── README.md           # per-module reference (where present)
│   └── files/              # template sources
└── blueprints/<name>/
    ├── blueprint.dhall     # blueprint definition
    ├── prompt.md           # agent task prompt
    └── files/              # read-only reference material
```
