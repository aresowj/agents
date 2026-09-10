import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import * as fs from "node:fs";
import * as path from "node:path";

/**
 * lazy-tools — dynamic tool loading for pi.
 *
 * Keeps heavyweight tool groups REGISTERED but INACTIVE so their large
 * descriptions do not occupy the system prompt every session. A small
 * `search_tools` loader stays active; calling it activates matching tools
 * for the rest of the session (additive change, per docs "Dynamic Tool
 * Loading" in extensions.md).
 *
 * Per-project override: place `.pi/lazy-tools.json` in the project root:
 *   { "eager": ["linear_"] }        // keep these prefixes active at startup
 */

// Default lazy groups (tool name prefix or exact match).
// NOTE: workflow/workflow_control are intentionally NOT listed —
// @quintinshaw/pi-dynamic-workflows force-re-adds them on every session_start,
// so deferring here would be undone. They stay eager (~1k tokens total).
const LAZY_EXACT = new Set([
  "subagent",
  // MCP gateway (pi-mcp-adapter): typically no servers connected; activate on demand.
  "mcp",
  "mcpScript",
  // Web research group: large schemas, defer until a task needs web access.
  "web_search",
  "source_check",
  "fetch_content",
  "get_search_content",
]);
const LAZY_PREFIXES: string[] = [
  // @alasano/pi-linear: deferred via its own tool-settings.json (seeded below);
  // also listed here as belt-and-suspenders for sessions before seeding applies.
  "linear_",
  "bg_",     // pi-subagents / pi-background tasks family
  "fusion_", // multi-model fusion reasoning
];

function isLazyName(name: string): boolean {
  return LAZY_EXACT.has(name) || LAZY_PREFIXES.some((p) => name.startsWith(p));
}

// @alasano/pi-linear re-activates all of its tools on session_start unless they
// are listed in disabledTools. Seed that settings file ONCE (never overwrite an
// existing one, so user choices made via /linear-settings survive).
import * as os from "node:os";

function seedLinearSettings(allToolNames: string[]): void {
  const stateDir = path.join(os.homedir(), ".pi", "agent", "state", "extensions", "linear");
  const file = path.join(stateDir, "tool-settings.json");
  try {
    if (fs.existsSync(file)) return;
    fs.mkdirSync(stateDir, { recursive: true });
    const disabledTools = allToolNames.filter((n) => n.startsWith("linear_"));
    if (disabledTools.length === 0) return;
    fs.writeFileSync(file, JSON.stringify({ disabledTools, defaultJsonView: false }, null, 2));
    console.error(`[lazy-tools] seeded Linear tool-settings.json with ${disabledTools.length} tools disabled`);
  } catch (e) {
    console.error("[lazy-tools] failed to seed Linear settings:", e instanceof Error ? e.message : String(e));
  }
}

// Project override may declare extra prefixes to keep eager (active).
interface Override {
  eager?: string[];
}

function readOverride(): string[] {
  try {
    const file = path.join(process.cwd(), ".pi", "lazy-tools.json");
    const data: Override = JSON.parse(fs.readFileSync(file, "utf8"));
    return Array.isArray(data.eager) ? data.eager : [];
  } catch {
    return [];
  }
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "search_tools",
    label: "Search Tools",
    description:
      "Search for and activate tools relevant to a task. Hidden capability groups include: Linear issue tracking (linear_*), subagent delegation, background tasks (bg_*), fusion multi-model reasoning, the MCP gateway (mcp/mcpScript), and web research (web_search/source_check/fetch_content/get_search_content). Workflow tools stay always available. Pass names to activate exact tool names, or query to keyword-search all registered tools.",
    promptSnippet:
      "Tools in the hidden groups above are not active until you call search_tools; use it when a task needs Linear issues, background/fusion work, web research (web_search and friends), or MCP gateway tools. Workflow tools stay always available.",
    parameters: Type.Object({
      query: Type.Optional(
        Type.String({ description: "Capability or task to keyword-search for" }),
      ),
      names: Type.Optional(
        Type.Array(Type.String(), {
          description: "Exact registered tool names to activate",
        }),
      ),
    }),
    async execute(_toolCallId, params) {
      const all = pi.getAllTools();
      const activeSet = new Set(pi.getActiveTools());

      let matches: { name: string; desc: string; score: number }[] = [];

      if (params.names && params.names.length > 0) {
        for (const n of params.names) {
          const t = all.find((x) => x.name === n);
          if (t) matches.push({ name: t.name, desc: t.description.slice(0, 160), score: 99 });
        }
      }

      if (params.query) {
        const terms = params.query.toLowerCase().split(/[^a-z0-9_]+/).filter(Boolean);
        for (const tool of all) {
          const nameL = tool.name.toLowerCase();
          const descL = tool.description.toLowerCase();
          let score = 0;
          for (const term of terms) {
            if (nameL.includes(term)) score += 2;
            if (descL.includes(term)) score += 1;
          }
          if (score > 0) matches.push({ name: tool.name, desc: tool.description.slice(0, 160), score });
        }
      }

      if (matches.length === 0) {
        return {
          content: [{ type: "text", text: `No tools found for the given query/names.` }],
          details: { matches: [] },
        };
      }

      matches.sort((a, b) => b.score - a.score);
      const top = matches.slice(0, 8);
      const toActivate = top.filter((m) => !activeSet.has(m.name)).map((m) => m.name);

      if (toActivate.length > 0) {
        pi.setActiveTools([...new Set([...pi.getActiveTools(), ...toActivate])]);
      }

      const lines = top.map(
        (m) => `- ${m.name}${activeSet.has(m.name) ? " (already active)" : toActivate.includes(m.name) ? " [activated]" : ""}: ${m.desc}`,
      );
      return {
        content: [{
          type: "text",
          text: `Matched tools:\n${lines.join("\n")}\nActivated now: ${toActivate.length > 0 ? toActivate.join(", ") : "(none — all matches were already active)"}. Activated tools are available from the next turn.`,
        }],
        details: { matches: top, activated: toActivate },
      };
    },
  });

  pi.on("session_start", () => {
    const allNames = pi.getAllTools().map((t) => t.name);
    seedLinearSettings(allNames);

    // Run the filter on a macrotask so it executes AFTER every other extension's
    // synchronous session_start handlers. Several extensions force-re-add their own
    // tools in their own session_start handlers (pi-background-tasks for bg_*/fusion_*
    // via delegate-extension.ts, pi-dynamic-workflows for workflow*); running last
    // makes this filter the final word on the startup active set. The first API
    // request happens well after this macrotask fires.
    setTimeout(() => {
      const names = pi.getAllTools().map((t) => t.name);
      const eager = readOverride();
      const lazyNames = new Set(
        names.filter((n) => isLazyName(n) && !eager.some((p) => n.startsWith(p))),
      );
      if (lazyNames.size === 0) return;

      const initial = pi.getActiveTools().filter((name) => !lazyNames.has(name));
      pi.setActiveTools([...new Set([...initial, "search_tools"])]);
      console.error(`[lazy-tools] deferred ${lazyNames.size} tools to search_tools (eager overrides: ${eager.join(", ") || "none"})`);
    }, 0);
  });
}
