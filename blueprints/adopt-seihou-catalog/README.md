# adopt-seihou-catalog

Adopt or refresh the typed catalog for a Seihou registry in
`mori://shinzui/mori`. Run the blueprint from the target checkout containing
`seihou-registry.dhall` and `mori.dhall`.

**Version** `0.1.0`

## Run

Install the blueprint from this registry, then run it in the target checkout.
Set `REGISTRY_GIT_SOURCE` to a Git source containing this blueprint.

```sh
seihou install "$REGISTRY_GIT_SOURCE" --module adopt-seihou-catalog
seihou agent run adopt-seihou-catalog
```

Use the checkout's configured local Mori registry. The workflow needs a Mori
CLI exposing `--adopt-seihou-catalog`, the Seihou OKF extension, and `okf` for
validation.

The blueprint regenerates the Seihou documentation, previews and applies the
catalog migration, checks legacy overrides, validates the files, and refreshes
the local registry. It reports discovered features and their documentation
links. On a repeat run, it keeps the existing catalog declaration and applies
any pending ordinary manifest migrations.
