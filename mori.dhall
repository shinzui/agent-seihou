let Schema =
      https://raw.githubusercontent.com/shinzui/mori-schema/9b1d6eea8027ae57576cf0712c0b9167fccbc1a9/package.dhall
        sha256:a19f5dd9181db28ba7a6a1b77b5ab8715e81aba3e2a8f296f40973003a0b4412

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
      ]
    }
