const ENDPOINTS = {
  grok:       'https://api.x.ai/v1/chat/completions',
  openai:     'https://api.openai.com/v1/chat/completions',
  openrouter: 'https://openrouter.ai/api/v1/chat/completions',
};

/**
 * Sends a chat request to the configured AI provider.
 * @param {{ messages: object[], apiKey: string, provider: string, model: string }} opts
 * @returns {Promise<string>} The assistant reply text.
 */
export async function sendChat({ messages, apiKey, provider = 'grok', model = 'grok-3-mini' }) {
  const endpoint = ENDPOINTS[provider] ?? ENDPOINTS.grok;

  const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${apiKey}`,
  };

  if (provider === 'openrouter') {
    headers['HTTP-Referer'] = 'http://localhost:3000';
    headers['X-Title']      = 'README Generator AI';
  }

  const res = await fetch(endpoint, {
    method:  'POST',
    headers,
    body: JSON.stringify({ model, messages, temperature: 0.3, max_tokens: 4096 }),
  });

  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err?.error?.message ?? `AI API error: ${res.status} ${res.statusText}`);
  }

  const data = await res.json();
  return data.choices[0].message.content;
}
