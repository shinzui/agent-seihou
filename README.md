# agent-seihou

A [Seihou](https://github.com/shinzui/seihou) registry of modules for scaffolding Claude skills and agent recipes.

## Modules

| Module | Description |
|--------|-------------|
| `claude-skill-link` | Symlink a Claude skill from `claude/skills/` into `.claude/skills/` so it's discoverable by Claude Code |
| `update-docs` | Generate a Claude skill that keeps project documentation in sync with code changes |

## Usage

### Browse available modules

```sh
seihou browse https://github.com/shinzui/agent-seihou.git
```

### Install

```sh
# Install all modules
seihou install https://github.com/shinzui/agent-seihou.git --all

# Install a specific module
seihou install https://github.com/shinzui/agent-seihou.git --module update-docs
```

### Run

```sh
seihou run update-docs \
  --var project.name=myapp \
  --var "project.description=My awesome project" \
  --var skill.name=myapp-update-docs \
  --var changelog.path=CHANGELOG.md \
  --var source.dirs=src/
```

This generates:
- `claude/skills/myapp-update-docs/SKILL.md` — the skill definition with all paths customized
- `.claude/skills/myapp-update-docs` — symlink so Claude Code discovers the skill

## Module Details

### claude-skill-link

Infrastructure module that creates a symlink from `.claude/skills/<name>` to `claude/skills/<name>`. This lets you keep skill source files in a tracked `claude/skills/` directory while making them visible to Claude Code via `.claude/skills/`.

**Variables:**

| Variable | Required | Description |
|----------|----------|-------------|
| `skill.name` | yes | Skill directory name (e.g. `myapp-update-docs`) |

### update-docs

Generates a Claude skill that analyzes git commits since the last documentation review and identifies gaps. Depends on `claude-skill-link` to wire up the symlink.

**Variables:**

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `project.name` | yes | | Project name |
| `project.description` | yes | | Short project description |
| `skill.name` | yes | | Skill directory name |
| `changelog.path` | yes | `docs/user/CHANGELOG.md` | Changelog with last reviewed commit |
| `docs.user.dir` | yes | `docs/user` | User documentation directory |
| `docs.dev.dir` | yes | `docs/dev` | Developer documentation directory |
| `source.dirs` | yes | `src/` | Source directories to analyze (comma-separated) |
| `cli.commands.dir` | no | | CLI command modules directory |
| `skills.dir` | no | `claude/skills` | Claude skills directory |

## Repository Layout

```
agent-seihou/
├── seihou-registry.dhall
└── modules/
    ├── claude-skill-link/
    │   └── module.dhall
    └── update-docs/
        ├── module.dhall
        └── files/
            └── SKILL.md.tpl
```
