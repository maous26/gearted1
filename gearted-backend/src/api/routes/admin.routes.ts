import { Router } from 'express';
import {
  getAdminStats,
  getUsers,
  getUserById,
  updateUser,
  suspendUser,
  deleteUser,
  getListings,
  getListingById,
  updateListing,
  approveListing,
  suspendListing,
  deleteListing,
  getMessages,
  deleteMessage,
  getReports,
  resolveReport,
  getSettings,
  updateSettings,
  getAnalytics
} from '../controllers/admin.controller';
import { authMiddleware } from '../middlewares/auth.middleware';
// import { adminMiddleware } from '../middlewares/admin.middleware';

// Temporary fix for TypeScript module resolution issue
const adminMiddleware = require('../middlewares/admin.middleware').adminMiddleware;

const router = Router();

// Apply auth and admin middleware to all routes
router.use(authMiddleware);
router.use(adminMiddleware);

// Dashboard & Stats
router.get('/stats', getAdminStats);
router.get('/analytics', getAnalytics);

// User Management
router.get('/users', getUsers);
router.get('/users/:id', getUserById);
router.put('/users/:id', updateUser);
router.post('/users/:id/suspend', suspendUser);
router.delete('/users/:id', deleteUser);

// Listing Management
router.get('/listings', getListings);
router.get('/listings/:id', getListingById);
router.put('/listings/:id', updateListing);
router.post('/listings/:id/approve', approveListing);
router.post('/listings/:id/suspend', suspendListing);
router.delete('/listings/:id', deleteListing);

// Message Management
router.get('/messages', getMessages);
router.delete('/messages/:id', deleteMessage);

// Reports & Moderation
router.get('/reports', getReports);
router.post('/reports/:id/resolve', resolveReport);

// Settings
router.get('/settings', getSettings);
router.put('/settings', updateSettings);

export default router;
