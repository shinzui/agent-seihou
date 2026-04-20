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

Run (with overrides):

```sh
seihou run <module> --var key=value
```

See `seihou run --help` and the target module's README for available variables.

## Repository Layout

```
agent-seihou/
├── seihou-registry.dhall   # module + recipe index
└── modules/<name>/
    ├── module.dhall        # module definition
    ├── README.md           # per-module reference (where present)
    └── files/              # template sources
```
