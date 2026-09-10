# SeihouBlueprint

- [docs-sync](docs-sync.md) - Discover a project's local and sibling documentation/agent-context surfaces, then audit and repair stale surfaces against authoritative code using a baseline-SHA ledger
- [hackage-release](hackage-release.md) - Agent-driven blueprint that generates a project-specific 'release' skill for publishing Haskell packages to Hackage (PVP versioning, changelog updates, dependency-ordered publishing, GitHub release), tailored to the repo's actual package layout and linked into both .claude/skills and .agents/skills
- [migrate-keiro-stack](migrate-keiro-stack.md) - Agent-driven workflow that migrates a Haskell/PostgreSQL project to a coherent pg-migrate, PGMQ, Kiroku, Keiro, Kioku, and Shibuya cohort, adopts the shared haskell-nix package set when the target already uses Nix, and selects a guarded disposable reset or a backup-and-restored-clone persistent cutover from database evidence

