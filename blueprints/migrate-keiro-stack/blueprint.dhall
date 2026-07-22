let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/a0fba0d17b43b14bfdf6d0bf98f1b7ff7af4ebab/package.dhall
        sha256:36250d32d50cec0ea8c74926684ffb8b20f6d0b4f2152930dfa04a1ff108ef3f

in  S.Blueprint::{
    , name = "migrate-keiro-stack"
    , version = Some "0.2.0"
    , description = Some
        "Inspect a Haskell/PostgreSQL project and migrate it to the coherent pg-migrate, PGMQ, Kiroku, Keiro, Kioku, Shibuya, and Settei standards. The workflow aligns active Nix builds through the maintained haskell-nix package set, adapts runtime APIs, adopts the six-package vertical module structure and Settei configuration without behavior drift, then selects a guarded disposable reset or backup-and-restored-clone persistent cutover from evidence while keeping destructive actions operator-approved."
    , prompt = ./prompt.md as Text
    , vars =
      [ S.VarDecl::{
        , name = "database.policy"
        , type = "text"
        , default = Some "ask"
        , description = Some
            "Database safety policy. 'ask' classifies from read-only evidence and asks only when intent remains ambiguous; 'disposable' permits a confirmed local/unshared/non-production reset; 'preserve' requires backup and restored-clone proof before writes."
        , required = True
        , validation = Some "(ask|disposable|preserve)"
        }
      ]
    , files =
      [ S.Blueprint.BlueprintFile::{
        , src = "cohort-and-runtime-reference.md"
        , description = Some
            "Release-cohort baseline, Mori-first dependency discovery, conditional shared haskell-nix integration, migration ownership order, Cabal/Nix alignment, and Kiroku/Keiro/Shibuya/PGMQ/Kioku runtime adaptation checklist."
        }
      , S.Blueprint.BlueprintFile::{
        , src = "pg-migrate-implementation-reference.md"
        , description = Some
            "Application-authoring guide for strict manifests, embedded migration components, the ordered complete plan, standard CLI integration, history import, testing, verification, and forward-only recovery."
        }
      , S.Blueprint.BlueprintFile::{
        , src = "disposable-database-fast-path.md"
        , description = Some
            "Short path for an explicitly confirmed local, unshared, non-production database that may be erased, rebuilt, verified, reapplied with zero work, and smoke-tested."
        }
      , S.Blueprint.BlueprintFile::{
        , src = "persistent-database-cutover.md"
        , description = Some
            "Fail-closed runbook for data-bearing databases: inventory, classification, backup, writer quiescence, restored-clone rehearsal, evidence-backed history import, verification, cutover, soak, and restore rollback."
        }
      , S.Blueprint.BlueprintFile::{
        , src = "vertical-structure-refactor.md"
        , description = Some
            "Behavior-preserving guide for moving an existing service into the six-package Generated/Holes vertical-slice structure, either by Keiro DSL re-scaffolding or concept-by-concept hand moves."
        }
      , S.Blueprint.BlueprintFile::{
        , src = "settei-migration.md"
        , description = Some
            "Behavior-preserving guide for replacing raw configuration wiring with inspectable Settei declarations, explicit file/Secret/environment precedence, redacted diagnostics, and the check-config rollout gate."
        }
      ]
    , tags =
      [ "haskell"
      , "postgresql"
      , "pg-migrate"
      , "keiro"
      , "kiroku"
      , "kioku"
      , "shibuya"
      , "pgmq"
      , "nix"
      , "settei"
      , "vertical-slice"
      ]
    }
