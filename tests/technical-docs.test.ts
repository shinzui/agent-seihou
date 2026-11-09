import { afterAll, expect, test } from "bun:test";
import { cpSync, existsSync, lstatSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, readlinkSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";

const producer = resolve(import.meta.dir, "..");
const binary = process.env.SEIHOU_TEST_BIN;
if (!binary) throw new Error("Set SEIHOU_TEST_BIN to an absolute path to the seihou binary; generation acceptance must not be skipped.");
if (!binary.startsWith("/") || !existsSync(binary)) throw new Error(`SEIHOU_TEST_BIN must name an existing absolute executable path; got ${binary}`);

const area = mkdtempSync(join(tmpdir(), "agent-seihou-technical-docs-"));
const environment = { ...process.env, HOME: join(area, "home"), XDG_CONFIG_HOME: join(area, "config"), XDG_CACHE_HOME: join(area, "cache") };
for (const key of ["HOME", "XDG_CONFIG_HOME", "XDG_CACHE_HOME"] as const) mkdirSync(environment[key], { recursive: true });
afterAll(() => rmSync(area, { recursive: true, force: true }));

const forms = ["tutorial", "how-to", "reference", "explanation", "walkthrough"];
const skillNames = (prefix: string) => [prefix, ...forms.map(form => `${prefix}-${form}`)];
const harnesses = [".claude", ".codex", ".agents"];

function invoke(cwd: string, executable: string, args: string[]) {
  const result = Bun.spawnSync([executable, ...args], { cwd, env: environment, stdin: new Uint8Array(), timeout: 120_000 });
  const output = result.stdout.toString();
  const error = result.stderr.toString();
  if (result.exitCode !== 0) throw new Error(`${executable} ${args.join(" ")} (${result.exitCode}):\n${output}\n${error}`);
  return output;
}
const run = (cwd: string, ...args: string[]) => invoke(cwd, binary!, args);

function project(name: string) {
  const cwd = join(area, name);
  mkdirSync(cwd, { recursive: true });
  invoke(cwd, "git", ["init", "-q"]);
  invoke(cwd, "git", ["config", "user.name", "Generation acceptance"]);
  invoke(cwd, "git", ["config", "user.email", "generation@example.invalid"]);
  writeFileSync(join(cwd, ".gitignore"), ".seihou/modules/\n");
  for (const module of ["agent-gitignore", "technical-docs"])
    cpSync(join(producer, "modules", module), join(cwd, ".seihou/modules", module), { recursive: true });
  return cwd;
}

const skillFile = (cwd: string, name: string, file = "SKILL.md") => join(cwd, "agents/skills", name, file);
const read = (cwd: string, name: string, file = "SKILL.md") => readFileSync(skillFile(cwd, name, file), "utf8");

function frontmatterName(text: string) {
  const block = text.match(/^---\n([\s\S]*?)\n---\n/);
  if (!block) throw new Error(`No frontmatter in:\n${text.slice(0, 200)}`);
  const name = block[1].match(/^name:\s*"?([^"\n]+?)"?\s*$/m);
  if (!name) throw new Error(`No name in frontmatter:\n${block[1]}`);
  return name[1];
}

function bodyOf(text: string) {
  return text.replace(/^---\n[\s\S]*?\n---\n/, "");
}

function filesUnder(root: string): string[] {
  return readdirSync(root, { withFileTypes: true }).flatMap(entry => {
    const path = join(root, entry.name);
    return entry.isDirectory() ? filesUnder(path) : [path];
  });
}

function snapshot(cwd: string) {
  const root = join(cwd, "agents/skills");
  return Object.fromEntries(filesUnder(root).sort().map(path => [relative(root, path), readFileSync(path).toString("base64")]));
}

function relativeLinks(text: string) {
  return [...text.matchAll(/\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g)]
    .map(match => match[1])
    .filter(target => !/^[a-z][a-z0-9+.-]*:/i.test(target) && !target.startsWith("#"));
}

let defaultProject: string;
function applied() {
  if (!defaultProject) {
    defaultProject = project("default");
    run(defaultProject, "run", "technical-docs", "--no-save-prompted");
  }
  return defaultProject;
}

test("the default prefix creates six skills whose frontmatter names match their directories", () => {
  const cwd = applied();
  expect(readdirSync(join(cwd, "agents/skills")).sort()).toEqual(skillNames("tech-docs").sort());
  for (const name of skillNames("tech-docs")) expect(frontmatterName(read(cwd, name))).toBe(name);
}, 120_000);

test("every skill carries a byte-identical WRITING-RULES.md", () => {
  const cwd = applied();
  const copies = skillNames("tech-docs").map(name => readFileSync(skillFile(cwd, name, "WRITING-RULES.md")));
  expect(copies).toHaveLength(6);
  for (const copy of copies) expect(copy.equals(copies[0])).toBe(true);
}, 120_000);

test("all 18 discovery links target the skill source and expose SKILL.md", () => {
  const cwd = applied();
  let checked = 0;
  for (const name of skillNames("tech-docs")) {
    for (const harness of harnesses) {
      const link = join(cwd, harness, "skills", name);
      expect(lstatSync(link).isSymbolicLink()).toBe(true);
      expect(readlinkSync(link)).toBe(`../../agents/skills/${name}`);
      expect(readFileSync(join(link, "SKILL.md"), "utf8")).toBe(read(cwd, name));
      checked += 1;
    }
  }
  expect(checked).toBe(18);
}, 120_000);

test("a second run leaves every generated skill byte unchanged", () => {
  const cwd = applied();
  const before = snapshot(cwd);
  run(cwd, "run", "technical-docs", "--no-save-prompted");
  expect(snapshot(cwd)).toEqual(before);
}, 120_000);

test("relative Markdown links in SKILL.md stay inside their own skill directory", () => {
  const cwd = applied();
  for (const name of skillNames("tech-docs")) {
    const directory = join(cwd, "agents/skills", name);
    for (const target of relativeLinks(read(cwd, name))) {
      const path = resolve(directory, target.split("#")[0]);
      expect(relative(directory, path).startsWith("..")).toBe(false);
      expect(existsSync(path) && statSync(path).isFile()).toBe(true);
    }
  }
}, 120_000);

test("the entry skill names all five form skills", () => {
  const body = bodyOf(read(applied(), "tech-docs"));
  for (const form of forms) expect(body).toContain(`tech-docs-${form}`);
}, 120_000);

test("a custom prefix renames all six skills and leaves no default name or placeholder", () => {
  const cwd = project("custom");
  run(cwd, "run", "technical-docs", "--no-save-prompted", "--var", "skill.prefix=acme-docs");
  expect(readdirSync(join(cwd, "agents/skills")).sort()).toEqual(skillNames("acme-docs").sort());
  for (const name of skillNames("acme-docs")) {
    const text = read(cwd, name);
    expect(frontmatterName(text)).toBe(name);
    expect(text).not.toContain("tech-docs");
    expect(text).not.toContain("{{");
    expect(dirname(readlinkSync(join(cwd, ".claude/skills", name)))).toBe("../../agents/skills");
  }
}, 120_000);
