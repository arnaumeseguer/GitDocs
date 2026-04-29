from fastapi import HTTPException
from .base import LLMStrategy


class GeminiStrategy(LLMStrategy):
    """Concrete strategy that calls the Google Gemini API."""

    MODEL = "gemini-2.5-flash-lite"

    def __init__(self, client):
        self._client = client

    def generate(self, prompt: str) -> dict:
        if not self._client:
            raise HTTPException(
                status_code=503,
                detail="GEMINI_API_KEY no configurat al servidor.",
            )
        try:
            response = self._client.models.generate_content(
                model=self.MODEL,
                contents=prompt,
            )
            return self._parse_json_response(response.text)
        except HTTPException:
            raise
        except Exception as exc:
            raise HTTPException(
                status_code=500,
                detail=f"Error de Gemini: {exc}",
            ) from exc
