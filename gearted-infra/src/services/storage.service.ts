import { S3Client, PutObjectCommand, DeleteObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import multer from 'multer';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';
import sharp from 'sharp';
import { logger } from '../utils/logger';

// Configuration S3 Client v3
const s3Client = new S3Client({
  region: process.env.AWS_REGION || 'eu-north-1',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY!,
    secretAccessKey: process.env.AWS_SECRET_KEY!
  }
});

// Configuration pour le stockage local (temporaire avant upload S3)
const storage = multer.memoryStorage();

// Filtre pour accepter uniquement les images
const fileFilter = (req: any, file: Express.Multer.File, cb: Function) => {
  const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Type de fichier non supporté. Utilisez JPG, PNG ou WEBP.'), false);
  }
};

// Configuration de multer
export const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB max (avant compression)
  fileFilter
});

// Compression et redimensionnement d'image
const optimizeImage = async (file: Express.Multer.File, options = { quality: 80, maxWidth: 1200 }): Promise<Buffer> => {
  try {
    const transformer = sharp(file.buffer)
      .resize({
        width: options.maxWidth,
        height: undefined,
        fit: 'inside',
        withoutEnlargement: true
      });

    // Appliquer le format et la qualité selon le type MIME
    switch (file.mimetype) {
      case 'image/jpeg':
      case 'image/jpg':
        return await transformer.jpeg({ quality: options.quality }).toBuffer();
      case 'image/png':
        return await transformer.png({ compressionLevel: 9 }).toBuffer();
      case 'image/webp':
        return await transformer.webp({ quality: options.quality }).toBuffer();
      default:
        return await transformer.jpeg({ quality: options.quality }).toBuffer();
    }
  } catch (error) {
    logger.error(`Erreur lors de l'optimisation de l'image: ${error instanceof Error ? error.message : String(error)}`);
    return file.buffer; // Fallback au buffer original en cas d'erreur
  }
};

// Upload vers S3 avec compression (sans ACL)
export const uploadToS3 = async (file: Express.Multer.File, userId?: string): Promise<string> => {
  try {
    // Comprimer l'image
    const optimizedBuffer = await optimizeImage(file);
    
    // Générer un nom de fichier unique
    const extension = path.extname(file.originalname).toLowerCase();
    const fileName = `${uuidv4()}${extension}`;
    
    // Déterminer le type MIME correct
    let contentType = file.mimetype;
    if (extension === '.jpg' || extension === '.jpeg') contentType = 'image/jpeg';
    else if (extension === '.png') contentType = 'image/png';
    else if (extension === '.webp') contentType = 'image/webp';
    
    // Upload vers S3 (sans ACL)
    const uploadParams = {
      Bucket: process.env.AWS_S3_BUCKET || 'gearted-images',
      Key: fileName,
      Body: optimizedBuffer,
      ContentType: contentType
    };
    
    await s3Client.send(new PutObjectCommand(uploadParams));
    
    // Construire l'URL publique
    const publicUrl = `https://${uploadParams.Bucket}.s3.${process.env.AWS_REGION || 'eu-north-1'}.amazonaws.com/${fileName}`;
    
    // Enregistrer la référence dans la base de données (à implémenter)
    if (userId) {
      await trackImageUpload(publicUrl, userId);
    }
    
    return publicUrl;
  } catch (error) {
    logger.error(`Erreur lors de l'upload vers S3: ${error instanceof Error ? error.message : String(error)}`);
    throw error;
  }
};

// Supprimer de S3
export const deleteFromS3 = async (imageUrl: string): Promise<void> => {
  try {
    // Extraire le nom du fichier de l'URL
    const key = imageUrl.split('/').pop();
    
    if (!key) {
      throw new Error('Impossible d\'extraire la clé de l\'URL');
    }
    
    const deleteParams = {
      Bucket: process.env.AWS_S3_BUCKET || 'gearted-images',
      Key: key
    };
    
    await s3Client.send(new DeleteObjectCommand(deleteParams));
    
    // Supprimer la référence dans la base de données (à implémenter)
    await removeImageReference(imageUrl);
  } catch (error) {
    logger.error(`Erreur lors de la suppression de S3: ${error instanceof Error ? error.message : String(error)}`);
    throw error;
  }
};

// Générer une URL signée avec expiration
export const getSignedUrlForDownload = async (imageUrl: string, expiresInSeconds = 3600): Promise<string> => {
  try {
    // Extraire le nom du fichier de l'URL
    const key = imageUrl.split('/').pop();
    
    if (!key) {
      throw new Error('Impossible d\'extraire la clé de l\'URL');
    }
    
    const command = new GetObjectCommand({
      Bucket: process.env.AWS_S3_BUCKET || 'gearted-images',
      Key: key
    });
    
    return await getSignedUrl(s3Client, command, { expiresIn: expiresInSeconds });
  } catch (error) {
    logger.error(`Erreur lors de la génération de l'URL signée: ${error instanceof Error ? error.message : String(error)}`);
    throw error;
  }
};

// Fonctions de suivi des images (à implémenter avec un modèle)
const trackImageUpload = async (imageUrl: string, userId: string) => {
  // TODO: Implémenter avec le modèle ImageReference
  logger.info(`Image uploaded: ${imageUrl} by user ${userId}`);
};

const removeImageReference = async (imageUrl: string) => {
  // TODO: Implémenter avec le modèle ImageReference
  logger.info(`Image reference removed: ${imageUrl}`);
};