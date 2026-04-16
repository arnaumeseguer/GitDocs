import { Router } from 'express';
import { getRepo } from '../controllers/github.controller.js';

const router = Router();

router.post('/repo', getRepo);

export default router;
