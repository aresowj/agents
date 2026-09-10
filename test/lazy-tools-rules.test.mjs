import assert from "node:assert/strict";
import { deferredToolNames, matchesRule } from "../extensions/lazy-tools/rules.ts";

const tools = ["subagent", "web_search", "linear_list_issues", "workflow", "custom_search"];

assert.equal(matchesRule("linear_list_issues", "linear_"), true);
assert.equal(matchesRule("web_search", "web_"), true);
assert.equal(matchesRule("web_search", "search"), false);

assert.deepEqual(
  [...deferredToolNames(tools, { eager: ["web_search"], lazy: ["custom_"] })].sort(),
  ["custom_search", "linear_list_issues", "subagent"],
);

assert.deepEqual(
  [...deferredToolNames(tools, { eager: ["linear_"], lazy: [] })].sort(),
  ["subagent", "web_search"],
);

console.log("lazy-tools rule tests passed");
