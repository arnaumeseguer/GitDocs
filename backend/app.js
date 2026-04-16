import express from 'express';
import cors from 'cors';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import router from './routes/index.js';

const __dirname = dirname(fileURLToPath(import.meta.url));

const app = express();

app.use(cors());
app.use(express.json());

// Serve frontend static files
app.use(express.static(join(__dirname, '../frontend')));

// API routes
app.use('/api', router);

// Fallback: serve frontend for any unknown route
app.get('*', (_req, res) => {
  res.sendFile(join(__dirname, '../frontend/index.html'));
});

export default app;
