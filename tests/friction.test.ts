import { afterEach, describe, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

// The friction script is an integration over okf: it bootstraps a bundle from an
// okf-profiles package, allocates handles, and validates. The package is found
// through OKF_PROFILES_PACKAGE or the Mori registry; without it, or without okf
// on PATH, the suite reports itself skipped rather than failing.
const root = resolve(import.meta.dir, "..");
const temporary: string[] = [];

function which(cmd: string): boolean {
  return Bun.spawnSync(["sh", "-c", `command -v ${cmd}`]).exitCode === 0;
}

function locatePackage(): string | undefined {
  const explicit = process.env.OKF_PROFILES_PACKAGE;
  if (explicit) return existsSync(explicit) ? explicit : undefined;
  if (!which("mori")) return undefined;
  const result = Bun.spawnSync(["mori", "path", "mori://shinzui/okf-profiles"]);
  if (result.exitCode !== 0) return undefined;
  const candidate = join(result.stdout.toString().trim(), "package.dhall");
  return existsSync(candidate) ? candidate : undefined;
}

const registry = locatePackage();
const prerequisites = which("okf") && registry !== undefined;
const skipReason = prerequisites
  ? ""
  : "needs okf on PATH and an okf-profiles checkout (OKF_PROFILES_PACKAGE or mori path mori://shinzui/okf-profiles)";

function temporaryDir() {
  const dir = mkdtempSync(join(tmpdir(), "agent-seihou-friction-"));
  temporary.push(dir);
  return dir;
}
afterEach(() => {
  for (const dir of temporary.splice(0)) rmSync(dir, { recursive: true, force: true });
});

function installFixture() {
  const dir = temporaryDir();
  const skill = join(dir, "skills", "custom-exec");
  mkdirSync(skill, { recursive: true });
  for (const name of ["record-friction.ts", "provenance-model.ts"]) {
    writeFileSync(join(skill, name), readFileSync(join(root, "modules/exec-plan/files", name)));
  }
  return { dir, script: join(skill, "record-friction.ts") };
}

function run(script: string, args: string[], cwd: string) {
  const result = Bun.spawnSync([process.execPath, script, ...args], { cwd, env: { ...process.env } });
  return { code: result.exitCode, stdout: result.stdout.toString(), stderr: result.stderr.toString() };
}

function validate(bundle: string) {
  return Bun.spawnSync(["okf", "validate", bundle, "--strict", "--profile", join(bundle, "profile.dhall"), "--profile-enforce", "--log-enforce"]).exitCode;
}

const identity = ["--model", "claude-exact", "--harness", "claude-code"];
const entry = (title: string, extra: string[] = []) => [
  "log", "--registry", registry ?? "", "--origin", "mori://example/warehouse",
  "--title", title, "--description", "One sentence naming the surface and the cost.",
  "--kind", "tooling", "--impact", "slowdown", "--affects", "mori://example/catalog",
  "--plan", "docs/plans/4-adopt.md", "--attempted", "Ran the freeze.", "--encountered", "It failed.",
  ...extra, ...identity,
];

describe.skipIf(!prerequisites)(`record-friction.ts${skipReason ? ` (skipped: ${skipReason})` : ""}`, () => {
  test("log bootstraps the bundle, allocates FRIC-N with okf, writes a valid entry, and prints its path", () => {
    const f = installFixture();
    const first = run(f.script, entry("Descriptor freeze needs a published tag", [
      "--impact", "detour", "--workaround", "Imported the local checkout.",
      "--evidence", "Error: Remote file not found", "--affected-version", "0.22.0", "--tag", "catalog",
    ]), f.dir);
    expect(first.code).toBe(0);
    expect(first.stdout.trim()).toBe("docs/friction-log/1-descriptor-freeze-needs-a-published-tag.md");
    const bundle = join(f.dir, "docs/friction-log");
    for (const name of ["profile.dhall", "index.md", "log.md"]) expect(existsSync(join(bundle, name))).toBe(true);
    const doc = readFileSync(join(bundle, "1-descriptor-freeze-needs-a-published-tag.md"), "utf8");
    for (const line of [
      "type: Friction Entry", "frictionId: FRIC-1", "status: logged", "impact: detour", "kind: tooling",
      'by: "claude-code/claude-exact"', 'origin: "mori://example/warehouse"', 'affects: "mori://example/catalog"',
      'workaround: "Imported the local checkout."', 'affectedVersion: "0.22.0"', 'plan: "docs/plans/4-adopt.md"',
      '  - "catalog"', "## Attempted", "## Encountered", "```text\nError: Remote file not found\n```", "## Workaround",
    ]) expect(doc).toContain(line);
    expect(readFileSync(join(bundle, "index.md"), "utf8")).toContain("1-descriptor-freeze-needs-a-published-tag.md");
    expect(readFileSync(join(bundle, "log.md"), "utf8")).toContain("FRIC-1 records detour tooling friction");

    const second = run(f.script, entry("Export cursor rejects the page size"), f.dir);
    expect(second.code).toBe(0);
    expect(second.stdout.trim()).toBe("docs/friction-log/2-export-cursor-rejects-the-page-size.md");
    expect(validate(bundle)).toBe(0);

    expect(run(f.script, ["init", "--registry", registry!], f.dir).code).toBe(0);
    expect(readdirSync(bundle).filter((n) => n.endsWith(".md")).length).toBe(4);
  }, 180_000);

  test("update records triage with an amended entry and refuses incomplete transitions", () => {
    const f = installFixture();
    expect(run(f.script, entry("Resume guide omits a step"), f.dir).code).toBe(0);
    const bundle = join(f.dir, "docs/friction-log");
    const path = join(bundle, "1-resume-guide-omits-a-step.md");
    const before = readFileSync(path, "utf8");

    for (const args of [
      ["--status", "duplicate"],
      ["--status", "promoted"],
      ["--status", "promoted", "--promoted-to", "BUG-4"],
      ["--status", "resolved"],
      ["--status", "duplicate", "--duplicate-of", "FRIC-1"],
      ["--status", "accepted", "--resolution", "Fine.", "--model", "unknown"],
    ]) {
      const result = run(f.script, ["update", "--id", "FRIC-1", ...args, ...(args.includes("--model") ? [] : identity)], f.dir);
      expect(result.code).not.toBe(0);
      expect(readFileSync(path, "utf8")).toBe(before);
    }

    const promoted = run(f.script, ["update", "--id", "FRIC-1", "--status", "promoted",
      "--promoted-to", "mori://example/warehouse/okf/bug-reports/concepts/BUG-4",
      "--change", "Promoted once reproducible.", "--codex-session-file", codexSession(f.dir)], f.dir);
    expect(promoted.code).toBe(0);
    expect(promoted.stdout.trim()).toBe("docs/friction-log/1-resume-guide-omits-a-step.md");
    const resolved = run(f.script, ["update", "--id", "FRIC-1", "--status", "resolved", "--resolution", "Guide fixed in 1.3.0.", ...identity], f.dir);
    expect(resolved.code).toBe(0);
    const doc = readFileSync(path, "utf8");
    expect(doc).toContain('status: "resolved"');
    expect(doc).toContain('promotedTo: "mori://example/warehouse/okf/bug-reports/concepts/BUG-4"');
    expect(doc).toContain('resolution: "Guide fixed in 1.3.0."');
    expect(doc).toContain('by: "claude-code/claude-exact"\n  at:');
    expect(doc).toMatch(/amended:\n  - by: "codex-cli\/gpt-exact"\n    at: "[^"]+"\n    change: "Promoted once reproducible."\n  - by: "claude-code\/claude-exact"\n    at: "[^"]+"\n    change: "Status set to resolved."/);
    expect(doc.endsWith("## Encountered\n\nIt failed.\n")).toBe(true);
    expect(readFileSync(join(bundle, "log.md"), "utf8")).toContain("FRIC-1 promoted: Promoted once reproducible.");
    expect(validate(bundle)).toBe(0);
    expect(run(f.script, ["update", "--id", "FRIC-7", "--status", "accepted", "--resolution", "x", ...identity], f.dir).code).not.toBe(0);
  }, 180_000);

  test("log rejects bad input before touching the working tree", () => {
    const f = installFixture();
    const base = entry("Anything");
    const without = (flag: string) => {
      const i = base.indexOf(flag);
      return [...base.slice(0, i), ...base.slice(i + 2)];
    };
    for (const args of [
      without("--model").filter((a) => a !== "--harness" && a !== "claude-code"),
      without("--title"), without("--attempted"), without("--affects"),
      [...without("--impact"), "--impact", "severe"],
      [...without("--kind"), "--kind", "library"],
      [...without("--impact"), "--impact", "detour"],
      [...without("--affects"), "--affects", "the catalog"],
      [...without("--origin"), "--origin", "https://example.com"],
      [...base, "--status", "promoted"],
    ]) {
      expect(run(f.script, args, f.dir).code).not.toBe(0);
      expect(existsSync(join(f.dir, "docs"))).toBe(false);
    }
  }, 60_000);
});

function codexSession(dir: string): string {
  const file = join(dir, "codex.jsonl");
  writeFileSync(file, [
    JSON.stringify({ type: "session_meta", payload: { id: "session-1" } }),
    JSON.stringify({ type: "turn_context", payload: { model: "gpt-exact" } }),
  ].join("\n") + "\n");
  process.env.CODEX_THREAD_ID = "session-1";
  return file;
}
