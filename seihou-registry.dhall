{ repoName = "agent-seihou"
, repoDescription = Some "Seihou modules for Claude skills and agent recipes"
, modules =
  [ { name = "claude-gitignore"
    , path = "modules/claude-gitignore"
    , description = Some "Ensure .claude/ and CLAUDE.local.md are in .gitignore"
    , tags = [ "claude", "gitignore", "infrastructure" ]
    }
  , { name = "claude-skill-link"
    , path = "modules/claude-skill-link"
    , description = Some "Symlink a Claude skill from claude/skills/ into .claude/skills/"
    , tags = [ "claude", "skill", "infrastructure" ]
    }
  , { name = "update-docs"
    , path = "modules/update-docs"
    , description = Some "Claude skill to update project documentation after code changes"
    , tags = [ "claude", "skill", "docs" ]
    }
  , { name = "exec-plan"
    , path = "modules/exec-plan"
    , description = Some "Claude skill for creating and managing execution plans (ExecPlans)"
    , tags = [ "claude", "skill", "planning" ]
    }
  , { name = "master-plan"
    , path = "modules/master-plan"
    , description = Some "Claude skill for creating and managing master plans (MasterPlans) — coordination documents that decompose large initiatives into multiple ExecPlans"
    , tags = [ "claude", "skill", "planning" ]
    }
  ]
}
