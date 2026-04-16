import { Router } from 'express';
import aiRoutes from './ai.routes.js';
import githubRoutes from './github.routes.js';

const router = Router();

router.use('/ai', aiRoutes);
router.use('/github', githubRoutes);

export default router;
