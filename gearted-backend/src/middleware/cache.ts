import { Request, Response, NextFunction } from 'express';
import { getRedisClient } from '../config/redis';
import { logger } from '../utils/logger';

/**
 * Create a caching middleware with a specific key prefix and TTL
 * 
 * @param keyPrefix - Prefix to use for this route's cache key
 * @param ttl - Time to live in seconds
 * @returns Express middleware function
 */
export const cache = (keyPrefix: string, ttl = 3600) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    // Skip cache if explicitly requested
    if (req.query.noCache === 'true' || req.headers['x-no-cache'] === 'true') {
      return next();
    }
    
    // Create a cache key based on request path
    const cacheKey = `gearted:/${req.originalUrl}`;
    
    // Get Redis client
    const redisClient = getRedisClient();
    
    // If Redis is not available, continue without caching
    if (!redisClient) {
      return next();
    }
    
    try {
      // Try to get data from cache
      const cachedData = await redisClient.get(cacheKey);
      
      if (cachedData) {
        // Cache hit
        return res.json(JSON.parse(cachedData));
      }
      
      // Cache miss, store the response
      const originalJson = res.json;
      res.json = function(body) {
        // Use async function but don't await (fire and forget)
        (async () => {
          try {
            await redisClient.setEx(cacheKey, ttl, JSON.stringify(body));
          } catch (err) {
            logger.error(`Redis cache set error: ${err instanceof Error ? err.message : String(err)}`);
          }
        })();
        
        return originalJson.call(this, body);
      };
      
      next();
    } catch (error) {
      logger.error(`Cache middleware error: ${error instanceof Error ? error.message : String(error)}`);
      next();
    }
  };
};