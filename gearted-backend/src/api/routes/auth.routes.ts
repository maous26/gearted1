import { Router } from 'express';
import { 
  register, 
  login, 
  getMe, 
  oauthSuccess, 
  oauthFailure,
  mobileGoogleAuth,
  mobileFacebookAuth,
  mobileInstagramAuth,
  updateFCMToken,
  removeFCMToken,
  testOAuthNotifications
} from '../../controllers/auth.controller';
import { authMiddleware } from '../middlewares/auth.middleware';
import passport from '../../config/passport';

const router = Router();

// Routes d'authentification classique
router.post('/register', register);
router.post('/login', login);
router.get('/me', authMiddleware, getMe);

// Routes OAuth Google
router.get('/google', 
  passport.authenticate('google', { scope: ['profile', 'email'] })
);

router.get('/google/callback',
  passport.authenticate('google', { failureRedirect: '/api/auth/failure' }),
  oauthSuccess
);

// Routes OAuth Facebook
router.get('/facebook',
  passport.authenticate('facebook', { scope: ['email'] })
);

router.get('/facebook/callback',
  passport.authenticate('facebook', { failureRedirect: '/api/auth/failure' }),
  oauthSuccess
);

// Route d'échec OAuth
router.get('/failure', oauthFailure);

// Routes OAuth Mobile
router.post('/google/mobile', mobileGoogleAuth);
router.post('/facebook/mobile', mobileFacebookAuth);
router.post('/instagram/mobile', mobileInstagramAuth);

// Routes FCM Token Management
router.put('/fcm-token', authMiddleware, updateFCMToken);
router.delete('/fcm-token', authMiddleware, removeFCMToken);

// Route de test pour les notifications OAuth (development uniquement)
router.post('/test-oauth-notifications', testOAuthNotifications);

export default router;
