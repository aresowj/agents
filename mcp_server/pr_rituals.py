import subprocess

import litellm


async def prepare_pr(base_branch: str = "main") -> str:
    """
    Automates PR rituals:
    - Runs linting and tests locally.
    - Uses litellm to generate a PR description based on unpushed commits.
    - Uses `gh` CLI to create the pull request.
    """

    # 1. Run local checks (pre-commit)
    print("Running local hooks...")
    hook_result = subprocess.run(
        ["pre-commit", "run", "--all-files"], capture_output=True, text=True
    )
    if hook_result.returncode != 0:
        return (
            f"Pre-commit hooks failed. Fix them before creating a PR:\n"
            f"{hook_result.stdout}\n{hook_result.stderr}"
        )

    # 2. Get commit history difference
    log_cmd = ["git", "log", f"origin/{base_branch}..HEAD", "--oneline"]
    log_result = subprocess.run(log_cmd, capture_output=True, text=True)
    commits = log_result.stdout.strip()

    if not commits:
        return "No unpushed commits found to create a PR."

    # 3. Generate PR description using LLM
    system_prompt = """
You are a PR assistant. Given a list of commits, generate a concise, professional
Pull Request title and description.
Output format:
TITLE: <title>
DESCRIPTION:
<description>
"""
    try:
        response = litellm.completion(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"Commits:\n{commits}"},
            ],
        )
        content = response.choices[0].message.content
        lines = content.strip().split("\n")
        title = lines[0].replace("TITLE:", "").strip()
        description = "\n".join(lines[1:]).replace("DESCRIPTION:", "").strip()

        # 4. Use `gh` CLI to create the PR
        pr_cmd = ["gh", "pr", "create", "-B", base_branch, "-t", title, "-b", description]
        pr_result = subprocess.run(pr_cmd, capture_output=True, text=True)

        if pr_result.returncode == 0:
            return f"Successfully created PR:\n{pr_result.stdout}"
        else:
            return f"Failed to create PR using gh CLI:\n{pr_result.stderr}"

    except Exception as e:
        return f"Error during PR generation: {str(e)}"
