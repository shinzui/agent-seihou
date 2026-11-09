---
id: 2
slug: add-a-technical-docs-module-of-documentation-writing-skills
title: "Add a technical-docs module of documentation-writing skills"
kind: exec-plan
created_at: 2026-11-09T15:05:40Z
provenance:
  created_by:
    model: "claude-opus-5-5"
    harness: "claude-code"
    at: 2026-11-09T15:05:40Z
  revisions:
    - model: "claude-opus-5-5"
      harness: "claude-code"
      at: 2026-11-09T15:14:29Z
      mode: "update"
      note: "Added omitted phrasing patterns and a voice-matching rule with a trial check"
    - model: "claude-opus-5-5"
      harness: "claude-code"
      at: 2026-11-09T15:17:59Z
      mode: "implement"
      note: "Implemented the technical-docs module milestones"
---

# Add a technical-docs module of documentation-writing skills

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries,
Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.
If durable project context changes, update or create ADRs in docs/adr/ in the same change.
Record friction met while implementing in the friction-log bundle as it occurs (see FRICTION.md).


## Purpose / Big Picture

Today an agent asked to document a project has no shared standard to follow. It tends to produce one long page that mixes a lesson, a task recipe, a specification, and a design rationale, and it often publishes commands it never ran.

After this change, a project can run `seihou run technical-docs` and receive six agent skills. One is an entry skill, `tech-docs`, that works out what kind of document a reader needs. The other five each write one kind of document well: a tutorial, a how-to guide, a reference page, an explanation, or a code walkthrough. Documents follow the Diátaxis framework by default, may step outside it when a project's needs call for that, and can be augmented with code walkthroughs that lead a reader through real source files.

To see it working, apply the module to a scratch Git project and observe six skill directories under `agents/skills/`, each linked into `.claude/skills/`, `.codex/skills/`, and `.agents/skills/`. Then ask the entry skill for documents in a disposable clone of this repository and observe that each request reaches the right kind of document, that a tutorial's commands all run when followed from a clean start, and that a walkthrough's code excerpts match the source exactly.


## Progress

- [x] Milestone 1 (2026-11-09): `modules/technical-docs` generates six linked skills, with default and custom prefixes, proven by `tests/technical-docs.test.ts`. The test passed 0 of 7 before the module existed and 7 of 7 after; `seihou validate-module --lint` reports no warnings.
- [x] Milestone 2 (2026-11-09): The shared writing rules and the `tech-docs` entry skill are complete and pass the generation test (7 of 7).
- [x] Milestone 3 (2026-11-09): The tutorial, how-to, reference, and explanation skills are complete and pass the generation test (7 of 7).
- [x] Milestone 4 (2026-11-09): The code-walkthrough skill is complete and passes the generation test (7 of 7).
- [ ] Milestone 5: Seven routing trials and two drafting trials in a disposable clone meet the criteria in Validation and Acceptance.
- [ ] Milestone 6: The module is published in the registry, `mori.dhall`, `README.md`, and the regenerated `okf-docs/` bundle, and all publication checks pass.


## Surprises & Discoveries

(None yet.)


## Decision Log

- Decision: Ship one Seihou module that generates six separate skills, rather than one skill with per-type reference files.
  Rationale: The user asked for "the necessary skills". Each kind of document has its own voice and its own failure modes, so a separately named skill can be invoked directly and loads only its own rules. The entry skill covers the common case where the writer does not yet know which kind is needed.
  Date: 2026-11-09

- Decision: Treat Diátaxis as the default, not a requirement. The entry skill must allow documents outside the framework and must not reshape them to fit.
  Rationale: The user said documents usually adhere to Diátaxis "but not always". READMEs, changelogs, release notes, migration guides, runbooks, ADRs, and OKF concepts have their own established forms.
  Date: 2026-11-09

- Decision: Make the code walkthrough a fifth form with its own skill, and require each walkthrough to be linked from the document or task it augments.
  Rationale: The user said walkthroughs "augment" their documents. Diátaxis has no such form. Its nearest neighbour is explanation, but a walkthrough is anchored to specific code at a specific commit and needs its own verification rules.
  Date: 2026-11-09

- Decision: Reserve "How to" titles for how-to guides. Tutorial titles promise an outcome in another form, such as "Build a read-only key-value store in Go".
  Rationale: Lynch's example tutorial titles start with "How to", while Diátaxis uses that phrasing to name how-to guides. Lynch's underlying rule, promising a clear outcome, survives in the other wording, and the two forms stay distinguishable by title.
  Date: 2026-11-09

- Decision: Reference pages may open with the simplest usage example and may have titled sections for common uses, provided those remain illustrations and never become instructions or rationale.
  Rationale: Nicholas recommends starting basic and predicting common uses. Diátaxis requires reference to describe and only describe, and permits brief illustrative examples. This resolution keeps both.
  Date: 2026-11-09

- Decision: Fold Nicholas's Quickstart into the how-to skill as a named variant. Do not add skills for his Examples or Templates sections, and exclude product changes such as auto-inserted API keys, CLI installers, and dashboard embedding.
  Rationale: A quickstart is a task recipe for a newcomer's goal of getting the smallest thing running. Example snippets are covered under reference and how-to. Templates are software projects, not documents, and product changes are not writing rules.
  Date: 2026-11-09

- Decision: Paraphrase the sources in our own words and cite them with URLs in a Sources section. Do not copy passages.
  Rationale: Two of the sources are copyrighted articles. The Diátaxis pages read on 2026-11-09 ask for citation and did not state a licence.
  Date: 2026-11-09

- Decision: Copy one shared `WRITING-RULES.md` source into each skill directory, rather than linking across skill directories.
  Rationale: A skill may be installed or renamed independently, so a relative path into a sibling skill is fragile. One source file in the module cannot drift, and the test asserts that all six copies are identical.
  Date: 2026-11-09

- Decision: Use one variable, `skill.prefix`, and add no documentation-directory variable. Skills discover each project's documentation layout and fall back to `docs/<form>/` only when none exists. Version 0.1.0 ships no helper scripts, and this repository does not apply the module to itself as part of this plan.
  Rationale: A single variable keeps installation free of prompts. Layouts vary between projects and are observable by the agent at writing time. Scripts and self-application can be added later without changing this interface.
  Date: 2026-11-09

- Decision: Skills sample one or two hand-written pages near the target and match the project's voice. Where that voice conflicts with a form's rules, the form's rules win. Generated pages are never sampled.
  Rationale: The sources define each form's voice, but not the voice of the projects these skills will write for. Matching sentence length, formality, and terminology makes new pages fit, while the form's rules are what stop a tutorial from collapsing into a how-to. Generated pages reflect a generator rather than an author.
  Date: 2026-11-09


## Outcomes & Retrospective

(To be filled during and after implementation.)


## Context and Orientation

This repository, `mori://shinzui/agent-seihou`, is a registry for Seihou (`mori://shinzui/seihou`), a tool that generates project files from declarative packages. A Seihou *module* is a directory holding a `module.dhall` definition, written in the Dhall configuration language, and a `files/` directory of source files. `seihou run <module>` executes the module's *steps* in the current project. The `copy` strategy writes a file unchanged. The `template` strategy substitutes `{{variable}}` placeholders first. The `symlink` strategy with `lifecycle = Some "checkout"` records a symbolic link that `seihou sync` can restore in any fresh clone.

A *skill* is a directory containing a `SKILL.md` file whose YAML frontmatter gives a name and a description. Coding agents load a skill when a request matches its description or when the user invokes it by name. In this repository's convention, the real files live in `agents/skills/<name>/`, and three links expose them to each agent harness: `.claude/skills/<name>`, `.codex/skills/<name>`, and `.agents/skills/<name>`.

Read `modules/exec-plan/module.dhall` as the closest existing example. It pins the Seihou schema import, uses both `copy` and `template` steps, declares the three links, and depends on `modules/agent-gitignore`, which adds the agent directories to the consuming project's `.gitignore`. `seihou-registry.dhall` is the authoritative list of published artifacts. `mori.dhall` separately describes this project and its templates to Mori, a project registry. `README.md` carries a table of modules. `okf-docs/` is a documentation bundle in the Open Knowledge Format (OKF), generated from the registry and never edited by hand. Bun tests live in `tests/`, and `tests/checkout-links.test.ts` shows the pattern for driving the real `seihou` binary in isolated temporary projects.

Two existing artifacts are nearby but do a different job. `modules/update-docs` and `blueprints/docs-sync` keep existing documentation in step with code changes. This module authors documents. The new skills do not replace them, and the entry skill should send a request about stale documentation to whichever of them the project has installed.

The following facts were verified on 2026-11-09 against `seihou v0.15.0.0` with a throwaway module in an isolated home directory, and they shape the design. One module can generate several skills and link each one. The same source file can be copied to several destinations. Source files can live in subdirectories of `files/`. A step's destination can compute a name with a Dhall function argument containing `{{skill.prefix}}`. Declaring the variable with a default and `required = False` lets `seihou run` proceed without a prompt and produces no advisory warning from `seihou validate-module --lint`. A second `seihou run` leaves generated skill files untouched and changes only `.seihou/manifest.json`. A literal `{{not.declared}}` inside a `template` source passes `seihou validate-module` but makes `seihou run` fail with `unresolved placeholder`, so template sources must contain no double braces other than `{{skill.prefix}}`. `copy` sources keep double braces literally, which makes `WRITING-RULES.md` safe for any example. The baseline checks on the unmodified repository report `OK: 7 modules, 1 recipe, 3 blueprints, 1 prompt, all versions in sync.` and `OK: 13 concepts (okf_version 0.2)`. Regenerating `okf-docs/` with the current extension changes one line in each of the 13 existing pages, `by: seihou-okf-extension/0.14.0.0` becoming `0.15.0.0`. That drift predates this work and is expected in the final diff.

The ADR corpus in `docs/adr/` contains one record, [ADR 1](../adr/1-keep-safety-critical-blueprints-self-contained.md), about keeping safety-critical blueprints self-contained across Seihou versions. It does not govern this module, which is deterministic and runs no external commands. One of its observations is relevant: Seihou v0.4 enforced only the literal validation pattern `[a-z][a-z0-9-]*`. This plan uses exactly that pattern for `skill.prefix`.

Three external works supply the writing guidance, and their substance is carried in this plan so that no site needs to be reread. They are Daniele Procida's Diátaxis (https://diataxis.fr/), Chris Nicholas's "How to write exceptional documentation" (https://chrisnicholas.dev/blog/how-to-write-exceptional-documentation), and Michael Lynch's "Rules for Writing Software Tutorials" (https://refactoringenglish.com/excerpts/rules-for-software-tutorials/).

Diátaxis divides documentation by the reader's need, using two questions known as the *compass*. Does the content inform action, meaning practical doing, or cognition, meaning thinking? Does it serve acquisition of skill, meaning study, or application of skill, meaning work? Action with acquisition is a tutorial. Action with application is a how-to guide. Cognition with application is reference. Cognition with acquisition is explanation. The difference between a tutorial and a how-to guide is study against work, never basic against advanced. The test between reference and explanation is whether someone would turn to it while executing a task, or after stepping away to think.


## Plan of Work

The new module lives at `modules/technical-docs/`. All skill text is authored under its `files/` directory. Nothing is written to `agents/skills/` in this repository. Work through the milestones in order. After Milestone 1, every change can be checked with the generation test.


### Milestone 1: A module that generates six linked skills

Scope: build the delivery mechanism with placeholder skill text, so that every later milestone is checked by a real generation run. At the end, the module validates without lint warnings and the test suite in `tests/technical-docs.test.ts` passes.

Create `modules/technical-docs/module.dhall` with exactly the structure shown in Interfaces and Dependencies. Create these source files, each initially holding valid frontmatter and a one-line body: `files/router/SKILL.md`, `files/tutorial/SKILL.md`, `files/how-to/SKILL.md`, `files/reference/SKILL.md`, `files/explanation/SKILL.md`, and `files/walkthrough/SKILL.md`. Also create `files/shared/WRITING-RULES.md`.

Create `tests/technical-docs.test.ts`, following the isolation pattern in `tests/checkout-links.test.ts`: a temporary area removed in `afterAll`, `HOME`, `XDG_CONFIG_HOME`, and `XDG_CACHE_HOME` pointed inside it, and a fresh `git init` project. Copy `modules/agent-gitignore` and `modules/technical-docs` into the project's `.seihou/modules/`. Run the binary named by `SEIHOU_TEST_BIN` with empty stdin and throw if that variable is unset or is not an absolute path to an existing file, so that acceptance cannot be skipped silently.

The test file must assert the following behaviour. With no variable overrides, `seihou run technical-docs --no-save-prompted` creates the six directories `tech-docs`, `tech-docs-tutorial`, `tech-docs-how-to`, `tech-docs-reference`, `tech-docs-explanation`, and `tech-docs-walkthrough` under `agents/skills/`. Each `SKILL.md` has a frontmatter `name` equal to its directory name. Each directory has a `WRITING-RULES.md`, and all six are byte-identical. Each of the 18 discovery links is a symbolic link whose target is `../../agents/skills/<name>` and through which `SKILL.md` can be read. A second run leaves every byte under `agents/skills/` unchanged. Every relative Markdown link in a generated `SKILL.md` resolves to a file inside that same skill directory. The entry skill's body names all five form skills. In a separate project, `--var skill.prefix=acme-docs` creates the six correspondingly named directories, and neither the string `tech-docs` nor `{{` appears in any generated `SKILL.md`.


### Milestone 2: The shared writing rules and the entry skill

Scope: write the two pieces that every document depends on. At the end, `files/shared/WRITING-RULES.md` and `files/router/SKILL.md` carry the content below, and the generation test still passes.

`WRITING-RULES.md` is a `copy` source, so it cannot name the generated skills. It applies to every document, including those outside Diátaxis. It covers the following in this order, in plain imperative prose.

The first group concerns truth. Never document from memory. Read the source and run the thing. Run every command you publish. Confirm every path, symbol, flag, and output against the working tree. In your final report, state what you ran and what you could not check, and in the document itself mark anything the reader cannot rely on. State limitations plainly and leave out marketing language.

The second group concerns the reader. Name the intended reader before writing. One page serves one need, and adjacent material gets a link instead of being absorbed. Define or link every term the intended reader may not know, and do not explain a simple idea with harder words. Do not assume a reader arrived from the previous page.

The third group concerns code samples, from Lynch. Commands must paste and run unchanged. Omit a leading `$` from commands meant for copying, and show a prompt only where it is needed to separate typed input from displayed output. Use non-interactive flags such as `--yes` so pasted lines are not consumed as answers. Chain dependent commands with `&&` and line continuations so a sequence stops at the first failure. Exclude line numbers from copyable text. Prefer long flag names such as `--recursive`. Separate what the reader must change from what must stay: at the top of a shell sample, assign editable values to commented variables and reference them as `${VAR?}` so an unset value fails loudly, and in source code use commented named constants for fixed values. Choose realistic example values that cannot be mistaken for keywords or library names, so use a `pets` table with a `pet_name` column and never `tbl` with a column called `column`. Replace tedious manual edits with a command. Give the full path of every file the reader touches and show exactly where a change goes. Pin versions, and say which version you tested.

The fourth group concerns structure. Write descriptive headings that make sense out of context, so use "Install Go 1.23" and not "Installation". Keep casing, point of view, and tense consistent across headings, and nest only what belongs to its parent. Write for readers who skim: use heading levels to show hierarchy, and add short comments to code samples where the purpose of a line is not obvious. Link generously to every mentioned feature. Follow the project's existing frontmatter, navigation, file naming, and cross-reference conventions, and where the project uses canonical cross-repository URIs such as Mori's `mori://` form, use those rather than paths.

The fifth group concerns voice. Before drafting, read one or two hand-written pages near the target, preferring pages of the same form, and match their sentence length, formality, terminology, and spelling. Do not sample generated pages. Where the project's voice conflicts with the rules of the form being written, the form's rules win, so a tutorial says "we" even when the surrounding pages do not. For a document outside Diátaxis, the project's voice governs. If no hand-written pages exist, use the form's default voice.

Close the rules with a Sources section citing the three works above by title, author, and URL, with the date 2026-11-09.

`files/router/SKILL.md` is the skill named `{{skill.prefix}}`. Its workflow has six parts.

First, identify who will read the document and what they are trying to do at the moment they open it. Second, determine the existing documentation layout, conventions, and any generated reference. If the target directory is an OKF bundle, keep its required frontmatter and use the `author-okf-concept` skill (`mori://shinzui/okf-kit/skills/author-okf-concept`) when it is installed. If the request is about stale documentation rather than authoring, send it to the project's `update-docs` skill or `docs-sync` workflow when one is installed.

Third, classify with the compass, asking its two questions and applying them to the whole request and, when doubt remains, to individual paragraphs. Include the two distinctions from Context and Orientation: tutorial against how-to is study against work and never basic against advanced, and reference against explanation is consulted mid-task against read after stepping away. Map the four outcomes to `{{skill.prefix}}-tutorial`, `{{skill.prefix}}-how-to`, `{{skill.prefix}}-reference`, and `{{skill.prefix}}-explanation`, and hand off to that skill.

Fourth, decide whether the request sits outside the framework. A README, changelog, release notes, migration guide, runbook, ADR, design document, or OKF concept follows the project's convention for that form plus `WRITING-RULES.md`. Do not force such a document into one of the four types. The compass may still be used section by section, for example to keep a README's installation steps short and link out for the rest.

Fifth, decide whether a code walkthrough should augment the document, using `{{skill.prefix}}-walkthrough`. Offer one when the reader must understand or change real code, or when the document's central claim rests on a specific code path. Do not add one by default.

Sixth, handle compound work. A request spanning several needs becomes several linked pages written one at a time. A request to "document this project" gets a proposed list of pages, drawn from these reader questions: How do I set it up? How do I use it effectively? How do I solve a specific problem? How does it work? What can I look up? Not every project needs every section, the user confirms the list before writing, and no empty structure is created in advance. To improve an existing page, follow the Diátaxis loop: pick one piece no larger than a page, assess which need it serves and how well, choose the single next improvement, complete it, and repeat.


### Milestone 3: The four Diátaxis form skills

Scope: write the four skills whose forms Diátaxis defines. At the end, each carries the content below and the generation test passes.

Every form skill, including the walkthrough in Milestone 4, shares this outer workflow. Read [WRITING-RULES.md](WRITING-RULES.md). Confirm the form with one sentence stating the reader's need, and hand back to `{{skill.prefix}}` if it does not fit. Discover the project's conventions, sample nearby pages for voice as `WRITING-RULES.md` directs, and choose the location, falling back to `docs/tutorials/`, `docs/how-to/`, `docs/reference/`, `docs/explanation/`, or `docs/walkthroughs/` respectively, creating only the directory the page needs. Ground the content in source and execution. Draft by the form's rules. Verify. Review against the form's listed failures. Link the page from related pages. Report what was verified, what was not, and which pages were sampled for voice, or that there were none.

`files/tutorial/SKILL.md` writes a lesson that gives a newcomer competence through doing. Use "we" and open with "In this tutorial, we will…", never "you will learn". Answer in the first sentences whether the reader should care and whether this page is right for them. Show the finished result early. The title promises the concrete outcome and does not begin with "How to". Teach one thing. If other technologies are unavoidable, use the simplest option and leave production alternatives to the end. Plan the sequence of topics before writing and let difficulty rise gradually toward something tangible the reader built and can extend. Every step leaves the code in a working state, using stubs instead of unfinished code. Deliver visible results early and often, state the exact expected output after steps, and flag likely failures. Sequence steps with "First, do x. Now, do y.", introduce expected output with "The output should look something like…", and prompt checks with "Let's check…". Direct attention with "Notice that…". Give brief, mild praise when the learner reaches a meaningful result. Show behaviour with real output, a screenshot, or a small demo rather than describing it, and add a short quiz or interactive element only when the documentation platform supports one. Offer no choices or alternatives. A best-practice remark stays to one sentence with a link, and explanation stays minimal with a link out. Keep demo interfaces free of styling. Minimise dependencies, roughly not adding one that saves fewer than 20 lines. End by proving it works and link the complete code when the project can host it, never inventing a link. Verification means following the page from a clean starting state exactly as written. Listed failures: teaching by explaining, presenting options, steps that do not reliably produce the promised result, drifting into a how-to.

`files/how-to/SKILL.md` writes directions for a competent user pursuing a goal. The title takes the form "How to <achieve goal>". Avoid gerunds and bare noun titles. Open with "This guide shows you how to…", state the end result, and list prerequisites and the starting point. Write around a goal or problem and never around a tool's operations. Use actions only, linking to reference and explanation with phrasing such as "Refer to the x reference guide for a full list of options." Handle real-world variation with conditionals such as "If you want x, do y", and let the path fork where it must. Begin and end at sensible points, preferring usability over completeness. Show how to confirm success. Mark workarounds with a visible disclaimer. Link a working example repository when one exists, and suggest repeated support questions as good sources of topics. A named variant, the quickstart, gets a newcomer running the smallest working thing: a couple of short paragraphs per step at most, each step nearly a command, no explanations, one page per technology rather than one page that mostly works for several. Quickstarts are retested end to end after every change. Listed failures: teaching mid-guide, reference-style completeness, steps that merely describe a tool's controls, vague titles, forcing a linear path on a branching task.

`files/reference/SKILL.md` writes dry, complete technical description to be consulted during work. First check whether the project generates this reference. If it does, do not hand-write a competing copy; improve the generator's input or link to the output. Mirror the product's own structure and use one consistent pattern on every entry. Lead each entry with the simplest working usage, then add titled sections for likely uses as illustrations only. Tabulate arguments, properties, and return values with type, requiredness, default, and meaning, and move complex arguments to linked subsections. Cover errors, limits, and unhappy paths. Recommend one default approach by placing it first and mention alternatives only in passing. Warnings of the form "You must not apply b unless c" are permitted. Link every mentioned item, and use the familiar OpenAPI-style layout for REST APIs. Verification means checking every signature, default, and limit against code and exercising examples. Listed failures: instruction or rationale creeping in, opinion or marketing, inconsistent entries, undocumented error behaviour.

`files/explanation/SKILL.md` writes a discussion that deepens understanding, for reading away from the work. Bound the page by a stated "why" question or a drawn perimeter, and title it with an implicit "About", such as "About connection policies". Cover context, history, design decisions, constraints, trade-offs, and alternatives, and make connections to neighbouring ideas. Opinions are allowed when reasons are given and counter-arguments acknowledged, using forms such as "W is better than z, because…" and "Some users prefer w. This can be a good approach, but…". Give history and analogy in forms such as "The reason for x is because historically, y…" and "An x in system y is analogous to a w in system z. However…". Use diagrams where they explain better than text and keep code snippets basic. Be matter-of-fact about limitations. Where the page's claims rest on code, verify them in the source. Listed failures: no boundary, steps or specifications creeping in, explanation scattered across other pages and left unrecognised, advertising.


### Milestone 4: The code-walkthrough skill

Scope: write the one form that has no external definition, so this plan's specification is authoritative. At the end, `files/walkthrough/SKILL.md` carries the content below and the generation test passes.

A *code walkthrough* is a guided reading of real source code along one thread, written for someone who needs a working mental model in order to read or change that code. It differs from a tutorial because the reader builds nothing, from a how-to because no task is performed, from reference because it is selective and ordered for comprehension, and from explanation because each point is anchored to specific code at a specific revision.

The skill must require all of the following. A walkthrough augments something, so name its parent document or task, link to the parent, and add a link from the parent back to it. Do not repeat the parent's steps or specifications. Answer one question, such as "What happens when a plan is created?", and state what is out of scope. Near the top, state the intended reader, what they should already know, and the commit identifier or release the walkthrough was written against. Begin with a short map of the files or stages involved, using a diagram when it helps. Order the stops by execution or data flow, or by what makes the next stop understandable, and never by file order.

Each stop has a location given as a repository-relative path and a symbol name, the smallest excerpt that makes the point, what it does and why it matters, and a transition to the next stop. Excerpts are verbatim, and any omission uses an explicit marker such as `// ...`. Never tidy or rename code in an excerpt. Prefer path and symbol anchors because they survive edits. Use line numbers only together with a pinned revision, and use a commit-pinned permalink when the project is hosted somewhere that supports one. Across repositories, use the project's canonical URI convention. Explain what is not obvious from reading: invariants, error paths, ordering constraints, surprising decisions, and where a common change would be made. Do not narrate syntax. End by restating the mental model and pointing to related pages.

Verification means confirming every anchor against the stated revision, comparing every excerpt character by character with the source, and tracing or running the path so behavioural claims are observed rather than inferred. Listed failures: touring files with no thread, paraphrased code, excerpts too long to read, drifting into instructions, a walkthrough that nothing links to.


### Milestone 5: Trials in a disposable clone

Scope: prove that agents following the generated skills produce the promised results, and repair skill wording where they do not. No trial output is committed. At the end, the criteria in Validation and Acceptance are met, and any skill change those trials forced is recorded under Surprises & Discoveries.

Apply the module in a disposable clone as shown in Concrete Steps. Start a new agent session for each prompt, with the clone as its working directory, so that only the generated skills guide it. When a trial fails, change the source under `modules/technical-docs/files/`, regenerate in the clone, and rerun only the affected trial.


### Milestone 6: Publication

Scope: make the finished module discoverable. At the end, the registry, project manifest, repository README, module README, and generated documentation agree.

Add the registry entry and the `mori.dhall` template entry shown in Interfaces and Dependencies. In `README.md`, add a row for `technical-docs` at version `0.1.0` to the Modules table with the description "Agent skills for writing tutorials, how-to guides, reference, explanations, and code walkthroughs". Then, following the short README convention of `mori://shinzui/seihou-kit/skills/seihou-module-readme`, write `modules/technical-docs/README.md`. It states what the module does, lists the six generated skills by default name, shows one install command and one run command, and links to `../../okf-docs/modules/technical-docs.md` for variables and steps instead of restating them. Regenerate `okf-docs/`.


## Concrete Steps

Run every command from the repository root, `/Users/shinzui/Keikaku/bokuno/agent-seihou`, unless a step changes directory. The first run in an isolated home downloads the pinned Seihou schema, so network access is required.

Validate the module after any change to `module.dhall`:

```bash
seihou validate-module modules/technical-docs --lint
```

```text
Module 'technical-docs' is valid.
```

Run the generation test. Only `SEIHOU_TEST_BIN` is needed for this file. The complete suite also needs a legacy `SEIHOU_LEGACY_TEST_BIN`, which `tests/checkout-links.test.ts` requires and which this plan does not change.

```bash
SEIHOU_TEST_BIN="$(command -v seihou)" bun test tests/technical-docs.test.ts
```

Prepare a disposable clone for Milestone 5. Run these commands from the repository root:

```bash
source_repo="$PWD" && \
trial_repo="$(mktemp -d)/agent-seihou-trial" && \
git clone --quiet "$source_repo" "$trial_repo" && \
mkdir -p "$trial_repo/.seihou/modules" && \
cp -R "$source_repo/modules/agent-gitignore" "$source_repo/modules/technical-docs" "$trial_repo/.seihou/modules/" && \
cd "$trial_repo" && \
printf '.seihou/modules/\n' >> .gitignore && \
seihou run technical-docs --no-save-prompted </dev/null && \
ls -1 agents/skills && \
echo "$trial_repo"
```

Publication checks for Milestone 6:

```bash
seihou registry validate
seihou-okf-extension docs --force
okf validate okf-docs --strict --profile okf-docs/profile.dhall --profile-enforce
dhall type --quiet --file mori.dhall
git status --short
```

```text
OK: 8 modules, 1 recipe, 3 blueprints, 1 prompt, all versions in sync.
Wrote 14 concepts to okf-docs
OK: 14 concepts (okf_version 0.2)
```

Make commits at milestone boundaries, directly on the current branch, using Conventional Commits and the plan trailer:

```text
feat(technical-docs): generate linked documentation skills

Add the module definition, placeholder skills, and generation test.

ExecPlan: docs/plans/2-add-a-technical-docs-module-of-documentation-writing-skills.md
```


## Validation and Acceptance

Required acceptance is all of the following.

`seihou validate-module modules/technical-docs --lint` reports the module valid with no `⚠` lines. `SEIHOU_TEST_BIN="$(command -v seihou)" bun test tests/technical-docs.test.ts` passes every assertion listed in Milestone 1. Before the module exists the test fails, and after Milestone 1 it passes, which demonstrates that it observes real generation.

In the disposable clone, seven fresh sessions each receive one request below, prefixed with `/tech-docs` and suffixed with "Tell me which form and skill you would use and why. Do not write any files."

Asked "Teach a newcomer to publish their first Seihou module from this repository", the session selects the tutorial. Asked "How do I bump a module's version and regenerate okf-docs?", it selects the how-to guide. Asked "Document every variable, step, and dependency of link-skill", it selects reference and points out that `okf-docs/modules/link-skill.md` already provides this and is generated. Asked "Why are skill discovery links declared as checkout outputs instead of created by shell commands?", it selects explanation. Asked "Walk a new maintainer through what init-plan.ts does when it creates a plan", it selects the walkthrough and identifies a parent document or asks for one. Asked "Write release notes for exec-plan 0.14.0", it treats the request as outside Diátaxis and does not choose one of the four types. Asked "Explain how ExecPlan provenance works and show me where it is implemented", it proposes an explanation augmented by a linked walkthrough, as two pages.

Two drafting trials then run with permission to write files in the clone. First, using the first request, an agent writes the tutorial, and a separate fresh session follows it verbatim from a new empty working directory. Every command must run and every stated output must match. Second, using the last request, an agent writes both pages. The reviewer confirms that each page links to the other, that the walkthrough states a commit identifier, and that each excerpt appears byte-for-byte in that revision of the named file, and each listed failure for the walkthrough is checked and absent. In both trials, the agent's report names the hand-written pages it sampled for voice or says there were none, no sampled page lies under the generated `okf-docs/` bundle, and the tutorial uses "we" throughout regardless of the voice of the sampled pages.

`seihou registry validate` reports 8 modules in sync, `okf validate` reports 14 concepts, and `dhall type --quiet --file mori.dhall` exits with status 0. Apart from the generator-version line described in Context and Orientation, the `okf-docs/` diff contains only additions for `technical-docs` and index or registry entries that mention it.

Running the complete `bun test` suite is desirable but is not required acceptance unless a legacy 0.9.0.0 binary is available. Nothing in this plan changes the code those tests exercise.


## Idempotence and Recovery

`seihou validate-module`, the Bun test, the checks in Milestone 6, and `seihou-okf-extension docs --force` are safe to repeat. The test creates and removes its own temporary area and never touches the user's Seihou configuration. Disposable clones live under a `mktemp` directory and can be deleted freely. Never run the trial's `seihou run` in the main checkout, because it would apply the module and write to `.seihou/manifest.json` here. If that happens by accident, run `git status --short` to see what changed, and restore only those files with `git restore` after checking that they contain no other work.

If `seihou run` fails with `unresolved placeholder`, a `template` source contains double braces other than `{{skill.prefix}}`. Rephrase it, or move the example into the `copy` source `WRITING-RULES.md`.


## Interfaces and Dependencies

The module's public interface is one optional variable, `skill.prefix`, with default `tech-docs`, and the six generated skill names derived from it. Changing a generated name later is a breaking change for anyone invoking the skills by name.

Create `modules/technical-docs/module.dhall` as follows. The schema import is the same pinned revision used by `modules/exec-plan/module.dhall`.

```dhall
let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/367b0a1390ac1ed3dda6e2cacfdf3e72b1f624df/package.dhall
        sha256:ef20d62c240dfe0e1126e05534d58c467188af4198307ad3c2a4a713bcd93505

let skill =
      \(name : Text) ->
      \(source : Text) ->
        [ S.Step::{
          , strategy = "template"
          , src = "${source}/SKILL.md"
          , dest = "agents/skills/${name}/SKILL.md"
          }
        , S.Step::{
          , strategy = "copy"
          , src = "shared/WRITING-RULES.md"
          , dest = "agents/skills/${name}/WRITING-RULES.md"
          }
        , S.Step::{
          , strategy = "symlink"
          , lifecycle = Some "checkout"
          , src = "agents/skills/${name}"
          , dest = ".claude/skills/${name}"
          }
        , S.Step::{
          , strategy = "symlink"
          , lifecycle = Some "checkout"
          , src = "agents/skills/${name}"
          , dest = ".codex/skills/${name}"
          }
        , S.Step::{
          , strategy = "symlink"
          , lifecycle = Some "checkout"
          , src = "agents/skills/${name}"
          , dest = ".agents/skills/${name}"
          }
        ]

in  S.Module::{
    , name = "technical-docs"
    , version = Some "0.1.0"
    , description = Some
        "Agent skills for writing technical documentation: an entry skill that classifies the reader's need, and skills for tutorials, how-to guides, reference, explanations, and code walkthroughs."
    , vars =
      [ S.VarDecl::{
        , name = "skill.prefix"
        , type = "text"
        , default = Some "tech-docs"
        , description = Some
            "Name of the entry skill and prefix of the five form skills"
        , required = False
        , validation = Some "[a-z][a-z0-9-]*"
        }
      ]
    , exports = [ { var = "skill.prefix", alias = None Text } ]
    , steps =
          skill "{{skill.prefix}}" "router"
        # skill "{{skill.prefix}}-tutorial" "tutorial"
        # skill "{{skill.prefix}}-how-to" "how-to"
        # skill "{{skill.prefix}}-reference" "reference"
        # skill "{{skill.prefix}}-explanation" "explanation"
        # skill "{{skill.prefix}}-walkthrough" "walkthrough"
    , dependencies = [ S.Dependency::{ module = "agent-gitignore" } ]
    }
```

Each `SKILL.md` begins with YAML frontmatter holding `name`, `description`, `argument-hint`, and `user-invocable: true`, as in `modules/exec-plan/files/SKILL.md`. Use these exact names and descriptions, so that requests reach the intended skill:

```yaml
- name: "{{skill.prefix}}"
  description: "Decide what kind of technical documentation a reader needs and write or plan it. Use when asked to document something and the form is not yet clear, to plan a set of docs, or to improve an existing page."
- name: "{{skill.prefix}}-tutorial"
  description: "Write a learning-oriented tutorial that teaches a newcomer by having them build something. Use when asked for a tutorial or lesson."
- name: "{{skill.prefix}}-how-to"
  description: "Write a goal-oriented how-to guide or quickstart for someone trying to get a specific task done. Use when asked for a how-to, guide for a task, recipe, or quickstart."
- name: "{{skill.prefix}}-reference"
  description: "Write dry, complete technical reference for an API, CLI, configuration, or schema. Use when asked to document all options, parameters, commands, or fields."
- name: "{{skill.prefix}}-explanation"
  description: "Write a discussion explaining why something works the way it does, covering design decisions, context, and trade-offs. Use when asked to explain concepts or architecture in prose."
- name: "{{skill.prefix}}-walkthrough"
  description: "Write a code walkthrough that guides a reader through real source files along one thread, anchored to a specific revision and linked from the document it augments. Use when asked to walk through, tour, or trace code."
```

Add this entry at the end of `modules` in `seihou-registry.dhall`:

```dhall
{ name = "technical-docs"
, version = Some "0.1.0"
, path = "modules/technical-docs"
, description = Some "Agent skills for writing tutorials, how-to guides, reference, explanations, and code walkthroughs"
, tags = [ "claude", "agents", "skill", "docs" ]
}
```

Add this entry at the end of `templates` in `mori.dhall`:

```dhall
Schema.SeihouTemplate::{
, name = "technical-docs"
, version = Some "0.1.0"
, description = Some
    "Agent skills for writing tutorials, how-to guides, reference, explanations, and code walkthroughs."
, modulePath = "modules/technical-docs"
, tags = [ "claude", "agents", "skill", "docs" ]
, dependencies = [ "agent-gitignore" ]
}
```

The module depends on `modules/agent-gitignore` and requires a Seihou runtime that supports checkout-lifecycle symlink steps, version 0.11.0.0 or newer. Development additionally uses `bun`, `seihou-okf-extension`, `okf` (`mori://shinzui/okf`), and `dhall`, all of which were present on the planning machine.


## Revision Notes

- 2026-11-09: Added the phrasing patterns the first draft omitted for tutorials, how-to guides, and explanations, added skim-reading and show-don't-tell guidance, and added a voice-matching rule with form-rules precedence and a trial check. The first draft encoded the sources' style but not the voice of the projects the skills write for.
