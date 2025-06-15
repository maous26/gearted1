import { Request, Response, NextFunction } from 'express';

/**
 * Admin middleware to check if user has admin privileges
 */
const adminMiddleware = (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = (req as any).user;
    
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Non authentifié'
      });
    }

    // Check if user has admin role
    // For now, we'll check if the email is in the admin list
    const adminEmails = [
      'admin@gearted.com',
      'moussa@gearted.com',
      process.env.ADMIN_EMAIL
    ].filter(Boolean);

    if (!adminEmails.includes(user.email)) {
      return res.status(403).json({
        success: false,
        message: 'Accès refusé. Privilèges administrateur requis.'
      });
    }

    next();
  } catch (error) {
    console.error('Admin middleware error:', error);
    return res.status(500).json({
      success: false,
      message: 'Erreur du serveur lors de la vérification des privilèges'
    });
  }
};

export { adminMiddleware };
export default adminMiddleware;
