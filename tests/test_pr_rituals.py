import asyncio
import subprocess
from unittest.mock import MagicMock, patch

from mcp_server.pr_rituals import prepare_pr


def test_prepare_pr_precommit_failure():
    mock_hook = MagicMock(spec=subprocess.CompletedProcess)
    mock_hook.returncode = 1
    mock_hook.stdout = "Failed linting"
    mock_hook.stderr = "Errors found"

    with patch("subprocess.run", return_value=mock_hook):
        res = asyncio.run(prepare_pr())
        assert "Pre-commit hooks failed" in res
        assert "Failed linting" in res


def test_prepare_pr_no_commits():
    mock_hook = MagicMock(returncode=0, stdout="", stderr="")
    mock_log = MagicMock(returncode=0, stdout="", stderr="")

    with patch("subprocess.run", side_effect=[mock_hook, mock_log]):
        res = asyncio.run(prepare_pr())
        assert res == "No unpushed commits found to create a PR."


def test_prepare_pr_success():
    mock_hook = MagicMock(returncode=0, stdout="", stderr="")
    mock_log = MagicMock(returncode=0, stdout="feat: new feature\n", stderr="")
    mock_pr = MagicMock(returncode=0, stdout="https://github.com/org/repo/pull/1", stderr="")

    mock_choice = MagicMock()
    mock_choice.message.content = (
        "TITLE: feat: add new feature\nDESCRIPTION:\nDetailed PR description"
    )
    mock_llm_response = MagicMock(choices=[mock_choice])

    with patch("subprocess.run", side_effect=[mock_hook, mock_log, mock_pr]), patch(
        "litellm.completion", return_value=mock_llm_response
    ):
        res = asyncio.run(prepare_pr("main"))
        assert "Successfully created PR" in res
        assert "https://github.com/org/repo/pull/1" in res


def test_prepare_pr_gh_failure():
    mock_hook = MagicMock(returncode=0, stdout="", stderr="")
    mock_log = MagicMock(returncode=0, stdout="feat: new feature\n", stderr="")
    mock_pr = MagicMock(
        returncode=1,
        stdout="",
        stderr="GraphQL error: pull request already exists",
    )

    mock_choice = MagicMock()
    mock_choice.message.content = (
        "TITLE: feat: add new feature\nDESCRIPTION:\nDetailed PR description"
    )
    mock_llm_response = MagicMock(choices=[mock_choice])

    with patch("subprocess.run", side_effect=[mock_hook, mock_log, mock_pr]), patch(
        "litellm.completion", return_value=mock_llm_response
    ):
        res = asyncio.run(prepare_pr("main"))
        assert "Failed to create PR using gh CLI" in res
        assert "GraphQL error" in res


def test_prepare_pr_exception():
    mock_hook = MagicMock(returncode=0, stdout="", stderr="")
    mock_log = MagicMock(returncode=0, stdout="feat: new feature\n", stderr="")

    with patch("subprocess.run", side_effect=[mock_hook, mock_log]), patch(
        "litellm.completion", side_effect=Exception("OpenAI quota exceeded")
    ):
        res = asyncio.run(prepare_pr("main"))
        assert "Error during PR generation: OpenAI quota exceeded" in res
