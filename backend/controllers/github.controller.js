import { fetchRepo } from '../services/github.service.js';

export async function getRepo(req, res) {
  const { owner, repo, token } = req.body;

  if (!owner || !repo) return res.status(400).json({ error: 'owner and repo are required' });

  try {
    const data = await fetchRepo({ owner, repo, token });
    res.json(data);
  } catch (err) {
    res.status(502).json({ error: err.message });
  }
}
