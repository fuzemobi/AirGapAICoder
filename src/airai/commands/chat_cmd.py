"""Chat and generation commands"""

import click
from rich.console import Console
from airai.api.client import OllamaClient


@click.command()
@click.argument("model")
@click.option("--prompt", "-p", help="Prompt text")
@click.pass_context
def chat(ctx, model, prompt):
    """Chat with an AI model"""
    console = ctx.obj["console"]
    remote = ctx.obj["remote"]
    
    if not prompt:
        prompt = click.prompt("Prompt")
    
    client = OllamaClient(f"http://{remote}")
    
    with console.status(f"[bold green]Generating response from {model}..."):
        response = client.generate(model, prompt)
    
    console.print("\n[bold cyan]Response:[/bold cyan]")
    console.print(response.get("response", "No response"))


@click.command()
@click.argument("model")
@click.argument("question")
@click.pass_context
def ask(ctx, model, question):
    """Quick question to AI model (alias for chat)"""
    ctx.invoke(chat, model=model, prompt=question)
