import asyncio
import json
from unittest.mock import MagicMock, patch

from mcp_server.router import route_task


def test_route_task_success():
    mock_choice = MagicMock()
    mock_choice.message.content = json.dumps(
        {
            "persona": "python_developer",
            "context": "Needs pytest setup",
            "steps": ["Write tests", "Run pytest"],
        }
    )
    mock_response = MagicMock()
    mock_response.choices = [mock_choice]

    with patch("litellm.completion", return_value=mock_response) as mock_litellm:
        result = asyncio.run(route_task("Fix CI tests for python"))
        assert mock_litellm.called
        parsed = json.loads(result)
        assert parsed["persona"] == "python_developer"
        assert len(parsed["steps"]) == 2


def test_route_task_exception():
    with patch("litellm.completion", side_effect=Exception("API Error")):
        result = asyncio.run(route_task("Fix CI tests for python"))
        parsed = json.loads(result)
        assert "error" in parsed
        assert "Failed to generate execution plan: API Error" in parsed["error"]
