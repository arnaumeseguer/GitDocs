# GitDocs

Auto-generate professional READMEs for GitHub repositories using AI (Gemini, Grok, or Claude).

---

## Architecture: Strategy Pattern for LLM Integration

GitDocs implements the **Strategy Pattern** to abstract different AI service integrations. This design allows seamless switching between LLMs without modifying client code.

### Design Overview

```
┌─────────────────────────────────────────────────────────┐
│              LLMContext (Strategy Context)              │
│  - Delegates generation requests to active strategy    │
└────────┬──────────────────────────────────────────────┘
         │
         ├─→ ┌──────────────────────┐
         │   │  LLMStrategy (ABC)   │
         │   │  Interface defining  │
         │   │  generate(prompt)    │
         │   └──────────────────────┘
         │
         ├─→ Concrete Implementations:
         │
         ├─→ ┌──────────────────────┐
         │   │ GeminiStrategy       │
         │   │ - Model: Gemini 2.5  │
         │   │ - Client: Google API │
         │   └──────────────────────┘
         │
         ├─→ ┌──────────────────────┐
         │   │ GrokStrategy         │
         │   │ - Model: Grok-3      │
         │   │ - Client: xAI API    │
         │   └──────────────────────┘
         │
         └─→ ┌──────────────────────┐
             │ ClaudeStrategy       │
             │ - Model: Claude 3.5  │
             │ - Client: Anthropic  │
             └──────────────────────┘
```

### Key Components

**1. Base Strategy** (`backend/strategies/base.py`)
- Abstract class `LLMStrategy` defines the `generate(prompt)` method
- `_parse_json_response()` robustly extracts JSON from LLM responses (supports fenced blocks, raw JSON, and inline objects)
- `LLMContext` holds a strategy and delegates calls to it

**2. Concrete Strategies** (`backend/strategies/`)
- **GeminiStrategy**: Calls Google Gemini API via `google.genai` SDK
- **GrokStrategy**: Calls xAI Grok via OpenAI-compatible API endpoint
- **ClaudeStrategy**: Calls Anthropic Claude via official `anthropic` SDK

Each strategy:
- Takes a client instance in `__init__`
- Implements `generate(prompt)` with API-specific call syntax
- Handles errors gracefully (missing API keys → 503, parse errors → 500)

**3. Request Flow**
```
Frontend (Dart)
    ↓
/api/generate (FastAPI endpoint)
    ↓
GenerateRequest (ai_model: "gemini"|"grok"|"claude")
    ↓
Select Strategy from registry _strategies
    ↓
LLMContext.generate(prompt)
    ↓
Strategy.generate() → API call
    ↓
JSON parse + return
    ↓
Frontend displays title, description, features, tech_stack
```

### Configuration

Add API keys to `.env`:
```bash
GEMINI_API_KEY=your_key_here
GROK_API_KEY=your_key_here
ANTHROPIC_API_KEY=your_key_here
```

Missing keys result in a **503 Service Unavailable** response.

### Frontend Integration

- **NewReadmeScreen** (`frontend/lib/screens/new_readme_screen.dart`): Allows users to select `aiModel` (gemini, grok, claude)
- **ApiService** calls `/api/generate` with selected model
- **ResultScreen** displays parsed response fields: `title`, `description`, `key_features`, `tech_stack`, `complexity`

### Why Strategy Pattern?

✅ **Loose Coupling**: Adding a new LLM only requires a new Strategy class  
✅ **Runtime Selection**: Users pick the model at runtime  
✅ **Single Responsibility**: Each strategy handles one API  
✅ **Error Isolation**: Strategy-specific errors don't crash the app  
✅ **Testability**: Mock strategies for unit tests  

---

## License / Llicència

This project is published under the [PolyForm Noncommercial License 1.0.0](LICENSE).

- ✅ Allowed: Personal use, academic work, research, NGOs, public institutions.
- ❌ Not allowed: Commercial use (requires prior agreement with the author).

Aquest projecte es publica sota la [llicència PolyForm Noncommercial 1.0.0](LICENSE).

- ✅ Permès: ús personal, acadèmic, recerca, ONGs i institucions públiques.
- ❌ No permès: ús comercial (requereix acord previ amb l'autor).

Commercial licenses / llicències comercials: arnaumeseguer2005@gmail.com
