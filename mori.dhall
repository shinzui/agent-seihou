let Schema =
      https://raw.githubusercontent.com/shinzui/mori-schema/1ed7527a9132dd3f4f2251c2ab7891fadb7006e8/package.dhall
        sha256:30f64b8cbeb90ab5afa76a523b05da707006bc31e886eec0aeb79e36f8b0afa1

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
    , seihouCatalog = Some Schema.SeihouCatalog::{
      , documentationBundle = Some "seihou-docs"
      , artifacts =
        [ Schema.SeihouArtifact::{
          , kind = Schema.SeihouArtifactKind.Module
          , name = "claude-gitignore"
          , sourcePath = "modules/claude-gitignore"
          , description = Some
              "Ensure .claude/ and CLAUDE.local.md are in .gitignore. Shared base module for Claude-related modules."
          }
        , Schema.SeihouArtifact::{
          , kind = Schema.SeihouArtifactKind.Module
          , name = "claude-skill-link"
          , sourcePath = "modules/claude-skill-link"
          , description = Some
              "Declare a manifest-owned checkout link from claude/skills/ into .claude/skills/ so it's discoverable by Claude Code."
          }
        , Schema.SeihouArtifact::{
          , kind = Schema.SeihouArtifactKind.Module
          , name = "update-docs"
          , sourcePath = "modules/update-docs"
          , description = Some
              "Claude skill that analyzes commits since the last documentation review and keeps project docs in sync."
          }
        , Schema.SeihouArtifact::{
          , kind = Schema.SeihouArtifactKind.Module
          , name = "exec-plan"
          , sourcePath = "modules/exec-plan"
          , description = Some
              "Claude skill for creating and managing execution plans (ExecPlans) — self-contained design documents that guide implementation of features and system changes."
          }
        , Schema.SeihouArtifact::{
          , kind = Schema.SeihouArtifactKind.Module
          , name = "master-plan"
          , sourcePath = "modules/master-plan"
          , description = Some
              "Claude skill for creating and managing master plans (MasterPlans) — coordination documents that decompose large initiatives into multiple ExecPlans."
          }
        , Schema.SeihouArtifact::{
          , kind = Schema.SeihouArtifactKind.Module
          , name = "technical-docs"
          , sourcePath = "modules/technical-docs"
          , description = Some
              "Agent skills for writing tutorials, how-to guides, reference, explanations, and code walkthroughs."
          }
        ]
      }
    , okfBundles =
      [ Schema.OkfBundle::{
        , name = "seihou-docs"
        , path = "okf-docs"
        , okfVersion = "0.2"
        , profile = Some "okf-docs/profile.dhall"
        }
      ]
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
        , version = Some "0.2.0"
        , description = Some
            "Declare a manifest-owned checkout link from claude/skills/ into .claude/skills/ so it's discoverable by Claude Code."
        , modulePath = "modules/claude-skill-link"
        , tags = [ "claude", "skill", "infrastructure" ]
        , dependencies = [ "claude-gitignore" ]
        , requiredVars = [ "skill.name" ]
        }
      , Schema.SeihouTemplate::{
        , name = "link-skill"
        , version = Some "0.4.0"
        , description = Some
            "Symlink a skill from agents/skills/ into .claude/skills/, .codex/skills/ and .agents/skills/. Records manifest-owned checkout links, restored by seihou sync in every clone (Seihou 0.11.0.0 or newer)."
        , modulePath = "modules/link-skill"
        , tags = [ "claude", "agents", "skill", "infrastructure" ]
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
        , version = Some "0.14.0"
        , description = Some
            "Claude skill for creating and managing execution plans (ExecPlans) — self-contained design documents that guide implementation of features and system changes."
        , modulePath = "modules/exec-plan"
        , tags = [ "claude", "skill", "planning" ]
        , dependencies = [ "agent-gitignore", "link-skill" ]
        , requiredVars = [ "skill.name" ]
        }
      , Schema.SeihouTemplate::{
        , name = "master-plan"
        , version = Some "0.14.0"
        , description = Some
            "Claude skill for creating and managing master plans (MasterPlans) — coordination documents that decompose large initiatives into multiple ExecPlans."
        , modulePath = "modules/master-plan"
        , tags = [ "claude", "skill", "planning" ]
        , dependencies = [ "agent-gitignore", "exec-plan", "link-skill" ]
        , requiredVars = [ "mp.skill.name", "exec-plan.skill.name" ]
        }
      , Schema.SeihouTemplate::{
        , name = "technical-docs"
        , version = Some "0.1.0"
        , description = Some
            "Agent skills for writing tutorials, how-to guides, reference, explanations, and code walkthroughs."
        , modulePath = "modules/technical-docs"
        , tags = [ "claude", "agents", "skill", "docs" ]
        , dependencies = [ "agent-gitignore" ]
        }
      ]
    }
