from fastapi import HTTPException
from .base import LLMStrategy


class GrokStrategy(LLMStrategy):
    """Concrete strategy that calls the xAI Grok API."""

    MODEL = "grok-3"

    def __init__(self, client):
        self._client = client

    def generate(self, prompt: str) -> dict:
        if not self._client:
            raise HTTPException(
                status_code=503,
                detail="GROK_API_KEY no configurat al servidor.",
            )
        try:
            response = self._client.chat.completions.create(
                model=self.MODEL,
                messages=[{"role": "user", "content": prompt}],
            )
            return self._parse_json_response(response.choices[0].message.content)
        except HTTPException:
            raise
        except Exception as exc:
            raise HTTPException(
                status_code=500,
                detail=f"Error de Grok: {exc}",
            ) from exc
