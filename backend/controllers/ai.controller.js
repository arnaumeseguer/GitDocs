import { sendChat } from '../services/ai.service.js';

export async function chat(req, res) {
  const { messages, apiKey, provider, model } = req.body;

  if (!apiKey)        return res.status(400).json({ error: 'API key required' });
  if (!messages?.length) return res.status(400).json({ error: 'messages[] required' });

  try {
    const content = await sendChat({ messages, apiKey, provider, model });
    res.json({ content });
  } catch (err) {
    res.status(502).json({ error: err.message });
  }
}
