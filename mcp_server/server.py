from mcp.server.mcpserver import MCPServer

from mcp_server.pr_rituals import prepare_pr
from mcp_server.router import route_task
from mcp_server.tester import generate_tests_for_coverage

app = MCPServer("agents-framework")


@app.tool()
async def route_task_tool(task_description: str) -> str:
    """
    Uses LLM Supervisor to route a task to specialized personas and generate a
    JSON Execution Plan.
    """
    return await route_task(task_description)


@app.tool()
async def generate_tests_for_coverage_tool(file_path: str, language: str) -> str:
    """
    Analyzes a file and generates tests to meet the 80% coverage threshold.
    Language must be 'python' or 'go'.
    """
    return await generate_tests_for_coverage(file_path, language)


@app.tool()
async def prepare_pr_tool(base_branch: str = "main") -> str:
    """Prepares and creates a GitHub pull request using the gh CLI, ensuring tests pass."""
    return await prepare_pr(base_branch)


if __name__ == "__main__":
    app.run()
