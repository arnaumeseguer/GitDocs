from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from google import genai as google_genai
from openai import OpenAI
import anthropic
import os
import requests
from dotenv import load_dotenv

from strategies import GeminiStrategy, GrokStrategy, ClaudeStrategy
from strategies.base import LLMContext

load_dotenv()

app = FastAPI(title="GitDocs API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

gemini_key = os.environ.get("GEMINI_API_KEY", "")
grok_key = os.environ.get("GROK_API_KEY", "")
anthropic_key = os.environ.get("ANTHROPIC_API_KEY", "")
github_token = os.environ.get("GITHUB_TOKEN", "")

gemini_client = google_genai.Client(api_key=gemini_key) if gemini_key else None
grok_client = (
    OpenAI(api_key=grok_key, base_url="https://api.x.ai/v1") if grok_key else None
)
anthropic_client = anthropic.Anthropic(api_key=anthropic_key) if anthropic_key else None

# ── Strategy instances ─────────────────────────────────────────────────────────

_strategies = {
    "gemini": GeminiStrategy(gemini_client),
    "grok": GrokStrategy(grok_client),
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
    ai_model: str = "gemini"


@app.post("/api/generate")
async def generate(req: GenerateRequest):
    strategy = _strategies.get(req.ai_model)
    if strategy is None:
        raise HTTPException(
            status_code=400,
            detail=f"Model desconegut: '{req.ai_model}'. Usa 'gemini', 'grok' o 'claude'.",
        )

    ctx = LLMContext(strategy)
    result = ctx.generate(req.prompt)

    # Ensure the 'readme' key is always present
    if "readme" not in result:
        raise HTTPException(
            status_code=500,
            detail="La resposta de la IA no conté el camp 'readme'.",
        )

    return result


@app.get("/")
async def root():
    return {"message": "GitDocs API running", "status": "ok"}


@app.get("/health")
async def health():
    return {
        "status": "ok",
        "github_token": bool(github_token),
        "gemini_key": bool(gemini_key),
        "grok_key": bool(grok_key),
        "anthropic_key": bool(anthropic_key),
    }
