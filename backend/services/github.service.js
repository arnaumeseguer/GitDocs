const PRIORITY_FILES = [
  'package.json', 'pyproject.toml', 'setup.py', 'Cargo.toml', 'go.mod',
  'composer.json', 'Gemfile', 'pom.xml', 'build.gradle', 'requirements.txt',
  'Pipfile', '.env.example', 'Makefile', 'docker-compose.yml', 'Dockerfile',
  'src/index.js', 'src/main.js', 'src/main.ts', 'index.js', 'main.py',
  'app.py', 'main.go', 'src/App.tsx', 'src/App.jsx',
];

const MAX_CONTENT_CHARS = 900;
const MAX_FILES_FETCH   = 8;
const MAX_TREE_DISPLAY  = 60;

/**
 * Fetches repo metadata, file tree, and key file contents from GitHub API.
 * @param {{ owner: string, repo: string, token?: string }} opts
 */
export async function fetchRepo({ owner, repo, token }) {
  const headers = { Accept: 'application/vnd.github+json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const [infoRes, treeRes] = await Promise.all([
    fetch(`https://api.github.com/repos/${owner}/${repo}`, { headers }),
    fetch(`https://api.github.com/repos/${owner}/${repo}/git/trees/HEAD?recursive=1`, { headers }),
  ]);

  if (!infoRes.ok) {
    const err = await infoRes.json().catch(() => ({}));
    throw new Error(err.message ?? `GitHub error: ${infoRes.status} ${infoRes.statusText}`);
  }

  const info     = await infoRes.json();
  const treeData = treeRes.ok ? await treeRes.json() : { tree: [] };
  const files    = (treeData.tree ?? []).filter(f => f.type === 'blob').map(f => f.path);

  const toFetch = [
    ...PRIORITY_FILES.filter(p => files.includes(p)),
    ...files.filter(p => !PRIORITY_FILES.includes(p)).slice(0, 3),
  ].slice(0, MAX_FILES_FETCH);

  const contents = {};
  await Promise.all(toFetch.map(async path => {
    try {
      const r = await fetch(
        `https://api.github.com/repos/${owner}/${repo}/contents/${path}`,
        { headers },
      );
      if (!r.ok) return;
      const d = await r.json();
      if (d.encoding === 'base64' && d.content) {
        const decoded = Buffer.from(d.content.replace(/\n/g, ''), 'base64').toString('utf-8');
        contents[path] = decoded.slice(0, MAX_CONTENT_CHARS);
      }
    } catch { /* skip unreadable files */ }
  }));

  return {
    info,
    files: files.slice(0, MAX_TREE_DISPLAY),
    contents,
  };
}
