import { afterAll, expect, test } from "bun:test";
import { cpSync, existsSync, lstatSync, mkdirSync, mkdtempSync, readFileSync, readlinkSync, rmSync, symlinkSync, unlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";

const producer = resolve(import.meta.dir, "..");
// Immutable, real command-based producers; never synthesize a legacy manifest.
const legacyCommit = "4e0a1d711fcb0373dc3733175830dbbbd334ce67";
const binary = process.env.SEIHOU_TEST_BIN;
const legacy = process.env.SEIHOU_LEGACY_TEST_BIN;
if (!binary || !legacy) throw new Error("Set SEIHOU_TEST_BIN (supporting candidate or released runtime) and SEIHOU_LEGACY_TEST_BIN (Seihou 0.9.0.0); checkout acceptance must not be skipped.");
for (const [key, path] of [["SEIHOU_TEST_BIN", binary], ["SEIHOU_LEGACY_TEST_BIN", legacy]]) {
  if (!path!.startsWith("/") || !existsSync(path!)) throw new Error(`${key} must name an existing absolute executable path; got ${path}`);
}
const area = mkdtempSync(join(tmpdir(), "agent-seihou-checkout-"));
const environment = { ...process.env, HOME: join(area, "home"), XDG_CONFIG_HOME: join(area, "config"), XDG_CACHE_HOME: join(area, "cache") };
for (const key of ["HOME", "XDG_CONFIG_HOME", "XDG_CACHE_HOME"]) mkdirSync(environment[key]!, { recursive: true });
afterAll(() => rmSync(area, { recursive: true, force: true }));
function invoke(cwd: string, executable: string, args: string[], ok = true) {
  const result = Bun.spawnSync([executable, ...args], { cwd, env: environment, stdin: new Uint8Array(), timeout: 120_000 });
  const output = result.stdout.toString();
  const error = result.stderr.toString();
  if (ok && result.exitCode !== 0) throw new Error(`${executable} ${args.join(" ")} (${result.exitCode}):\n${output}\n${error}`);
  return { code: result.exitCode, output, error };
}
const run = (cwd: string, args: string[], ok = true) => invoke(cwd, binary!, args, ok);
const git = (cwd: string, ...args: string[]) => invoke(cwd, "git", args).output;
const manifest = (cwd: string) => JSON.parse(readFileSync(join(cwd, ".seihou/manifest.json"), "utf8"));
function project(name: string) {
  const cwd = join(area, name);
  mkdirSync(cwd, { recursive: true });
  git(cwd, "init", "-q");
  git(cwd, "config", "user.name", "Checkout acceptance");
  git(cwd, "config", "user.email", "checkout@example.invalid");
  writeFileSync(join(cwd, ".gitignore"), ".seihou/modules/\n");
  return cwd;
}
function modules(cwd: string, old = false) {
  const destination = join(cwd, ".seihou/modules");
  rmSync(destination, { recursive: true, force: true });
  mkdirSync(destination, { recursive: true });
  if (old) {
    const archive = Bun.spawnSync(["git", "-C", producer, "archive", legacyCommit, "modules"], { stdout: "pipe" });
    if (archive.exitCode !== 0) throw new Error(`Legacy producer commit unavailable: ${legacyCommit}`);
    const extract = Bun.spawnSync(["tar", "-xf", "-", "-C", destination, "--strip-components=1"], { stdin: archive.stdout });
    expect(extract.exitCode).toBe(0);
  } else cpSync(process.env.SEIHOU_TEST_MODULES || join(producer, "modules"), destination, { recursive: true });
}
function source(cwd: string, path: string) {
  mkdirSync(join(cwd, path), { recursive: true });
  writeFileSync(join(cwd, path, "SKILL.md"), "source sentinel\n");
}
function links(cwd: string, name: string, base = "agents", includeCodex = true) {
  const destinations = base === "agents" ? [`.claude/skills/${name}`, `.agents/skills/${name}`, ...(includeCodex ? [`.codex/skills/${name}`] : [])] : [`.claude/skills/${name}`];
  for (const dest of destinations) {
    expect(lstatSync(join(cwd, dest)).isSymbolicLink()).toBe(true);
    expect(readlinkSync(join(cwd, dest))).toBe(`../../${base}/skills/${name}`);
    expect(existsSync(join(cwd, dest, "SKILL.md"))).toBe(true);
  }
}
function declarations(cwd: string, name: string, base = "agents") {
  const m = manifest(cwd);
  const destinations = base === "agents" ? [`.claude/skills/${name}`, `.codex/skills/${name}`, `.agents/skills/${name}`] : [`.claude/skills/${name}`];
  expect(m.version).toBeGreaterThanOrEqual(9);
  for (const dest of destinations) {
    expect(m.checkoutOutputs[dest]).toBeDefined();
    expect(m.checkoutOutputs[dest].spec).toEqual({ kind: "directory-symlink", source: `${base}/skills/${name}` });
    expect(Object.keys(m.checkoutOutputs[dest].owners).length).toBeGreaterThan(0);
    expect(m.files[dest]).toBeUndefined();
  }
  links(cwd, name, base);
}

test("runtime identities are explicit", () => {
  const currentVersion = run(producer, ["--version"]).output.trim();
  const legacyVersion = invoke(producer, legacy!, ["--version"]).output.trim();
  console.info({ currentVersion, legacyVersion, legacyProducer: legacyCommit });
  expect(legacyVersion).toMatch(/^seihou v0\.9\.0\.0(?:\s|$)/);
});

test("real schema-6 command application upgrades to declarations, adopting or creating links under --no-commands", () => {
  const original = project("legacy");
  modules(original, true);
  source(original, "agents/skills/release");
  invoke(original, legacy!, ["run", "link-skill", "--var", "skill.name=release", "--no-save-prompted"]);
  const before = manifest(original);
  expect(before.version).toBe(6);
  expect(before.checkoutOutputs).toBeUndefined();
  expect(JSON.stringify(before.modules)).toContain('"0.2.0"');
  expect(Object.keys(before.applications[0].commandReceipts)).toHaveLength(4);
  const receipts = JSON.stringify(before.applications[0].commandReceipts);
  expect(receipts).toContain("mkdir -p");
  expect(receipts).toContain("ln -sfn");
  links(original, "release", "agents", false);
  for (const missing of [false, true]) {
    const cwd = join(area, missing ? "legacy-missing" : "legacy-correct");
    cpSync(original, cwd, { recursive: true, verbatimSymlinks: true });
    if (missing) for (const harness of [".claude", ".agents"]) unlinkSync(join(cwd, harness, "skills/release"));
    modules(cwd);
    const result = run(cwd, ["update", "link-skill", "--no-commands", "--json"]);
    declarations(cwd, "release");
    expect(Object.keys(manifest(cwd).checkoutOutputs)).toHaveLength(3);
    // Receipts are historical evidence; their timestamps must never be replayed.
    const remaining = manifest(cwd).applications[0].commandReceipts || {};
    for (const [key, value] of Object.entries(remaining)) expect(value).toEqual(before.applications[0].commandReceipts[key]);
    expect(result.output).not.toContain('"execution":"executed"');
    if (missing) cloneProof(cwd, "release", {
      ".claude/skills/release": "../../agents/skills/release",
      ".agents/skills/release": "../../agents/skills/release",
      ".codex/skills/release": "../../agents/skills/release",
    });
  }
}, 120_000);

function snapshot(cwd: string) {
  const paths = git(cwd, "ls-files", "-z").split("\0").filter(Boolean);
  return { index: git(cwd, "ls-files", "--stage", "-z"), bytes: paths.map(path => [path, (lstatSync(join(cwd, path)).isSymbolicLink() ? Buffer.from(readlinkSync(join(cwd, path))) : readFileSync(join(cwd, path))).toString("base64")]) };
}
function commit(cwd: string) {
  git(cwd, "add", ".");
  git(cwd, "commit", "-qm", "test: record real producer application");
}
function cloneProof(original: string, name: string, expected: Record<string, string>) {
  commit(original);
  const cwd = join(area, `${name}-clone`);
  git(original, "clone", "-q", original, cwd);
  expect(existsSync(join(cwd, ".seihou/modules"))).toBe(false);
  expect(existsSync(join(environment.XDG_CONFIG_HOME!, "seihou/installed"))).toBe(false);
  const before = snapshot(cwd);
  const manifestBytes = readFileSync(join(cwd, ".seihou/manifest.json"), "utf8");
  const paths = Object.keys(expected);
  run(cwd, ["status"]);
  const dry = JSON.parse(run(cwd, ["sync", "--dry-run", "--json"]).output);
  expect(dry.summary.planned.created).toBe(paths.length);
  for (const path of paths) expect(existsSync(join(cwd, dirname(path)))).toBe(false);
  const first = JSON.parse(run(cwd, ["sync", "--json"]).output);
  expect(first.summary.applied.created).toBe(paths.length);
  const second = JSON.parse(run(cwd, ["sync", "--json"]).output);
  expect(second.summary.planned.unchanged).toBe(paths.length);
  for (const [path, target] of Object.entries(expected)) {
    expect(readlinkSync(join(cwd, path))).toBe(target);
    expect(existsSync(join(cwd, path, "SKILL.md"))).toBe(true);
  }
  unlinkSync(join(cwd, paths[0]));
  run(cwd, ["sync", "--json"]);
  expect(readlinkSync(join(cwd, paths[0]))).toBe(expected[paths[0]]);
  unlinkSync(join(cwd, paths[0]));
  symlinkSync("wrong-target", join(cwd, paths[0]));
  run(cwd, ["sync", "--json"]);
  expect(readlinkSync(join(cwd, paths[0]))).toBe(expected[paths[0]]);
  expect(snapshot(cwd)).toEqual(before);
  expect(readFileSync(join(cwd, ".seihou/manifest.json"), "utf8")).toBe(manifestBytes);
  expect(git(cwd, "status", "--porcelain")).toBe("");
  // A real directory collision preserves all content and blocks the entire sync.
  unlinkSync(join(cwd, paths[0]));
  source(cwd, paths[0]);
  const refused = run(cwd, ["sync", "--json"], false);
  expect(refused.code).not.toBe(0);
  expect(refused.output).toContain("checkout_destination_occupied");
  expect(readFileSync(join(cwd, paths[0], "SKILL.md"), "utf8")).toBe("source sentinel\n");
  expect(snapshot(cwd)).toEqual(before);
  expect(readFileSync(join(cwd, ".seihou/manifest.json"), "utf8")).toBe(manifestBytes);
  rmSync(join(cwd, paths[0]), { recursive: true });
  run(cwd, ["sync", "--json"]);
  const worktree = join(area, `${name}-worktree`);
  git(original, "worktree", "add", "--detach", "-q", worktree);
  const worktreeBefore = snapshot(worktree);
  run(worktree, ["sync", "--json"]);
  for (const [path, target] of Object.entries(expected)) expect(readlinkSync(join(worktree, path))).toBe(target);
  expect(snapshot(worktree)).toEqual(worktreeBefore);
  expect(git(worktree, "status", "--porcelain")).toBe("");
  git(original, "worktree", "remove", worktree);
}

test("master-plan generates both real skill sources and six portable declarations", () => {
  const cwd = project("master");
  modules(cwd);
  run(cwd, ["run", "master-plan", "--no-commands", "--no-save-prompted", "--var", "intentions.enabled=false"]);
  declarations(cwd, "exec-plan");
  declarations(cwd, "master-plan");
  const m = manifest(cwd);
  expect(Object.keys(m.checkoutOutputs)).toHaveLength(6);
  const application = m.applications[0];
  for (const [path, output] of Object.entries<any>(m.checkoutOutputs)) {
    expect(Object.keys(output.owners)).toEqual([application.applicationId]);
    expect(output.owners[application.applicationId]).toHaveLength(1);
    expect(output.owners[application.applicationId][0]).toMatch(/^(exec-plan#|master-plan$)/);
    expect(Object.keys(m.files)).not.toContain(path);
  }
  cloneProof(cwd, "master", Object.fromEntries(["exec-plan", "master-plan"].flatMap(name =>
    [".claude", ".codex", ".agents"].map(harness => [`${harness}/skills/${name}`, `../../agents/skills/${name}`]))));
}, 120_000);

test("update-docs keeps claude/skills sources and composes the real legacy link module", () => {
  const cwd = project("docs");
  modules(cwd);
  run(cwd, ["run", "update-docs", "--no-commands", "--no-save-prompted", ...[
    "project.name=fixture", "project.description=Checkout acceptance", "skill.name=fixture-update-docs",
    "changelog.path=docs/CHANGELOG.md", "docs.user.dir=docs/user", "docs.dev.dir=docs/dev",
    "source.dirs=src/", "cli.commands.dir=src/CLI", "skills.dir=claude/skills",
  ].flatMap(value => ["--var", value])]);
  declarations(cwd, "fixture-update-docs", "claude");
  expect(Object.keys(manifest(cwd).checkoutOutputs)).toHaveLength(1);
  expect(existsSync(join(cwd, "agents/skills/fixture-update-docs"))).toBe(false);
  cloneProof(cwd, "docs", { ".claude/skills/fixture-update-docs": "../../claude/skills/fixture-update-docs" });
}, 120_000);

test("agreeing real link-skill owners survive one application's removal", () => {
  const cwd = project("owners");
  modules(cwd);
  run(cwd, ["run", "exec-plan", "--no-commands", "--no-save-prompted", "--var", "intentions.enabled=false"]);
  run(cwd, ["run", "link-skill", "--no-commands", "--no-save-prompted", "--var", "skill.name=exec-plan"]);
  const before = manifest(cwd);
  const direct = before.applications.find((app: any) => app.target.name === "link-skill");
  for (const output of Object.values<any>(before.checkoutOutputs)) expect(Object.keys(output.owners)).toHaveLength(2);
  run(cwd, ["remove", "link-skill", "--application", direct.applicationId, "--force"]);
  declarations(cwd, "exec-plan");
  for (const output of Object.values<any>(manifest(cwd).checkoutOutputs)) {
    expect(Object.keys(output.owners)).toHaveLength(1);
    expect(output.owners[direct.applicationId]).toBeUndefined();
  }
}, 120_000);

test("missing source and occupied real directory refuse atomically and preserve content", () => {
  for (const occupied of [false, true]) {
    const cwd = project(occupied ? "occupied" : "missing");
    modules(cwd);
    run(cwd, ["run", "claude-gitignore", "--no-commands", "--no-save-prompted"]);
    if (occupied) {
      source(cwd, "agents/skills/release");
      source(cwd, ".claude/skills/release");
    }
    const before = readFileSync(join(cwd, ".seihou/manifest.json"), "utf8");
    const ignore = readFileSync(join(cwd, ".gitignore"), "utf8");
    const refusal = run(cwd, ["run", "link-skill", "--var", "skill.name=release", "--no-commands", "--no-save-prompted"], false);
    expect(refusal.code).not.toBe(0);
    expect(refusal.output + refusal.error).toMatch(occupied ? /occupied|real file or directory/ : /source.*(missing|directory)|source_missing/i);
    expect(readFileSync(join(cwd, ".seihou/manifest.json"), "utf8")).toBe(before);
    expect(readFileSync(join(cwd, ".gitignore"), "utf8")).toBe(ignore);
    expect(existsSync(join(cwd, ".agents/skills/release"))).toBe(false);
    if (occupied) for (const path of ["agents/skills/release", ".claude/skills/release"])
      expect(readFileSync(join(cwd, path, "SKILL.md"), "utf8")).toBe("source sentinel\n");
  }
}, 120_000);

test("the old runtime refuses the new strategy before recording outputs", () => {
  const cwd = project("old-runtime");
  modules(cwd);
  source(cwd, "agents/skills/release");
  const result = invoke(cwd, legacy!, ["run", "link-skill", "--var", "skill.name=release", "--no-commands", "--no-save-prompted"], false);
  expect(result.code).not.toBe(0);
  expect(result.output + result.error).toMatch(/unknown strategy[^\n]*symlink/i);
  expect(existsSync(join(cwd, ".seihou/manifest.json"))).toBe(false);
  expect(existsSync(join(cwd, ".claude/skills/release"))).toBe(false);
}, 120_000);

test("legacy claude-skill-link command receipts become a declaration without moving its source", () => {
  const cwd = project("legacy-claude");
  modules(cwd, true);
  source(cwd, "claude/skills/release");
  invoke(cwd, legacy!, ["run", "claude-skill-link", "--var", "skill.name=release", "--no-save-prompted"]);
  const before = manifest(cwd);
  expect(before.version).toBe(6);
  expect(before.checkoutOutputs).toBeUndefined();
  expect(before.modules.find((entry: any) => entry.name === "claude-skill-link").version).toBe("0.1.0");
  expect(Object.keys(before.applications[0].commandReceipts)).toHaveLength(2);
  expect(JSON.stringify(before.applications[0].commandReceipts)).toContain("ln -sfn ../../claude/skills/release");
  links(cwd, "release", "claude");
  unlinkSync(join(cwd, ".claude/skills/release"));
  modules(cwd);
  run(cwd, ["update", "claude-skill-link", "--no-commands", "--json"]);
  declarations(cwd, "release", "claude");
  expect(Object.keys(manifest(cwd).checkoutOutputs)).toHaveLength(1);
  expect(readFileSync(join(cwd, "claude/skills/release/SKILL.md"), "utf8")).toBe("source sentinel\n");
  expect(existsSync(join(cwd, "agents/skills/release"))).toBe(false);
}, 120_000);


test("planning compositions link custom source names at all three tool destinations", () => {
  const cwd = project("custom-planning");
  modules(cwd);
  run(cwd, ["run", "master-plan", "--no-commands", "--no-save-prompted", "--var", "intentions.enabled=false", "--var", "mp.skill.name=roadmap", "--var", "skill.name=execution", "--var", "exec-plan.skill.name=execution"]);
  declarations(cwd, "roadmap");
  declarations(cwd, "execution");
  expect(Object.keys(manifest(cwd).checkoutOutputs)).toHaveLength(6);
  cloneProof(cwd, "custom", Object.fromEntries(["roadmap", "execution"].flatMap(name =>
    [".claude", ".codex", ".agents"].map(tool => [`${tool}/skills/${name}`, `../../agents/skills/${name}`]))));
}, 120_000);
