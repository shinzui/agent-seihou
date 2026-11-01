-- Requires the single-base recipe CLI delivery tracked by
-- mori://shinzui/seihou/plans/118-extend-recipes-through-a-single-origin-aware-base
{ name = "haskell-cli-app-with-agents"
, version = Some "0.1.0"
, description = Some "Bootstrap a Haskell CLI repository with shared agent ignore rules and a configured GitHub owner."
, extends = Some
    { recipe = "haskell-cli-app-repo"
    , source = Some "https://github.com/shinzui/seihou-modules.git"
    , versionRange = Some { minimum = "0.1.0", before = "0.2.0" }
    }
, modules =
    [ { module = "agent-gitignore", vars = [] : List { name : Text, value : Text } } ]
, moduleOverrides =
    [ { module = "git-init", vars = [ { name = "git.githubOwner", value = "shinzui" } ] } ]
, vars = [] : List { name : Text, type : Text, default : Optional Text, description : Optional Text, required : Bool, validation : Optional Text }
, prompts = [] : List { var : Text, text : Text, when : Optional Text, choices : Optional (List Text) }
}
