"""Models management commands"""

import click
from rich.console import Console
from rich.table import Table
from airai.api.client import OllamaClient


@click.group(name="models")
def models():
    """Manage AI models"""
    pass


@models.command()
@click.pass_context
def list(ctx):
    """List available models"""
    console = ctx.obj["console"]
    remote = ctx.obj["remote"]
    
    client = OllamaClient(f"http://{remote}")
    
    with console.status("[bold green]Fetching models..."):
        models_list = client.list_models()
    
    if not models_list:
        console.print("[yellow]No models found[/yellow]")
        return
    
    table = Table(title=f"Models on {remote}")
    table.add_column("Name", style="cyan")
    table.add_column("Size", style="magenta")
    table.add_column("Modified", style="green")
    
    for model in models_list:
        name = model.get("name", "unknown")
        size = f"{model.get('size', 0) / 1e9:.1f}GB"
        modified = model.get("modified_at", "unknown")[:10]
        table.add_row(name, size, modified)
    
    console.print(table)
