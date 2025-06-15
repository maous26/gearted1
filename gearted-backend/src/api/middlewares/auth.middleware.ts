import { Request, Response, NextFunction } from 'express';
import User, { IUser } from '../../models/user.model';
import { logger } from '../../utils/logger';
import { authService } from '../../services/auth.service';

export const authMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  try {
    // Extract token from header
    const token = authService.extractTokenFromHeader(req.headers.authorization);
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. No token provided',
      });
    }

    // Verify token
    const decoded = authService.verifyToken(token);
    
    // Get full user information
    const user = await User.findById(decoded.id).select('-password');
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User not found',
      });
    }
    
    // Add user info to request
    req.user = user;
    
    next();
  } catch (error) {
    logger.error(`Authentication error: ${error instanceof Error ? error.message : String(error)}`);
    
    // Provide specific error message
    let message = 'Access denied. Invalid token';
    if (error instanceof Error) {
      if (error.message === 'Token has expired') {
        message = 'Access denied. Token has expired';
      } else if (error.message === 'Invalid token') {
        message = 'Access denied. Invalid token';
      }
    }
    
    return res.status(401).json({
      success: false,
      message,
    });
  }
};

// Admin middleware - requires authentication + admin role
export const adminMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  try {
    // First run auth middleware
    await new Promise<void>((resolve, reject) => {
      authMiddleware(req, res, (err) => {
        if (err) reject(err);
        else resolve();
      });
    });

    // Check if user is admin
    if (!req.user || !(req.user as IUser).isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin privileges required',
      });
    }

    next();
  } catch (error) {
    logger.error(`Admin authentication error: ${error instanceof Error ? error.message : String(error)}`);
    return res.status(401).json({
      success: false,
      message: 'Access denied. Authentication failed',
    });
  }
};

// Optional auth middleware - continues even if no token
export const optionalAuthMiddleware = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const token = authService.extractTokenFromHeader(req.headers.authorization);
    
    if (token) {
      const decoded = authService.verifyToken(token);
      const user = await User.findById(decoded.id).select('-password');
      
      if (user) {
        req.user = user;
      }
    }
    
    next();
  } catch (error) {
    // Continue without authentication
    logger.debug(`Optional auth failed: ${error instanceof Error ? error.message : String(error)}`);
    next();
  }
};
