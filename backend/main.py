from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from google import genai as google_genai
from openai import OpenAI
import anthropic
import os
import requests
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
grok_key = os.environ.get("GROK_API_KEY", "")
anthropic_key = os.environ.get("ANTHROPIC_API_KEY", "")
github_token = os.environ.get("GITHUB_TOKEN", "")

gemini_client = google_genai.Client(api_key=gemini_key) if gemini_key else None
grok_client = (
    OpenAI(api_key=grok_key, base_url="https://api.x.ai/v1") if grok_key else None
)
anthropic_client = anthropic.Anthropic(api_key=anthropic_key) if anthropic_key else None

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


FALLBACK_ORDER = ["gemini", "grok", "claude"]


def _call_model(model: str, prompt: str) -> str:
    if model == "grok":
        if not grok_client:
            raise RuntimeError("GROK_API_KEY not set")
        response = grok_client.chat.completions.create(
            model="grok-3",
            messages=[{"role": "user", "content": prompt}],
        )
        return response.choices[0].message.content
    elif model == "claude":
        if not anthropic_client:
            raise RuntimeError("ANTHROPIC_API_KEY not set")
        response = anthropic_client.messages.create(
            model="claude-haiku-4-5",
            max_tokens=4096,
            messages=[{"role": "user", "content": prompt}],
        )
        return response.content[0].text
    else:
        if not gemini_client:
            raise RuntimeError("GEMINI_API_KEY not set")
        response = gemini_client.models.generate_content(
            model="gemini-2.5-flash-lite",
            contents=prompt,
        )
        return response.text


class GenerateRequest(BaseModel):
    prompt: str
    repoData: dict = {}
    langData: dict = {}
    settings: dict = {}
    ai_model: str = "gemini"
    no_fallback: bool = False


@app.post("/api/generate")
async def generate(req: GenerateRequest):
    if req.no_fallback:
        try:
            print(f"[generate] trying model={req.ai_model} (no_fallback)")
            readme = _call_model(req.ai_model, req.prompt)
            print(f"[generate] success model={req.ai_model}")
            return {"readme": readme, "model_used": req.ai_model}
        except Exception as e:
            print(f"[generate] model={req.ai_model} failed: {type(e).__name__}: {e}")
            raise HTTPException(status_code=500, detail=str(e))

    order = [req.ai_model] + [m for m in FALLBACK_ORDER if m != req.ai_model]
    last_error: Exception = RuntimeError("No AI model available")
    for model in order:
        try:
            print(f"[generate] trying model={model}")
            readme = _call_model(model, req.prompt)
            print(f"[generate] success model={model}")
            return {"readme": readme, "model_used": model}
        except Exception as e:
            print(f"[generate] model={model} failed: {type(e).__name__}: {e}")
            last_error = e
            continue
    raise HTTPException(status_code=500, detail=str(last_error))


@app.get("/health")
async def health():
    return {
        "status": "ok",
        "github_token": bool(github_token),
        "gemini_key": bool(gemini_key),
        "grok_key": bool(grok_key),
        "anthropic_key": bool(anthropic_key),
    }
