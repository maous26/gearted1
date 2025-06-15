import { Request, Response, NextFunction } from 'express';
import { logger } from '../../utils/logger';

export const errorMiddleware = (err: Error, req: Request, res: Response, next: NextFunction) => {
  logger.error(`Erreur: ${err.message}`);
  
  // Si l'erreur est une erreur de validation MongoDB
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      success: false,
      message: 'Erreur de validation des données',
      error: err.message,
    });
  }
  
  // Si l'erreur est une erreur MongoDB
  if (err.name === 'MongoError') {
    return res.status(400).json({
      success: false,
      message: 'Erreur de base de données',
      error: err.message,
    });
  }
  
  // Erreur par défaut
  res.status(500).json({
    success: false,
    message: 'Erreur serveur',
    error: process.env.NODE_ENV === 'development' ? err.message : 'Une erreur est survenue',
  });
};
