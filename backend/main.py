from fastapi import FastAPI, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from google import genai as google_genai
from groq import Groq
import anthropic
import json
import os
import requests
import re
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="GitDocs API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

gemini_key = os.environ.get("GEMINI_API_KEY", "")
groq_key = os.environ.get("GROQ_API_KEY", "")
anthropic_key = os.environ.get("ANTHROPIC_API_KEY", "")
github_token = os.environ.get("GITHUB_TOKEN", "")

gemini_client = google_genai.Client(api_key=gemini_key) if gemini_key else None
groq_client = Groq(api_key=groq_key) if groq_key else None
anthropic_client = anthropic.Anthropic(api_key=anthropic_key) if anthropic_key else None


def _parse_json_response(text: str) -> dict:
    """Extract and parse a JSON object from an LLM response string."""
    match = re.search(r"```json\s*(.*?)\s*```", text, re.DOTALL)
    if match:
        try:
            return json.loads(match.group(1))
        except json.JSONDecodeError:
            pass

    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass

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


class GeminiStrategy:
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
            return _parse_json_response(response.text)
        except HTTPException:
            raise
        except Exception as exc:
            raise HTTPException(
                status_code=500,
                detail=f"Error de Gemini: {exc}",
            ) from exc


class GroqStrategy:
    MODEL = "openai/gpt-oss-120b"

    def __init__(self, client):
        self._client = client

    def generate(self, prompt: str) -> dict:
        if not self._client:
            raise HTTPException(
                status_code=503,
                detail="GROQ_API_KEY no configurat al servidor.",
            )
        try:
            completion = self._client.chat.completions.create(
                model=self.MODEL,
                messages=[{"role": "user", "content": prompt}],
                temperature=1,
                max_completion_tokens=8192,
                top_p=1,
                reasoning_effort="medium",
                stream=True,
                stop=None,
            )

            content_parts = []

            # completion may be an iterator (stream) yielding dict-like or attr objects,
            # or a single response object. Be defensive when extracting text.
            try:
                for chunk in completion:
                    part = ""
                    # dict-like chunk
                    if isinstance(chunk, dict):
                        try:
                            ch = chunk.get("choices", [])
                            if ch:
                                delta = ch[0].get("delta")
                                if isinstance(delta, dict):
                                    part = delta.get("content") or ""
                                else:
                                    part = ch[0].get("text") or ch[0].get("message", {}).get("content", "")
                            else:
                                part = chunk.get("text") or ""
                        except Exception:
                            part = ""
                    else:
                        # object-like chunk
                        try:
                            # try attribute access (choices[0].delta.content)
                            part = getattr(getattr(chunk.choices[0], "delta", None), "content", None) or getattr(chunk.choices[0], "text", "") or ""
                        except Exception:
                            part = ""

                    content_parts.append(part or "")
            except TypeError:
                # Not iterable — perhaps a single response object
                try:
                    if isinstance(completion, dict):
                        # non-stream dict
                        if "choices" in completion and completion["choices"]:
                            # try common shapes
                            c0 = completion["choices"][0]
                            text = c0.get("message", {}).get("content") or c0.get("text") or ""
                            content_parts.append(text)
                    else:
                        # object with .choices
                        try:
                            text = getattr(getattr(completion.choices[0], "message", None), "content", None) or getattr(completion.choices[0], "text", "")
                            content_parts.append(text or "")
                        except Exception:
                            pass
                except Exception as e:
                    print("Groq: unable to extract text from non-iterable completion:", e)

            joined = "".join(content_parts)
            # attempt to parse JSON block from the joined text; if parsing fails,
            # assume model returned raw README markdown and return it under 'readme'.
            try:
                parsed = _parse_json_response(joined)
                return parsed
            except HTTPException:
                return {"readme": joined}
        except HTTPException:
            raise
        except Exception as exc:
            print("GroqStrategy.generate error:", exc)
            raise HTTPException(
                status_code=500,
                detail=f"Error de Groq: {exc}",
            ) from exc


class ClaudeStrategy:
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
            return _parse_json_response(response.content[0].text)
        except HTTPException:
            raise
        except Exception as exc:
            raise HTTPException(
                status_code=500,
                detail=f"Error de Claude: {exc}",
            ) from exc


_strategies = {
    "gemini": GeminiStrategy(gemini_client),
    "groq": GroqStrategy(groq_client),
    # backwards-compatible alias: some deployments or clients used "grok"
    "grok": GroqStrategy(groq_client),
    "claude": ClaudeStrategy(anthropic_client),
}

GITHUB_HEADERS = {
    "Accept": "application/vnd.github+json",
    **({"Authorization": f"Bearer {github_token}"} if github_token else {}),
}


def github_get(path: str):
    res = requests.get(f"https://api.github.com{path}", headers=GITHUB_HEADERS)
    if res.status_code == 404:
        raise HTTPException(
            status_code=404, detail="Repositorio no encontrado o privado."
        )
    if res.status_code in (403, 429):
        raise HTTPException(status_code=429, detail="Límit de GitHub API superat.")
    if res.status_code != 200:
        raise HTTPException(
            status_code=res.status_code, detail=f"GitHub API error {res.status_code}"
        )
    return res.json()


# ── GitHub proxy endpoints ─────────────────────────────────────────────────────


@app.get("/github/repo/{owner}/{repo}")
async def get_repo(owner: str, repo: str):
    return github_get(f"/repos/{owner}/{repo}")


@app.get("/github/repo/{owner}/{repo}/languages")
async def get_languages(owner: str, repo: str):
    try:
        return github_get(f"/repos/{owner}/{repo}/languages")
    except Exception:
        return {}


@app.get("/github/repo/{owner}/{repo}/contents")
async def get_contents(owner: str, repo: str):
    try:
        return github_get(f"/repos/{owner}/{repo}/contents")
    except Exception:
        return []


@app.get("/github/repo/{owner}/{repo}/readme")
async def get_readme(owner: str, repo: str):
    try:
        return github_get(f"/repos/{owner}/{repo}/readme")
    except Exception:
        return {}


# ── Generate endpoint ──────────────────────────────────────────────────────────


class GenerateRequest(BaseModel):
    prompt: str
    repoData: dict = {}
    langData: dict = {}
    settings: dict = {}
    ai_model: str = "groq"


@app.post("/api/generate")
async def generate(req: GenerateRequest):
    strategy = _strategies.get(req.ai_model)
    if strategy is None:
        raise HTTPException(
            status_code=400,
            detail=(
                f"Model desconegut: '{req.ai_model}'. Usa 'gemini', 'groq' (o 'grok') o 'claude'."
            ),
        )

    result = strategy.generate(req.prompt)

    # Ensure the 'readme' key is always present
    if "readme" not in result:
        raise HTTPException(
            status_code=500,
            detail="La resposta de la IA no conté el camp 'readme'.",
        )

    # Always return raw README markdown (text/markdown)
    if "readme" not in result:
        raise HTTPException(
            status_code=500,
            detail="La resposta de la IA no conté el camp 'readme'.",
        )

    readme_text = result.get("readme", "")
    return Response(
        content=readme_text,
        media_type="text/markdown",
        headers={"Content-Disposition": "attachment; filename=README.md"},
    )


@app.get("/")
async def root():
    return {"message": "GitDocs API running", "status": "ok"}


@app.get("/health")
async def health():
    return {
        "status": "ok",
        "github_token": bool(github_token),
        "gemini_key": bool(gemini_key),
        "groq_key": bool(groq_key),
        "anthropic_key": bool(anthropic_key),
    }
