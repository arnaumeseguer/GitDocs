from fastapi import HTTPException
from .base import LLMStrategy


class ClaudeStrategy(LLMStrategy):
    """Concrete strategy that calls the Anthropic Claude API."""

    MODEL = "claude-haiku-4-5"

    def __init__(self, client):
        self._client = client

    def generate(self, prompt: str) -> dict:
        if not self._client:
            raise HTTPException(
                status_code=503,
                detail="ANTHROPIC_API_KEY no configurat al servidor.",
            )
        try:
            response = self._client.messages.create(
                model=self.MODEL,
                max_tokens=4096,
                messages=[{"role": "user", "content": prompt}],
            )
            return self._parse_json_response(response.content[0].text)
        except HTTPException:
            raise
        except Exception as exc:
            raise HTTPException(
                status_code=500,
                detail=f"Error de Claude: {exc}",
            ) from exc
