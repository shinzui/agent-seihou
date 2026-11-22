let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/a0fba0d17b43b14bfdf6d0bf98f1b7ff7af4ebab/package.dhall
        sha256:36250d32d50cec0ea8c74926684ffb8b20f6d0b4f2152930dfa04a1ff108ef3f

in  S.Blueprint::{
    , name = "adopt-seihou-catalog"
    , version = Some "0.1.0"
    , description = Some
        "Adopt or refresh Mori's typed Seihou catalog, regenerate OKF documentation, and verify feature links in the local registry"
    , prompt = ./prompt.md as Text
    , allowedTools = Some
      [ "Bash(mori schema migrate *)"
      , "Bash(mori show --json)"
      , "Bash(mori validate)"
      , "Bash(mori register --local)"
      , "Bash(mori registry show *)"
      , "Bash(okf validate *)"
      , "Bash(seihou-okf-extension docs *)"
      , "Bash(mktemp *)"
      , "Bash(diff *)"
      , "Bash(jq *)"
      ]
    , tags = [ "seihou", "mori", "okf", "registry", "migration" ]
    }
