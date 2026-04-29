from abc import ABC, abstractmethod
import json
import re
from fastapi import HTTPException


class LLMStrategy(ABC):
    """Strategy interface for LLM services."""

    @abstractmethod
    def generate(self, prompt: str) -> dict:
        pass

    def _parse_json_response(self, text: str) -> dict:
        """Extract and parse a JSON object from an LLM response string."""
        # 1. JSON fenced code block
        match = re.search(r"```json\s*(.*?)\s*```", text, re.DOTALL)
        if match:
            try:
                return json.loads(match.group(1))
            except json.JSONDecodeError:
                pass

        # 2. Raw JSON
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            pass

        # 3. First {...} block found in the text
        match = re.search(r"\{.*\}", text, re.DOTALL)
        if match:
            try:
                return json.loads(match.group(0))
            except json.JSONDecodeError:
                pass

        raise HTTPException(
            status_code=500,
            detail="La IA no ha retornat una resposta JSON vàlida.",
        )


class LLMContext:
    """Context that delegates generation to the active strategy."""

    def __init__(self, strategy: LLMStrategy):
        self._strategy = strategy

    def set_strategy(self, strategy: LLMStrategy) -> None:
        self._strategy = strategy

    def generate(self, prompt: str) -> dict:
        return self._strategy.generate(prompt)
