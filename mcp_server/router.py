import json

import litellm


async def route_task(task_description: str) -> str:
    """
    Uses litellm to evaluate the task and generate a JSON Execution Plan.
    """
    system_prompt = """
You are the Supervisor Agent for an agent workflow framework.
Your job is to read a task description and output a JSON execution plan for a specialized subagent.
The JSON must have the following schema:
{
    "persona": "python_developer" | "go_developer" | "qa_engineer" | "devops",
    "context": "Context or files needed for the task",
    "steps": ["Step 1", "Step 2", "Step 3"]
}
Only output valid JSON. No markdown wrapping.
"""
    try:
        response = litellm.completion(
            model="gpt-4o",  # Defaulting to an OpenAI model, but user can configure litellm
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": task_description},
            ],
            response_format={"type": "json_object"},
        )
        content = response.choices[0].message.content
        # Validate it's JSON
        json.loads(content)
        return content
    except Exception as e:
        return json.dumps({"error": f"Failed to generate execution plan: {str(e)}"})
