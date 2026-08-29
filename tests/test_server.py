import asyncio
from unittest.mock import AsyncMock, patch

from mcp_server.server import generate_tests_for_coverage_tool, prepare_pr_tool, route_task_tool


def test_route_task_tool():
    with patch("mcp_server.server.route_task", new_callable=AsyncMock) as mock_route:
        mock_route.return_value = '{"persona": "qa_engineer"}'
        res = asyncio.run(route_task_tool("Write tests for app"))
        assert res == '{"persona": "qa_engineer"}'
        mock_route.assert_called_once_with("Write tests for app")


def test_generate_tests_for_coverage_tool():
    with patch("mcp_server.server.generate_tests_for_coverage", new_callable=AsyncMock) as mock_gen:
        mock_gen.return_value = "Tests generated"
        res = asyncio.run(generate_tests_for_coverage_tool("main.py", "python"))
        assert res == "Tests generated"
        mock_gen.assert_called_once_with("main.py", "python")


def test_prepare_pr_tool():
    with patch("mcp_server.server.prepare_pr", new_callable=AsyncMock) as mock_pr:
        mock_pr.return_value = "PR created"
        res = asyncio.run(prepare_pr_tool("develop"))
        assert res == "PR created"
        mock_pr.assert_called_once_with("develop")
