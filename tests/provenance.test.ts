import { afterEach, describe, expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { claudeModel, codexModel, resolveModel } from "../modules/exec-plan/files/provenance-model.ts";

const root = resolve(import.meta.dir, "..");
const temporary: string[] = [];
const jsonl = (...records: unknown[]) => records.map((record) => JSON.stringify(record)).join("\n") + "\n";
const codex = (model: unknown) => ({ type: "turn_context", payload: { model } });
const meta = { type: "session_meta", payload: { id: "session-1" } };
const claude = (model: unknown, agentId?: string) => ({
  type: "assistant", sessionId: "session-1", agentId, isSidechain: !!agentId,
  message: { role: "assistant", model, content: [{ type: "tool_use" }] },
});
const user = (content: unknown) => ({ type: "user", sessionId: "session-1", message: { content } });

function temporaryDir() {
  const dir = mkdtempSync(join(tmpdir(), "agent-seihou-provenance-"));
  temporary.push(dir);
  return dir;
}
afterEach(() => {
  for (const dir of temporary.splice(0)) rmSync(dir, { recursive: true, force: true });
});

describe("runtime model discovery", () => {
  test("Codex selects the latest turn, not the initial model or message contents", () => {
    expect(codexModel(jsonl(meta, codex("old-model"), codex("new-model"),
      { type: "response_item", model: "not-metadata" }), "session-1")).toBe("new-model");
  });
  test("Codex rejects wrong sessions, missing current model, and corrupt records", () => {
    expect(() => codexModel(jsonl(meta, codex("model")), "wrong")).toThrow("does not match");
    expect(() => codexModel(jsonl(codex("model")), "session-1")).toThrow("does not match");
    expect(() => codexModel(jsonl(meta, meta, codex("model")), "session-1")).toThrow("multiple");
    for (const missing of [undefined, null, "", "unknown", "<synthetic>"]) {
      expect(() => codexModel(jsonl(meta, codex("old"), codex(missing)), "session-1")).toThrow("no exact model");
    }
    expect(() => codexModel(jsonl(meta, codex("model")) + "PRIVATE malformed data", "session-1")).toThrow("invalid JSON");
  });
  test("Claude selects the current assistant model across switches and tool results", () => {
    expect(claudeModel(jsonl(claude("old"), user("new prompt"), claude("claude-opus-5"),
      user([{ type: "tool_result", content: "result" }])), "session-1")).toBe("claude-opus-5");
  });
  test("Claude rejects stale, synthetic, missing, mismatched, and malformed metadata", () => {
    expect(() => claudeModel(jsonl(claude("old"), user("new prompt")), "session-1")).toThrow("no exact model");
    expect(() => claudeModel(jsonl(claude("old"), claude(undefined)), "session-1")).toThrow("no exact model");
    expect(() => claudeModel(jsonl(claude("<synthetic>")), "session-1")).toThrow("no exact model");
    expect(() => claudeModel(jsonl(claude("model")), "other-session")).toThrow("does not match");
    expect(() => claudeModel(jsonl(claude("model")) + "{", "session-1")).toThrow("invalid JSON");
  });
  test("Claude distinguishes the parent and each subagent even in the same session", () => {
    expect(claudeModel(jsonl(claude("child-model", "child-1")), "session-1", "child-1")).toBe("child-model");
    expect(() => claudeModel(jsonl(claude("parent")), "session-1", "child-1")).toThrow("agent identity mismatch");
    expect(() => claudeModel(jsonl(claude("child", "child-1")), "session-1")).toThrow("agent identity mismatch");
    expect(() => claudeModel(jsonl(claude("child", "child-2")), "session-1", "child-1")).toThrow("agent identity mismatch");
  });
  test("explicit identities work for other harnesses; unknown needs an explained opt-in", () => {
    expect(resolveModel({ model: " model-exact ", harness: "custom-harness" })).toEqual({ model: "model-exact", harness: "custom-harness", note: undefined });
    for (const args of [{}, { model: " " }, { model: "unknown" }, { model: " UNKNOWN ", "allow-unknown": true },
      { model: "unknown", "unknown-reason": "missing" }, { model: "known", "allow-unknown": true },
      { model: "unknown", "allow-unknown": true, "unknown-reason": " \n " }]) {
      expect(() => resolveModel(args)).toThrow();
    }
    expect(resolveModel({ model: "unknown", "allow-unknown": true, "unknown-reason": "Runtime context and session metadata unavailable" }).note)
      .toBe("Model discovery unavailable: Runtime context and session metadata unavailable");
  });
  test("file discovery requires unambiguous inputs and verifies environment identity", () => {
    const dir = temporaryDir();
    const file = join(dir, "session.jsonl");
    writeFileSync(file, jsonl(meta, codex("gpt-exact")));
    expect(resolveModel({ "codex-session-file": file }, { CODEX_THREAD_ID: "session-1" }).harness).toBe("codex-cli");
    expect(resolveModel({ "codex-session-file": file }, { CODEX_SESSION_ID: "session-1" }).model).toBe("gpt-exact");
    for (const args of [
      { "codex-session-file": file },
      { "codex-session-file": file, "codex-session-id": "wrong" },
      { "codex-session-file": file, "codex-session-id": "session-1", model: "manual" },
      { "codex-session-file": file, "codex-session-id": "session-1", harness: "claude-code" },
      { "codex-session-file": file, "claude-session-file": file },
      { model: "manual", "claude-session-id": "session-1" },
      { "claude-session-file": file },
      { "codex-session-file": join(dir, "missing"), "codex-session-id": "session-1" },
    ]) expect(() => resolveModel(args, {})).toThrow();
  });
});

// Exercise deployed relative imports, including custom skill directory names.
function installFixture() {
  const dir = temporaryDir();
  const ep = join(dir, "skills", "custom-exec");
  const mp = join(dir, "skills", "custom-master");
  mkdirSync(ep, { recursive: true });
  mkdirSync(mp, { recursive: true });
  for (const name of ["init-plan.ts", "record-provenance.ts", "provenance-model.ts"]) {
    writeFileSync(join(ep, name), readFileSync(join(root, "modules/exec-plan/files", name)));
  }
  writeFileSync(join(mp, "init-masterplan.ts"),
    readFileSync(join(root, "modules/master-plan/files/init-masterplan.ts"), "utf8")
      .replaceAll("{{exec-plan.skill.name}}", "custom-exec"));
  const codexFile = join(dir, "codex.jsonl");
  const claudeFile = join(dir, "claude.jsonl");
  writeFileSync(codexFile, jsonl(meta, codex("old"), codex("gpt-exact")));
  writeFileSync(claudeFile, jsonl(claude("old"), user("next turn"), claude("claude-exact")));
  return { dir, ep, mp, codexFile, claudeFile };
}
function run(script: string, args: string[], cwd: string) {
  const result = Bun.spawnSync([process.execPath, script, ...args], { cwd, env: { ...process.env, CODEX_THREAD_ID: "session-1" } });
  return { code: result.exitCode, stdout: result.stdout.toString(), stderr: result.stderr.toString() };
}

for (const scriptName of ["init-plan.ts", "init-masterplan.ts"]) {
  describe(scriptName, () => {
    test("rejects missing and unexplained unknown identities before creating a directory", () => {
      const f = installFixture();
      const script = join(scriptName === "init-plan.ts" ? f.ep : f.mp, scriptName);
      const output = join(f.dir, "plans");
      for (const args of [[], ["--model", "unknown"], ["--model", "unknown", "--allow-unknown"]]) {
        expect(run(script, ["--title", "Test", "--dir", output, ...args], f.dir).code).not.toBe(0);
        expect(existsSync(output)).toBe(false);
      }
    });
    test("records Codex, Claude, explicit IDs, and explained unknown in created_by", () => {
      const f = installFixture();
      const script = join(scriptName === "init-plan.ts" ? f.ep : f.mp, scriptName);
      for (const [args, model, harness] of [
        [["--codex-session-file", f.codexFile], "gpt-exact", "codex-cli"],
        [["--claude-session-file", f.claudeFile, "--claude-session-id", "session-1"], "claude-exact", "claude-code"],
        [["--model", "manual-exact", "--harness", "other"], "manual-exact", "other"],
        [["--model", "unknown", "--allow-unknown", "--unknown-reason", "Metadata inaccessible"], "unknown", undefined],
      ] as const) {
        const result = run(script, ["--title", "Test", "--dir", join(f.dir, "plans"), ...args], f.dir);
        expect(result.code).toBe(0);
        const doc = readFileSync(result.stdout.trim(), "utf8");
        expect(doc).toContain(`created_by:\n    model: "${model}"`);
        if (harness) expect(doc).toContain(`harness: "${harness}"`);
        if (model === "unknown") expect(doc).toContain('note: "Model discovery unavailable: Metadata inaccessible"');
      }
    });
  });
}

describe("record-provenance.ts", () => {
  test("appends verified identities, preserves existing history/body, and deduplicates fallback reasons", () => {
    const f = installFixture();
    const plan = join(f.dir, "plan.md");
    const initial = '---\nid: 7\nprovenance:\n  created_by:\n    model: "original"\n    at: 2026-01-01T00:00:00Z\n---\n\n# Existing plan\nKeep body.\n';
    writeFileSync(plan, initial);
    const script = join(f.ep, "record-provenance.ts");
    const base = ["revision", "--plan", plan, "--mode", "update", "--at", "2026-09-10T17:00:00Z"];
    for (const args of [["--model", "unknown"], ["--claude-session-file", f.claudeFile, "--claude-session-id", "wrong"]]) {
      expect(run(script, [...base, ...args], f.dir).code).not.toBe(0);
      expect(readFileSync(plan, "utf8")).toBe(initial);
    }
    expect(run(script, [...base, "--codex-session-file", f.codexFile], f.dir).code).toBe(0);
    expect(run(script, ["review", "--plan", plan, "--claude-session-file", f.claudeFile, "--claude-session-id", "session-1", "--verdict", "approved"], f.dir).code).toBe(0);
    const unknown = [...base, "--model", "unknown", "--allow-unknown", "--unknown-reason", "Runtime metadata unavailable", "--note", "Changed scope"];
    expect(run(script, unknown, f.dir).code).toBe(0);
    const recorded = readFileSync(plan, "utf8");
    expect(recorded).toContain('created_by:\n    model: "original"\n    at: 2026-01-01T00:00:00Z');
    expect(recorded).toContain('model: "gpt-exact"');
    expect(recorded).toContain('model: "claude-exact"');
    expect(recorded).toContain('note: "Changed scope; Model discovery unavailable: Runtime metadata unavailable"');
    expect(recorded.endsWith("# Existing plan\nKeep body.\n")).toBe(true);
    expect(run(script, unknown, f.dir).code).toBe(0);
    expect(readFileSync(plan, "utf8")).toBe(recorded);
  });
});
