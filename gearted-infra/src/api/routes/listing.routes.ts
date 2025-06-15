import { Router } from 'express';
import { 
  getListings, 
  getListingById, 
  createListing, 
  updateListing, 
  deleteListing,
  markAsSold
} from '../../controllers/listing.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = Router();

// Routes publiques
router.get('/', getListings);
router.get('/:id', getListingById);

// Routes protégées
router.post('/', authMiddleware, createListing);
router.put('/:id', authMiddleware, updateListing);
router.delete('/:id', authMiddleware, deleteListing);
router.patch('/:id/sold', authMiddleware, markAsSold);

export default router;
