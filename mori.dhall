let Schema =
      https://raw.githubusercontent.com/shinzui/mori-schema/a3c59033a08c2eaef2cfba4a3c99fc9c192ca6d7/package.dhall
        sha256:18258ef583580a897f4af3e7c86db0342afb42fb40efc535b217ba1089230141

in  Schema.Project::{
    , project = Schema.ProjectIdentity::{
      , name = "agent-seihou"
      , namespace = "shinzui"
      , type = Schema.PackageType.Other "SeihouRegistry"
      , language = Schema.Language.Dhall
      , lifecycle = Schema.Lifecycle.Active
      , description = Some
          "Seihou registry of modules for scaffolding Claude skills and agent recipes"
      }
    , repos =
      [ Schema.Repo::{
        , name = "agent-seihou"
        , github = Some "shinzui/agent-seihou"
        }
      ]
    , templates =
      [ Schema.SeihouTemplate::{
        , name = "claude-gitignore"
        , version = Some "0.2.0"
        , description = Some
            "Ensure .claude/ and CLAUDE.local.md are in .gitignore. Shared base module for Claude-related modules."
        , modulePath = "modules/claude-gitignore"
        , tags = [ "claude", "gitignore", "infrastructure" ]
        }
      , Schema.SeihouTemplate::{
        , name = "claude-skill-link"
        , version = Some "0.1.0"
        , description = Some
            "Symlink a Claude skill from claude/skills/ into .claude/skills/ so it's discoverable by Claude Code."
        , modulePath = "modules/claude-skill-link"
        , tags = [ "claude", "skill", "infrastructure" ]
        , dependencies = [ "claude-gitignore" ]
        , requiredVars = [ "skill.name" ]
        }
      , Schema.SeihouTemplate::{
        , name = "update-docs"
        , version = Some "0.1.0"
        , description = Some
            "Claude skill that analyzes commits since the last documentation review and keeps project docs in sync."
        , modulePath = "modules/update-docs"
        , tags = [ "claude", "skill", "docs" ]
        , dependencies = [ "claude-skill-link" ]
        , requiredVars =
          [ "project.name"
          , "project.description"
          , "skill.name"
          , "changelog.path"
          , "docs.user.dir"
          , "docs.dev.dir"
          , "source.dirs"
          ]
        }
      , Schema.SeihouTemplate::{
        , name = "exec-plan"
        , version = Some "0.1.3"
        , description = Some
            "Claude skill for creating and managing execution plans (ExecPlans) — self-contained design documents that guide implementation of features and system changes."
        , modulePath = "modules/exec-plan"
        , tags = [ "claude", "skill", "planning" ]
        , dependencies = [ "claude-skill-link" ]
        , requiredVars = [ "skill.name" ]
        }
      , Schema.SeihouTemplate::{
        , name = "master-plan"
        , version = Some "0.1.0"
        , description = Some
            "Claude skill for creating and managing master plans (MasterPlans) — coordination documents that decompose large initiatives into multiple ExecPlans."
        , modulePath = "modules/master-plan"
        , tags = [ "claude", "skill", "planning" ]
        , dependencies = [ "exec-plan", "claude-skill-link" ]
        , requiredVars = [ "mp.skill.name", "exec-plan.skill.name" ]
        }
      , Schema.SeihouTemplate::{
        , name = "exec-plan-digest"
        , version = Some "0.1.0"
        , description = Some
            "Claude skill that produces a standardized JSON digest of ExecPlans — extracts status, progress, discoveries, decisions, and outcomes; cross-references git commit trailers; and surfaces issues a human skimming the plan would miss."
        , modulePath = "modules/exec-plan-digest"
        , tags = [ "claude", "skill", "planning", "digest" ]
        , dependencies = [ "exec-plan", "claude-skill-link" ]
        , requiredVars = [ "digest.skill.name", "exec-plan.skill.name" ]
        }
      , Schema.SeihouTemplate::{
        , name = "master-plan-digest"
        , version = Some "0.1.0"
        , description = Some
            "Claude skill that emits a standardized JSON digest of MasterPlans — parses the Exec-Plan Registry, computes the dependency graph, embeds per-child exec-plan-digest output, cross-references git commit trailers, and surfaces coordination issues."
        , modulePath = "modules/master-plan-digest"
        , tags = [ "claude", "skill", "planning", "digest" ]
        , dependencies =
          [ "master-plan", "exec-plan-digest", "claude-skill-link" ]
        , requiredVars =
          [ "mp-digest.skill.name"
          , "master-plan.skill.name"
          , "exec-plan-digest.skill.name"
          ]
        }
      ]
    }
