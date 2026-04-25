{ repoName = "agent-seihou"
, repoDescription = Some "Seihou modules for Claude skills and agent recipes"
, modules =
  [ { name = "claude-gitignore"
    , version = Some "0.2.0"
    , path = "modules/claude-gitignore"
    , description = Some "Ensure .claude/ and CLAUDE.local.md are in .gitignore"
    , tags = [ "claude", "gitignore", "infrastructure" ]
    }
  , { name = "claude-skill-link"
    , version = Some "0.1.0"
    , path = "modules/claude-skill-link"
    , description = Some "Symlink a Claude skill from claude/skills/ into .claude/skills/"
    , tags = [ "claude", "skill", "infrastructure" ]
    }
  , { name = "link-skill"
    , version = Some "0.1.0"
    , path = "modules/link-skill"
    , description = Some "Symlink a skill from claude/skills/ into both .claude/skills/ and .agents/skills/"
    , tags = [ "claude", "agents", "skill", "infrastructure" ]
    }
  , { name = "update-docs"
    , version = Some "0.1.0"
    , path = "modules/update-docs"
    , description = Some "Claude skill to update project documentation after code changes"
    , tags = [ "claude", "skill", "docs" ]
    }
  , { name = "exec-plan"
    , version = Some "0.1.3"
    , path = "modules/exec-plan"
    , description = Some "Claude skill for creating and managing execution plans (ExecPlans)"
    , tags = [ "claude", "skill", "planning" ]
    }
  , { name = "master-plan"
    , version = Some "0.1.0"
    , path = "modules/master-plan"
    , description = Some "Claude skill for creating and managing master plans (MasterPlans) — coordination documents that decompose large initiatives into multiple ExecPlans"
    , tags = [ "claude", "skill", "planning" ]
    }
  , { name = "exec-plan-digest"
    , version = Some "0.1.0"
    , path = "modules/exec-plan-digest"
    , description = Some "Claude skill that emits a standardized JSON digest of ExecPlans — status, progress, discoveries, decisions, commit-trailer coverage, and prioritized findings for things a human skimming would miss"
    , tags = [ "claude", "skill", "planning" ]
    }
  , { name = "master-plan-digest"
    , version = Some "0.1.0"
    , path = "modules/master-plan-digest"
    , description = Some "Claude skill that emits a standardized JSON digest of MasterPlans — registry, dependency graph (ready/blocked/critical path), per-child exec-plan digests, trailer coverage, and coordination findings (registry drift, cascade gaps, integration-point violations)"
    , tags = [ "claude", "skill", "planning" ]
    }
  ]
, recipes =
  [] : List { name : Text, version : Optional Text, path : Text, description : Optional Text, tags : List Text }
}
