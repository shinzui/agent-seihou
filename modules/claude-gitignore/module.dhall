let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/2b4035b/package.dhall
        sha256:21716b4aee783d8eb8b12c754050880fa710e881ecda85925f855ef34cc34a55

in  S.Module::{
    , name = "claude-gitignore"
    , version = Some "0.2.0"
    , description = Some
        "Ensure .claude/ and CLAUDE.local.md are in .gitignore. Shared base module for Claude-related modules."
    , steps =
      [ S.Step::{
        , strategy = "template"
        , src = "gitignore.tpl"
        , dest = ".gitignore"
        , patch = Some "append-line-if-absent"
        }
      ]
    , removal = None S.Removal.Type
    }
