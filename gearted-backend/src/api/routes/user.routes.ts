import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = Router();

// Route de test
router.get('/test', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'User routes working',
  });
});

// Route protégée
router.get('/profile', authMiddleware, (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Profile route protected',
    userId: (req as any).userId,
  });
});

export default router;
