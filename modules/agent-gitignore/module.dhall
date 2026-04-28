let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/b83079d377f22c77292ad5ccf88d1061a58f0c1c/package.dhall
        sha256:1d46697ed3e7ca1b0d9922020e2da034ae6e33f7b482ee454c68d94b536e8c2a

in  S.Module::{
    , name = "agent-gitignore"
    , version = Some "0.1.0"
    , description = Some
        "Ensure .claude/, .agents/, and CLAUDE.local.md are in .gitignore. Shared base module for skill modules that publish into both .claude/ and .agents/."
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
