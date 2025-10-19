"""
AirAI - Enterprise air-gapped AI coding assistant CLI

Professional command-line interface for managing and interacting with
air-gapped Ollama AI servers.
"""

__version__ = "1.1.0"
__author__ = "Fuzemobi, LLC - Chad Rosenbohm"
__license__ = "MIT"

from airai.api.client import OllamaClient

__all__ = ["OllamaClient", "__version__"]
