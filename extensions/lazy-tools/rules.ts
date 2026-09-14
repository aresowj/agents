export interface LazyToolsConfig {
  eager?: string[];
  lazy?: string[];
}

const DEFAULT_LAZY_EXACT = new Set([
  "subagent",
  "mcp",
  "mcpScript",
  "web_search",
  "source_check",
  "fetch_content",
  "get_search_content",
]);

const DEFAULT_LAZY_PREFIXES = ["linear_", "bg_", "fusion_"];

export function unique(values: string[]): string[] {
  return [...new Set(values.filter(Boolean))];
}

export function matchesRule(name: string, rule: string): boolean {
  return name === rule || name.startsWith(rule);
}

export function deferredToolNames(names: string[], config: Required<LazyToolsConfig>): Set<string> {
  return new Set(
    names.filter((name) => {
      const lazy = DEFAULT_LAZY_EXACT.has(name)
        || DEFAULT_LAZY_PREFIXES.some((prefix) => name.startsWith(prefix))
        || config.lazy.some((rule) => matchesRule(name, rule));
      return lazy && !config.eager.some((rule) => matchesRule(name, rule));
    }),
  );
}
