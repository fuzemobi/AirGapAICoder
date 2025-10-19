"""Server management commands"""

import click


@click.group()
def server():
    """Manage Ollama server"""
    pass


@server.command()
def status():
    """Check server status"""
    click.echo("Server status command - Coming soon in v1.1.0")


@server.command()
def start():
    """Start Ollama server"""
    click.echo("Server start command - Coming soon in v1.1.0")


@server.command()
def stop():
    """Stop Ollama server"""
    click.echo("Server stop command - Coming soon in v1.1.0")
