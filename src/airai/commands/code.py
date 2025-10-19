"""AI-assisted code commands"""

import click
from rich.console import Console
from rich.syntax import Syntax
from rich.panel import Panel
from airai.api.client import OllamaClient
import os


@click.group(name="code")
def code():
    """AI-assisted coding operations"""
    pass


@code.command()
@click.argument("file_path", type=click.Path(exists=True))
@click.option("--instructions", "-i", help="Editing instructions")
@click.option("--model", "-m", default="qwen-32b-cline", help="Model to use")
@click.pass_context
def edit(ctx, file_path, instructions, model):
    """AI-assisted file editing
    
    Example:
        airai code edit app.py "refactor to use async/await"
        airai code edit --instructions "add error handling" server.py
    """
    console = ctx.obj["console"]
    remote = ctx.obj["remote"]
    
    if not instructions:
        instructions = click.prompt("Editing instructions")
    
    # Read file
    with open(file_path, 'r') as f:
        original_content = f.read()
    
    console.print(f"\n[cyan]Editing:[/cyan] {file_path}")
    console.print(f"[cyan]Instructions:[/cyan] {instructions}\n")
    
    # Build prompt
    prompt = f"""You are a code editing assistant. 
    
File: {file_path}
Original content:
```
{original_content}
```

Instructions: {instructions}

Please provide the complete edited file content. Include all necessary imports and maintain code style.
Output ONLY the code, no explanations."""

    client = OllamaClient(f"http://{remote}")
    
    with console.status(f"[bold green]Editing with {model}..."):
        response = client.generate(model, prompt, temperature=0.2)
    
    edited_content = response.get("response", "").strip()
    
    # Remove markdown code blocks if present
    if edited_content.startswith("```"):
        lines = edited_content.split("\n")
        edited_content = "\n".join(lines[1:-1])
    
    # Show diff
    console.print("\n[bold cyan]Edited Code:[/bold cyan]")
    syntax = Syntax(edited_content, get_language(file_path), theme="monokai", line_numbers=True)
    console.print(syntax)
    
    # Confirm before writing
    if click.confirm("\nApply these changes?", default=True):
        # Backup original
        backup_path = f"{file_path}.bak"
        with open(backup_path, 'w') as f:
            f.write(original_content)
        
        # Write edited
        with open(file_path, 'w') as f:
            f.write(edited_content)
        
        console.print(f"[green]✓[/green] Changes applied to {file_path}")
        console.print(f"[dim]Backup saved to {backup_path}[/dim]")
    else:
        console.print("[yellow]Changes discarded[/yellow]")


@code.command()
@click.argument("path", type=click.Path(exists=True))
@click.option("--model", "-m", default="qwen-32b-cline", help="Model to use")
@click.pass_context
def review(ctx, path, model):
    """AI code review
    
    Example:
        airai code review src/app.py
        airai code review src/
    """
    console = ctx.obj["console"]
    remote = ctx.obj["remote"]
    
    files_to_review = []
    
    if os.path.isfile(path):
        files_to_review.append(path)
    else:
        # Review all Python files in directory
        for root, dirs, files in os.walk(path):
            for file in files:
                if file.endswith(('.py', '.js', '.ts', '.java', '.go', '.rs')):
                    files_to_review.append(os.path.join(root, file))
    
    console.print(f"\n[cyan]Reviewing {len(files_to_review)} file(s)...[/cyan]\n")
    
    client = OllamaClient(f"http://{remote}")
    
    for file_path in files_to_review:
        with open(file_path, 'r') as f:
            content = f.read()
        
        prompt = f"""Review this code for:
- Bugs and potential issues
- Security vulnerabilities
- Performance problems
- Code quality and maintainability
- Best practices

File: {file_path}
```
{content}
```

Provide a concise review with actionable suggestions."""

        with console.status(f"[bold green]Reviewing {file_path}..."):
            response = client.generate(model, prompt, temperature=0.3)
        
        review_text = response.get("response", "No review available")
        
        panel = Panel(
            review_text,
            title=f"[bold cyan]Review: {file_path}[/bold cyan]",
            border_style="cyan"
        )
        console.print(panel)
        console.print()


@code.command()
@click.argument("file_path", type=click.Path(exists=True))
@click.option("--model", "-m", default="deepseek-r1-32b-cline", help="Model to use")
@click.pass_context
def fix(ctx, file_path, model):
    """AI-guided bug fixing
    
    Example:
        airai code fix buggy_module.py
    """
    console = ctx.obj["console"]
    remote = ctx.obj["remote"]
    
    with open(file_path, 'r') as f:
        content = f.read()
    
    console.print(f"\n[cyan]Analyzing:[/cyan] {file_path}\n")
    
    prompt = f"""Analyze this code for bugs and provide fixes:

File: {file_path}
```
{content}
```

1. Identify bugs and issues
2. Explain each problem
3. Provide the corrected code

Output format:
## Issues Found
[list issues]

## Corrected Code
```
[complete corrected code]
```
"""

    client = OllamaClient(f"http://{remote}")
    
    with console.status(f"[bold green]Analyzing with {model}..."):
        response = client.generate(model, prompt, temperature=0.2)
    
    analysis = response.get("response", "")
    
    console.print("[bold cyan]Analysis & Fixes:[/bold cyan]")
    console.print(analysis)
    
    # Extract fixed code if present
    if "```" in analysis:
        if click.confirm("\nApply suggested fixes?", default=False):
            # Simple extraction - in production, use proper parsing
            lines = analysis.split("```")
            if len(lines) >= 3:
                fixed_code = lines[-2].strip()
                
                # Backup and write
                backup_path = f"{file_path}.bak"
                with open(backup_path, 'w') as f:
                    f.write(content)
                
                with open(file_path, 'w') as f:
                    f.write(fixed_code)
                
                console.print(f"[green]✓[/green] Fixes applied to {file_path}")
                console.print(f"[dim]Backup saved to {backup_path}[/dim]")


@code.command()
@click.argument("file_path", type=click.Path(exists=True))
@click.option("--model", "-m", default="qwen-32b-cline", help="Model to use")
@click.option("--framework", "-f", default="pytest", help="Test framework")
@click.pass_context
def test(ctx, file_path, model, framework):
    """Generate tests for code
    
    Example:
        airai code test src/calculator.py
        airai code test src/api.py --framework unittest
    """
    console = ctx.obj["console"]
    remote = ctx.obj["remote"]
    
    with open(file_path, 'r') as f:
        content = f.read()
    
    console.print(f"\n[cyan]Generating tests for:[/cyan] {file_path}")
    console.print(f"[cyan]Framework:[/cyan] {framework}\n")
    
    prompt = f"""Generate comprehensive unit tests for this code using {framework}:

File: {file_path}
```
{content}
```

Requirements:
- Use {framework} framework
- Test happy paths and edge cases
- Include fixtures if needed
- Add docstrings
- Cover error handling

Provide complete, runnable test code."""

    client = OllamaClient(f"http://{remote}")
    
    with console.status(f"[bold green]Generating tests with {model}..."):
        response = client.generate(model, prompt, temperature=0.3)
    
    test_code = response.get("response", "").strip()
    
    # Remove markdown if present
    if test_code.startswith("```"):
        lines = test_code.split("\n")
        test_code = "\n".join(lines[1:-1])
    
    # Show generated tests
    console.print("\n[bold cyan]Generated Tests:[/bold cyan]")
    syntax = Syntax(test_code, "python", theme="monokai", line_numbers=True)
    console.print(syntax)
    
    # Suggest test file name
    test_file = file_path.replace(".py", "_test.py")
    if not test_file.startswith("test_"):
        test_file = f"test_{os.path.basename(file_path)}"
    
    if click.confirm(f"\nSave tests to {test_file}?", default=True):
        with open(test_file, 'w') as f:
            f.write(test_code)
        console.print(f"[green]✓[/green] Tests saved to {test_file}")


def get_language(file_path):
    """Detect language from file extension"""
    ext = os.path.splitext(file_path)[1]
    mapping = {
        '.py': 'python',
        '.js': 'javascript',
        '.ts': 'typescript',
        '.java': 'java',
        '.go': 'go',
        '.rs': 'rust',
        '.cpp': 'cpp',
        '.c': 'c',
        '.sh': 'bash',
    }
    return mapping.get(ext, 'text')
