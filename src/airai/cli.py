"""
AirAI CLI - Main command-line interface
"""

import click
from rich.console import Console

from airai import __version__
from airai.commands import chat_cmd, code, health, models_cmd, server

console = Console()


@click.group()
@click.version_option(version=__version__, prog_name="airai")
@click.option(
    "--config",
    type=click.Path(exists=True),
    help="Path to configuration file",
    envvar="AIRAI_CONFIG",
)
@click.option(
    "--remote",
    default="localhost:11434",
    help="Remote Ollama server (HOST:PORT)",
    envvar="OLLAMA_HOST",
)
@click.pass_context
def cli(ctx, config, remote):
    """
    AirAI - Enterprise air-gapped AI coding assistant CLI

    Manage and interact with Ollama AI servers in air-gapped environments.
    """
    ctx.ensure_object(dict)
    ctx.obj["config"] = config
    ctx.obj["remote"] = remote
    ctx.obj["console"] = console


# Register command groups
cli.add_command(server.server)
cli.add_command(models_cmd.models)
cli.add_command(chat_cmd.chat)
cli.add_command(chat_cmd.ask)
cli.add_command(health.health)
cli.add_command(code.code)  # NEW: Code assistance commands


def main():
    """Main entry point for CLI"""
    cli(obj={})


if __name__ == "__main__":
    main()
