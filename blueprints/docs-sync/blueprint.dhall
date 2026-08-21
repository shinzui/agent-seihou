let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/a0fba0d17b43b14bfdf6d0bf98f1b7ff7af4ebab/package.dhall
        sha256:36250d32d50cec0ea8c74926684ffb8b20f6d0b4f2152930dfa04a1ff108ef3f

in  S.Blueprint::{
    , name = "docs-sync"
    , version = Some "0.1.0"
    , description = Some
        "Discover a project's documentation and agent-context surfaces, then audit and repair every stale surface against the code using a baseline-SHA ledger. The workflow adapts to local prose, embedded or runtime-loaded CLI help, embedded agent-assist context, and confirmed sibling kit or public-docs repositories instead of assuming a fixed project layout."
    , prompt = ./prompt.md as Text
    , vars =
      [ S.VarDecl::{
        , name = "sync.scope"
        , type = "text"
        , default = Some "all"
        , description = Some
            "Surfaces to audit. Use 'all' for every stale discovered surface, or a comma-separated list of surface keys from docs/docs-sync.json (for example 'readme,cli-help,agent-context'). Discovery always runs, but baselines advance only for audited surfaces."
        , required = True
        }
      , S.VarDecl::{
        , name = "external.policy"
        , type = "text"
        , default = Some "discover"
        , description = Some
            "Whether to discover and sync confirmed sibling kit/docs repositories ('discover') or restrict all edits to the current repository ('local-only')."
        , required = True
        , validation = Some "(discover|local-only)"
        }
      ]
    , files =
      [ S.Blueprint.BlueprintFile::{
        , src = "capability-discovery.md"
        , description = Some
            "Evidence rules for discovering local documentation, CLI help transport and reachability, embedded agent-assist context, and sibling kit/docs repositories without relying on project-specific names or language conventions."
        }
      , S.Blueprint.BlueprintFile::{
        , src = "ledger-reference.md"
        , description = Some
            "Portable docs/docs-sync.json shape, baseline invariants, staleness rules, and examples for local and cross-repository surfaces."
        }
      ]
    , tags =
      [ "documentation"
      , "docs"
      , "cli"
      , "agents"
      , "skills"
      , "drift"
      , "audit"
      ]
    }
