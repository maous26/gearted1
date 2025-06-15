import { Request, Response, NextFunction } from 'express';

/**
 * Wrapper for async route handlers to catch errors
 * This eliminates the need for try/catch blocks in each route
 * 
 * @param fn - Async route handler function
 * @returns Express middleware with error handling
 */
export const handleAsync = (
  fn: (req: Request, res: Response, next: NextFunction) => Promise<any>
) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch((err) => {
      console.error('Route error:', err);
      res.status(500).json({ error: 'Internal server error' });
    });
  };
};
