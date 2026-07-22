# Settei Configuration Migration

Migrate configuration to the released Settei 0.2.0.0 family without changing the values the
service resolves. Settei replaces scattered loading logic with one statically inspectable
`Config a`, ordered sources, typed errors, and a redaction-aware provenance report. Upgrade every
Settei package together; mixed family versions are unsupported.

## Capture current behavior before editing

Inventory every raw Dhall `FromDhall`/`inputFile auto` call, environment lookup, CLI override,
default, conditional requirement, secret, config file, mounted directory, and deployment argument.
Build a key table containing current name, type, default, sensitivity, source, precedence, and all
known spellings. Capture redacted resolved results for representative development, test, and
production fixtures. Never put raw credentials in the fixture or migration notes.

Preserve source behavior first. Key renames, new defaults, deployment-value changes, and removal of
old spellings are separate follow-up changes.

## Declare one inspectable target

Use public APIs from `Settei`, `Settei.Env`, `Settei.Formats`, `Settei.Optparse`, and
`Settei.Kubernetes`. Declare every possible setting applicatively. `Config` deliberately has no
`Monad`; use `whenConfig` or `whenEq` for conditional requirements, `fallbackTo` for a spelling
transition, and `withDefault` for named defaults.

```haskell
serviceConfig :: Config ServiceConfig
serviceConfig =
  ServiceConfig
    <$> required environmentSetting
    <*> withDefault
      httpPortSetting
      (constantDefault (RuleName "http-default-port") "Use the service HTTP port" 8080)
    <*> required databaseHostSetting
    <*> whenEq
      (required environmentSetting)
      Production
      (required databasePasswordSetting)
```

Define stable hierarchical keys with `parseKey`. Use `publicSetting`,
`publicSettingWithRenderer`, or `publicShowSetting` only for values safe to expose. Use
`secretSetting` for credentials and keep secret-bearing constructors private without a revealing
`Show` instance. Sensitivity belongs to the logical key, not the environment variable or mounted
file that supplied it.

## Make precedence explicit

The service order is low to high: general configuration files, mounted Kubernetes Secret
directories, then explicitly bound environment variables. Construct that list once per binary and
reject unknown keys.

```haskell
resolveServiceSources
  :: [Source]
  -> [Source]
  -> EnvSnapshot
  -> ResolveResult ServiceConfig
resolveServiceSources files mountedSecrets snapshot =
  resolve
    (ResolveOptions RejectUnknownKeys)
    (files <> mountedSecrets <> [environmentSource environmentBindings snapshot])
    serviceConfig
```

There is no runtime prefix scan. Create every mapping with `binding`, validate the collection with
`bindings`, and force the production `environmentBindings` CAF in a unit test. For mounted Secret
directories, build explicit `fileBindings` and load them with `readMountedDirectorySource`.
Review `unboundMountedFiles`; an unbound file should fail deployment validation rather than become
an accidental input.

During a raw Dhall transition, load the existing document through `settei-dhall`. Select
`NoImports` by default or `LocalImportsWithin` an explicit root. Treat an import closure as one
source because leaf-level attribution cannot survive normalization. Do not keep direct application
decoding alongside Settei after equivalent behavior is proven.

## Add diagnostics before changing deployment

Mount `diagnosticModeOptions` in every service binary:

- `--describe-config` and `--describe-config-json` print the static schema without reading sources;
- `--explain-config` and `--explain-config-json` resolve sources and print safe provenance;
- `--check-config` resolves exactly as normal startup, prints only redacted diagnostics, and exits
  before acquiring listeners, pools, telemetry exporters, or workers.

Reserve exit code 2 for usage, 3 for source IO/parsing, and 4 for typed resolution. Keep a planted
secret-sentinel test that asserts the sentinel appears in neither standard output, standard error,
errors, nor rendered reports, while the redaction marker does appear. Log a separate allowlisted
startup summary; never interpolate the complete resolved record.

For every captured fixture, compare the old redacted result to the Settei result. The selected
values, defaults, failures, and precedence must match unless a separate reviewed behavior change
explicitly says otherwise.

## Gate Kubernetes rollout with the real path

Use one immutable image across namespaces. Mount general ConfigMap data and Secret directories
separately. Run an init container with the same image, arguments, environment, service account, and
mounts as the main container; add only `--check-config`. A nonzero 2/3/4 result blocks the pod before
it opens a listener or consumes messages.

Render every Kustomize overlay in CI, validate it offline, and assert that the init and main
containers receive identical inputs. Namespace identity may be recorded through `POD_NAMESPACE`,
but it must not silently select databases, credentials, or feature behavior. Settei resolves a
startup snapshot; use a deployment rollout for config changes rather than a hand-rolled reload.

## Migration acceptance

The phase is complete only when:

- the old key/default/source inventory is reconciled to the new declaration;
- every explicit environment and mounted-file binding constructs in tests;
- representative redacted before/after fixtures match;
- unknown keys fail;
- malformed highest-precedence values fail rather than falling back;
- the secret sentinel stays redacted;
- all diagnostic modes return the reserved exit behavior;
- `--check-config` uses the normal source path and starts no runtime resources;
- rendered deployment overlays contain the matching rollout gate.

## Normative citations and source

Discover these docs with `mori registry docs shinzui/keiro-runtime-patterns`:

| Topic | Path | DocRef key |
|---|---|---|
| Service declaration and sources | `config/settei-service-standard.md` | `config-settei-service-standard` |
| Kubernetes rollout and drain | `config/kubernetes-deployment.md` | `config-kubernetes-deployment` |
| Adapter and resolver traps | `config/settei-gotchas.md` | `config-settei-gotchas` |

Run `mori registry show shinzui/settei --full` and read
`examples/settei-service/src/Settei/Example/Service.hs` plus the relevant guides at the reported
path before using exact imports. The APIs and examples above were verified against Settei release
revision `1bf62b0af110b4f42fe2528e9d459e0ccf12d626`.
