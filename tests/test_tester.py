import asyncio
import os
from unittest.mock import MagicMock, patch

from mcp_server.tester import generate_tests_for_coverage


def test_generate_tests_file_not_found():
    res = asyncio.run(generate_tests_for_coverage("nonexistent_file.py", "python"))
    assert res == "Error: File nonexistent_file.py does not exist."


def test_generate_tests_python(tmp_path):
    src_file = tmp_path / "module.py"
    src_file.write_text("def add(a, b): return a + b\n")

    mock_choice = MagicMock()
    mock_choice.message.content = "def test_add(): assert add(1, 2) == 3\n"
    mock_llm_response = MagicMock(choices=[mock_choice])

    with patch("litellm.completion", return_value=mock_llm_response), patch(
        "subprocess.run"
    ) as mock_subproc, patch("os.makedirs"), patch("builtins.open", create=True):
        res = asyncio.run(generate_tests_for_coverage(str(src_file), "python"))
        expected_test_path = os.path.join("tests", "test_module.py")
        assert f"Successfully generated tests and saved to {expected_test_path}" in res
        mock_subproc.assert_called_once_with(
            ["ruff", "format", expected_test_path], capture_output=True
        )


def test_generate_tests_go(tmp_path):
    src_file = tmp_path / "calc.go"
    src_file.write_text("package main\n")

    mock_choice = MagicMock()
    mock_choice.message.content = "package main\n"
    mock_llm_response = MagicMock(choices=[mock_choice])

    with patch("litellm.completion", return_value=mock_llm_response), patch(
        "subprocess.run"
    ) as mock_subproc, patch("os.makedirs"), patch("builtins.open", create=True):
        res = asyncio.run(generate_tests_for_coverage(str(src_file), "go"))
        expected_test_path = str(tmp_path / "calc_test.go")
        assert f"Successfully generated tests and saved to {expected_test_path}" in res
        mock_subproc.assert_called_once_with(["go", "fmt", expected_test_path], capture_output=True)


def test_generate_tests_unsupported_language(tmp_path):
    src_file = tmp_path / "main.rs"
    src_file.write_text("fn main() {}\n")

    mock_choice = MagicMock()
    mock_choice.message.content = "// test"
    mock_llm_response = MagicMock(choices=[mock_choice])

    with patch("litellm.completion", return_value=mock_llm_response):
        res = asyncio.run(generate_tests_for_coverage(str(src_file), "rust"))
        assert res == "Unsupported language."


def test_generate_tests_exception(tmp_path):
    src_file = tmp_path / "app.py"
    src_file.write_text("x = 1\n")

    with patch("litellm.completion", side_effect=Exception("Model timeout")):
        res = asyncio.run(generate_tests_for_coverage(str(src_file), "python"))
        assert "Failed to generate tests: Model timeout" in res
