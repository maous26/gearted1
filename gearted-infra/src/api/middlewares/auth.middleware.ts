import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { logger } from '../../utils/logger';

export const authMiddleware = (req: Request, res: Response, next: NextFunction) => {
  try {
    // Récupérer le token du header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Accès non autorisé. Token manquant',
      });
    }

    const token = authHeader.split(' ')[1];

    // Vérifier le token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'default_secret');
    
    // Ajouter l'ID utilisateur à la requête
    (req as any).userId = (decoded as any).id;
    
    next();
  } catch (error) {
    logger.error(`Erreur d'authentification: ${error instanceof Error ? error.message : String(error)}`);
    return res.status(401).json({
      success: false,
      message: 'Accès non autorisé. Token invalide',
    });
  }
};
