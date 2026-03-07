{ repoName = "agent-seihou"
, repoDescription = Some "Seihou modules for Claude skills and agent recipes"
, modules =
  [ { name = "claude-skill-link"
    , path = "modules/claude-skill-link"
    , description = Some "Symlink a Claude skill from claude/skills/ into .claude/skills/"
    , tags = [ "claude", "skill", "infrastructure" ]
    }
  , { name = "update-docs"
    , path = "modules/update-docs"
    , description = Some "Claude skill to update project documentation after code changes"
    , tags = [ "claude", "skill", "docs" ]
    }
  ]
}
