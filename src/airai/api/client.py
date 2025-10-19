"""Ollama HTTP API client wrapper"""

from typing import Any, Dict, List, Optional
import requests
from requests.exceptions import ConnectionError, RequestException, Timeout


class OllamaClientError(Exception):
    """Base exception for Ollama client errors"""
    pass


class OllamaClient:
    """HTTP client for Ollama API"""

    def __init__(self, base_url: str = "http://localhost:11434", timeout: int = 300):
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout
        self.session = requests.Session()

    def health_check(self) -> bool:
        """Check if Ollama server is responding"""
        try:
            response = self.session.get(f"{self.base_url}/api/tags", timeout=5)
            return response.status_code == 200
        except (ConnectionError, Timeout, RequestException):
            return False

    def list_models(self) -> List[Dict[str, Any]]:
        """List available models"""
        try:
            response = self.session.get(f"{self.base_url}/api/tags", timeout=self.timeout)
            response.raise_for_status()
            return response.json().get("models", [])
        except RequestException as e:
            raise OllamaClientError(f"Failed to list models: {e}")

    def generate(self, model: str, prompt: str, stream: bool = False, **options) -> Dict[str, Any]:
        """Generate text from model"""
        payload = {"model": model, "prompt": prompt, "stream": stream}
        if options:
            payload["options"] = options
        try:
            response = self.session.post(
                f"{self.base_url}/api/generate",
                json=payload,
                timeout=self.timeout,
                stream=stream,
            )
            response.raise_for_status()
            return response.json() if not stream else {"stream": response.iter_lines()}
        except RequestException as e:
            raise OllamaClientError(f"Failed to generate: {e}")
