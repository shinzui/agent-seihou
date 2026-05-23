---
name: seihou-blueprint-readme
description: Generate or refresh a human-readable README.md for a Seihou blueprint, documenting its version, variables, prompts, baseline modules, reference files, allowed tools, tags, and how the agent run produces output — so readers understand the blueprint without reading blueprint.dhall or prompt.md. Use when authoring or updating documentation for a blueprint.
allowed-tools: AskUserQuestion, Read, Write, Edit, Glob, Bash
---

# Seihou Blueprint README

This skill produces a `README.md` next to a blueprint's `blueprint.dhall`, synthesizing
the blueprint's public interface into human-readable documentation. The goal is that a
reader can understand what the blueprint does, what inputs it takes, what scaffolding it
applies before launching the agent, and how to run it, **without** opening
`blueprint.dhall` or `prompt.md`.

A blueprint differs from a module: it is **agent-driven**. Instead of producing
deterministic files from a fixed variable set, it applies optional baseline modules, then
launches a coding agent with a prompt that tailors the output to the target repository.
This skill is the blueprint counterpart to `seihou-module-readme`.

It works by:

1. Locating the blueprint directory (the one containing `blueprint.dhall`).
2. Running `seihou validate-blueprint <path>` for a consistency check.
3. Reading `blueprint.dhall` to extract metadata (name, version, description, vars,
   prompts, baseModules, files, allowedTools, tags).
4. Reading `prompt.md` only to *summarize* what the agent is asked to produce — never to
   reproduce it.
5. Rendering a structured README with fixed section ordering.
6. Writing or updating `README.md` in the blueprint directory.

## When to Use

Activate when the user says things like:

- "Add a README to this blueprint"
- "Document this seihou blueprint"
- "Generate blueprint docs"
- "Write a README for my blueprint"
- "Refresh the blueprint README"
- "/seihou-blueprint-readme"

If the artifact is a **module** (`module.dhall`, with `steps`/`commands`/`removal`), use
`seihou-module-readme` instead.

## Key Concepts

### Blueprint directory

A Seihou blueprint lives in a directory containing:

- `blueprint.dhall` — the blueprint definition
- `prompt.md` — the agent task prompt (imported by `blueprint.dhall` as `./prompt.md as Text`)
- `files/` — read-only reference material the agent may adapt

The README this skill produces lives alongside `blueprint.dhall` (same directory).

### Public interface vs. implementation

The README should describe the blueprint's **public interface** — what affects how a
user runs it and what they get back:

- Identity: `name`, `version`, `description`, `tags`
- Inputs: `vars` (type, default, required, description, validation), `prompts`
- Pre-launch scaffolding: `baseModules` (applied as a baseline before the agent runs)
- Agent context: `files` (reference material mounted read-only), `allowedTools`
- Outcome: a *summary* of what the prompt asks the agent to produce

The full prompt text, Dhall plumbing (`S.Blueprint::{...}`, schema imports), and the
contents of reference files stay out of the README.

### Modules vs. blueprints — what does NOT apply

Blueprints have no `steps`, `commands`, `exports`, `removal`, or `migrations`. Do not
invent those sections. Output is non-deterministic, so there is no "Generated Files"
table — describe the *intended* outcome instead.

### Authoritative sources

- `blueprint.dhall` — the source of truth for everything documented
- `prompt.md` — the agent task; read it to summarize intent, not to copy
- `seihou validate-blueprint <path>` — sanity check that the blueprint loads cleanly

## Workflow Overview

1. **Locate the blueprint** — resolve the target blueprint directory.
2. **Validate** — run `seihou validate-blueprint`.
3. **Read and extract** — parse `blueprint.dhall`; skim `prompt.md` for an intent summary.
4. **Decide on existing README** — preserve hand-written sections if present.
5. **Render README.md** — fill in the template in the fixed order below.
6. **Write the file and summarize** — report what was written and next steps.

## Instructions for Claude

### Phase 1: Locate the Blueprint

If the user named a blueprint or pointed at a path, use that. Otherwise:

```
Question: "Which blueprint should I document?"
Header: "Blueprint"
Options:
- Current directory (contains blueprint.dhall)
- Let me provide a path
- Pick from blueprints listed by `seihou list`
```

Resolve to an absolute path `BP_DIR` such that `BP_DIR/blueprint.dhall` exists. Prefer
the source repo where the blueprint was authored over an installed copy under
`.seihou/` or `~/.config/seihou/installed/`.

Fail fast with a clear message if `BP_DIR/blueprint.dhall` does not exist. If the
directory has a `module.dhall` instead, tell the user to use `seihou-module-readme`.

### Phase 2: Validate

```bash
seihou validate-blueprint <BP_DIR>
```

If validation fails, surface the error and stop — do not document a broken blueprint.

### Phase 3: Read and Extract

Read `blueprint.dhall` and extract the following. Omit any field the blueprint does not
define rather than writing placeholders.

| Field          | Dhall location                              | README section     |
|----------------|---------------------------------------------|--------------------|
| `name`         | top-level `name`                            | Title              |
| `version`      | top-level `version` (`Optional Text`)       | Version line       |
| `description`  | top-level `description` (`Optional Text`)   | Lead paragraph     |
| `tags`         | top-level `tags`                            | Tags / front line  |
| `vars`         | top-level `vars`                            | Variables table    |
| `prompts`      | top-level `prompts`                         | Prompts section    |
| `baseModules`  | top-level `baseModules`                     | Baseline section   |
| `files`        | top-level `files`                           | Reference Files    |
| `allowedTools` | top-level `allowedTools` (`Optional (List Text)`) | Allowed Tools |

Extraction notes:

- Variable defaults are `Optional Text`: render `Some "foo"` as `foo`, `None Text` as an
  em dash (`—`).
- `required = True/False` → yes/no. `validation = Some "<regex>"` → code-fenced regex.
- `baseModules` entries are `Dependency` records: list the `module` name and any `vars`
  bindings (`name = value`).
- `files` entries are `{ src, description }`: list `src` and its description.
- `allowedTools = Some [...]` → list the tools; `None` → omit the section (the runner
  uses its default toolset).

Then read `prompt.md` **once**, to write a 2–5 sentence summary of what the agent is
asked to do and produce (the outcome and the high-level steps). Do not paste the prompt.

### Phase 4: Decide on Existing README

If `BP_DIR/README.md` exists:

```
Question: "A README already exists. How should I update it?"
Header: "README"
Options:
- Regenerate fully (overwrite) (Recommended)
- Preserve hand-written sections between <!-- keep:begin --> and <!-- keep:end --> markers
- Show me a diff first, don't write yet
```

If preserving, re-insert any `<!-- keep:begin name="..." -->` / `<!-- keep:end -->`
block verbatim (under a `## Notes` heading, or at the matching `name=` section).

### Phase 5: Render README.md

Use this **exact** structure. Omit any section whose source field is absent. Keep prose
terse — this is a reference.

```markdown
# <name>

> <description — one or two sentences>

**Version:** `<version>`

**Kind:** Blueprint (agent-driven — run with `seihou agent run`, not `seihou run`)

## Overview

<1–3 sentences: what the blueprint generates, how it tailors output to the target repo,
and who it is for. Derive from description + the prompt.md summary + baseModules.>

## Variables

| Name | Type | Default | Required | Validation | Description |
|------|------|---------|----------|------------|-------------|
| `skill.name` | `text` | `release` | yes | `[a-z][a-z0-9-]*` | ... |

## Prompts

The following values are asked interactively (unless supplied via `--var`):

- **`<var>`** — <prompt text>
  - Shown when: `<when expression>` *(if set)*
  - Choices: `opt1`, `opt2` *(if set)*

## Baseline

Before the agent launches, `seihou agent run` applies these base modules as a starting
scaffold (file steps only — module commands are not run by the baseline):

- **`<module>`** *(with `name = value` bindings, if any)*

Skip with `--no-baseline`.

<If baseModules is empty: "This blueprint declares no base modules.">

## Reference Files

Mounted read-only and listed in the agent's prompt as adaptable source material:

- `files/<src>` — <description>

## Allowed Tools

The agent session is restricted to: `<tool>`, `<tool>`, ...

<Omit this section entirely if allowedTools is None.>

## What the agent produces

<2–5 sentence summary from prompt.md: the outcome and the high-level steps the agent
follows. Describe the result, not the prompt verbatim.>

## Usage

Run in the target repository:

```bash
seihou agent run <name>
```

With variable overrides, or skipping the baseline:

```bash
seihou agent run <name> --var <var>=<value>
seihou agent run <name> --no-baseline
```

Print the resolved agent system prompt without launching the agent (no side effects):

```bash
seihou agent --debug run <name> --no-baseline
```

## Tags

`<tag>`, `<tag>`, ...

<Omit if tags is empty.>

## See Also

- `blueprint.dhall` — full blueprint definition and authoritative source
- `prompt.md` — the agent task prompt
- `files/` — read-only reference material
```

Rendering rules:

- Backtick every variable name, module name, default value, regex, tool name, file path,
  and command.
- Keep tables compact — one row per entry.
- Quote `when` expressions verbatim (e.g. `Eq intentions.enabled true`).
- Do not invent prose beyond what the blueprint declares (plus the prompt.md summary).
  Missing variable descriptions render as an em dash `—`.
- Omit any empty list-valued section (`vars`, `prompts`, `baseModules`, `files`, `tags`)
  entirely — do not print "None".

### Phase 6: Write and Summarize

Write the rendered README to `<BP_DIR>/README.md` (Write tool; Edit if preserving
hand-written sections). Re-run the validator as a sanity check:

```bash
seihou validate-blueprint <BP_DIR>
```

Then report:

```
## README Generated: <blueprint name>

### File
- `<BP_DIR>/README.md` (<created | updated>)

### Blueprint Summary
- **Version**: <version or "unversioned">
- **Variables**: <count> (<required-count> required)
- **Prompts**: <count>
- **Base modules**: <count>
- **Reference files**: <count>
- **Allowed tools**: <count or "default (unrestricted)">

### Next Steps
1. Review the generated README and tighten any prose that reads as generic.
2. If the blueprint gains new variables or base modules, re-run /seihou-blueprint-readme.
3. Commit when satisfied:
   ```bash
   git add <BP_DIR>/README.md
   git commit -m "docs(<blueprint name>): add blueprint README"
   ```
```

## Output Format

Use the summary template above verbatim. Keep it terse — the README is the deliverable.

## Important Notes

- **The README lives next to `blueprint.dhall`**, not inside `files/`. Never place it
  where it would be mounted as reference material.
- **Summarize `prompt.md`, don't reproduce it.** The README should let a reader grasp the
  outcome without reading the full prompt. Reading the prompt once to summarize is
  expected; pasting it is not.
- **Do not read reference file contents** under `files/` when synthesizing the README —
  the description in `blueprint.dhall` is enough.
- **Omit, don't stub.** Sections with no corresponding data are dropped entirely.
- **No module-only sections.** Blueprints have no steps, commands, exports, removal, or
  migrations — never add those sections.
- **Preserve the author's voice where present.** Carry across `<!-- keep:begin -->`
  blocks on regeneration.
- **Never edit `blueprint.dhall` or `prompt.md` from this skill.** Documentation is
  strictly downstream. If metadata is wrong, tell the user to edit the source and re-run.
- **Run `seihou validate-blueprint` before and after.** Documenting a blueprint that
  fails to load would hard-code the wrong interface.
