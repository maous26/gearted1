import { Request, Response, NextFunction } from 'express';
import { uploadToS3, deleteFromS3 } from '../services/storage.service';
import { logger } from '../utils/logger';

// Upload d'une ou plusieurs images
export const uploadImages = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Aucun fichier n\'a été envoyé',
      });
    }

    const files = req.files as Express.Multer.File[];
    const userId = (req as any).userId; // Extract userId from authenticated request
    const uploadPromises = files.map(file => uploadToS3(file, userId));
    const imageUrls = await Promise.all(uploadPromises);

    res.status(200).json({
      success: true,
      imageUrls,
    });
  } catch (error) {
    logger.error(`Erreur lors de l'upload d'images: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};

// Suppression d'une image
export const deleteImage = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { imageUrl } = req.body;

    if (!imageUrl) {
      return res.status(400).json({
        success: false,
        message: 'URL de l\'image requise',
      });
    }

    await deleteFromS3(imageUrl);

    res.status(200).json({
      success: true,
      message: 'Image supprimée avec succès',
    });
  } catch (error) {
    logger.error(`Erreur lors de la suppression d'image: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};
