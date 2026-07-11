let Prompt =
      { var : Text, text : Text, when : Optional Text, choices : Optional (List Text) }

let CommandVar =
      { name : Text
      , run : Text
      , workDir : Optional Text
      , when : Optional Text
      , trim : Bool
      , maxBytes : Optional Natural
      }

let PromptFile =
      { src : Text, description : Optional Text }

let PromptGuidance =
      { title : Text, body : Text, when : Optional Text }

let Launch =
      { provider : Optional Text, mode : Optional Text, model : Optional Text }

in  { name = "fix-prelude-import-conflicts"
    , version = Some "0.1.0"
    , description = Some
        "Fix custom-prelude import-conflict violations in a Haskell repo: hide clashing names from the prelude import (never the other import) and never qualify operators. Detects qualified operators, wrong-side hiding, and clash-avoiding qualified prelude imports, fixes them, and verifies with cabal. Adjust the guidance blocks per project."
    , prompt = ./prompt.md as Text
    , vars = [] : List
        { name : Text
        , type : Text
        , default : Optional Text
        , description : Optional Text
        , required : Bool
        , validation : Optional Text
        }
    , prompts = [] : List Prompt
    , commandVars = [] : List CommandVar
    , guidance =
      [ { title = "Custom-prelude invariants"
        , body =
            ''
            These two rules are non-negotiable and override any local habit:

            1. Resolve a name clash by hiding the name from the **prelude** import
               (`import P hiding (name)`), never from the other import.
            2. Never qualify an operator. Import operators unqualified and resolve
               clashes by hiding (rule 1).

            Keep edits scoped to imports and operator call sites. Do not reformat
            unrelated code and do not touch the prelude module's own contents.''
        , when = None Text
        }
      , { title = "Verify with cabal"
        , body =
            "Verify with `cabal build all` (and focused `cabal build <pkg>` while iterating). Build after each batch of edits and do not consider a batch done until it compiles."
        , when = None Text
        }
      , -- Per-project guidance: edit this block (or add more) for the repo you
        -- are running against. Name the prelude module, list directories to
        -- skip, the project's preferred operator sources, known acceptable
        -- exceptions, etc. Delete it if there is nothing project-specific.
        { title = "Project-specific guidance"
        , body =
            ''
            (Replace this with guidance for the current project. For example:
            the prelude module is `Acme.Prelude`; skip the `vendored/` directory;
            the `<+>` operator comes from `Data.Semigroup.Foldable`, not the
            prelude.)''
        , when = None Text
        }
      ]
    , files = [] : List PromptFile
    , allowedTools = None (List Text)
    , tags = [ "haskell", "refactoring", "prelude", "imports" ]
    , launch = None Launch
    }
