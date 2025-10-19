"""Health check command"""

import click
from rich.console import Console
from rich.table import Table
from airai.api.client import OllamaClient


@click.command()
@click.pass_context
def health(ctx):
    """Check Ollama server health"""
    console = ctx.obj["console"]
    remote = ctx.obj["remote"]
    
    client = OllamaClient(f"http://{remote}")
    
    with console.status("[bold green]Checking server health..."):
        is_healthy = client.health_check()
    
    if is_healthy:
        console.print(f"[green]✓[/green] Server at {remote} is healthy")
    else:
        console.print(f"[red]✗[/red] Server at {remote} is not responding")
        raise click.Abort()
