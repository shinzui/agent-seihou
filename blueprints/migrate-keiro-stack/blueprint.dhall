let S =
      https://raw.githubusercontent.com/shinzui/seihou-schema/a0fba0d17b43b14bfdf6d0bf98f1b7ff7af4ebab/package.dhall
        sha256:36250d32d50cec0ea8c74926684ffb8b20f6d0b4f2152930dfa04a1ff108ef3f

in  S.Blueprint::{
    , name = "migrate-keiro-stack"
    , version = Some "0.1.0"
    , description = Some
        "Inspect a Haskell/PostgreSQL project and migrate it to a coherent pg-migrate, PGMQ, Kiroku, Keiro, Kioku, and Shibuya cohort. The agent selects a guarded disposable reset or a backup-and-restored-clone persistent cutover from database evidence, composes the ordered migration plan, adapts runtime APIs, validates live behavior, and keeps destructive actions operator-approved."
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
            "Release-cohort baseline, Mori-first dependency discovery, migration ownership order, Cabal/Nix alignment, and Kiroku/Keiro/Shibuya/PGMQ/Kioku runtime adaptation checklist."
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
      ]
    }
