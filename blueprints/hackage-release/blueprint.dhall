let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/a0fba0d17b43b14bfdf6d0bf98f1b7ff7af4ebab/package.dhall
        sha256:36250d32d50cec0ea8c74926684ffb8b20f6d0b4f2152930dfa04a1ff108ef3f

in  S.Blueprint::{
    , name = "hackage-release"
    , version = Some "0.1.0"
    , description = Some
        "Generate a project-specific 'release' skill that publishes Haskell packages to Hackage following PVP. An agent inspects the repo (cabal files, package layout, inter-package dependency order, publishable vs internal packages, changelog and git-tag conventions, nix/cabal check gates, GitHub release usage) and writes a tailored skill rather than a static one. The skill is written to agents/skills/<name> and wired into both .claude/skills and .agents/skills via the link-skill module (run by the agent); agent-gitignore is applied as a baseline."
    , prompt = ./prompt.md as Text
    , vars =
      [ S.VarDecl::{
        , name = "skill.name"
        , type = "text"
        , default = Some "release"
        , description = Some
            "Name of the generated skill directory under agents/skills/. Defaults to 'release' (the conventional name). Used to template the agent prompt and to drive the `seihou run link-skill --var skill.name=...` invocation that wires the skill into .claude/skills and .agents/skills."
        , required = True
        , validation = Some "[a-z][a-z0-9-]*"
        }
      ]
    , baseModules = [ S.Dependency::{ module = "agent-gitignore" } ]
    , files =
      [ S.Blueprint.BlueprintFile::{
        , src = "release-skill-reference.md"
        , description = Some
            "Reference example: a complete multi-package Hackage release skill (adapted from the shibuya project). Use it as a structural template — adapt every project-specific detail (package names, directories, dependency order, publishable set) to THIS repository. Do not copy it verbatim."
        }
      ]
    , tags = [ "haskell", "hackage", "release", "skill", "claude", "agents" ]
    }
