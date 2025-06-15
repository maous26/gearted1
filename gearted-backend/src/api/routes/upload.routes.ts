import { Router } from 'express';
import { upload } from '../../services/storage.service';
import { uploadImages, deleteImage } from '../../controllers/upload.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = Router();

// Route pour uploader une ou plusieurs images
router.post(
  '/',
  authMiddleware,
  upload.array('images', 8), // Max 8 images
  uploadImages
);

// Route pour supprimer une image
router.delete('/', authMiddleware, deleteImage);

export default router;
