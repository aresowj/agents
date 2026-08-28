import os
import subprocess

import litellm


async def generate_tests_for_coverage(file_path: str, language: str) -> str:
    """
    Analyzes a file, checks coverage, and uses an LLM to generate missing tests.
    """
    if not os.path.exists(file_path):
        return f"Error: File {file_path} does not exist."

    with open(file_path, "r") as f:
        source_code = f.read()

    system_prompt = f"""
You are an expert QA Engineer. Write tests to achieve at least 80% coverage for the provided code.
Language: {language}
Framework: {"pytest" if language == "python" else "testing and github.com/stretchr/testify"}
Output only the test code. No markdown formatting or explanations.
"""

    try:
        response = litellm.completion(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"Source code for {file_path}:\n\n{source_code}"},
            ],
        )
        test_code = response.choices[0].message.content

        # Decide where to save the tests
        if language == "python":
            base_name = os.path.basename(file_path)
            test_file_path = os.path.join("tests", f"test_{base_name}")
        elif language == "go":
            test_file_path = file_path.replace(".go", "_test.go")
        else:
            return "Unsupported language."

        os.makedirs(os.path.dirname(test_file_path), exist_ok=True)
        with open(test_file_path, "w") as f:
            f.write(test_code)

        # Format the test code if possible
        if language == "python":
            subprocess.run(["ruff", "format", test_file_path], capture_output=True)
        elif language == "go":
            subprocess.run(["go", "fmt", test_file_path], capture_output=True)

        return f"Successfully generated tests and saved to {test_file_path}."
    except Exception as e:
        return f"Failed to generate tests: {str(e)}"
