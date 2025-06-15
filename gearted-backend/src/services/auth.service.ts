import * as jwt from 'jsonwebtoken';
import { logger } from '../utils/logger';

export interface JWTPayload {
  id: string;
  email: string;
  username: string;
  isAdmin?: boolean;
}

export interface TokenOptions {
  expiresIn?: string;
  issuer?: string;
  audience?: string;
}

class AuthService {
  private readonly defaultOptions: TokenOptions = {
    expiresIn: process.env.JWT_EXPIRATION || '24h',
    issuer: 'gearted-api',
    audience: 'gearted-app'
  };

  /**
   * Generate a JWT token
   */
  generateToken(payload: JWTPayload, options?: TokenOptions): string {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
      throw new Error('JWT_SECRET is not defined in environment variables');
    }

    const tokenOptions = { ...this.defaultOptions, ...options };
    
    try {
      return jwt.sign(payload, secret, tokenOptions);
    } catch (error) {
      logger.error(`Error generating JWT token: ${error instanceof Error ? error.message : String(error)}`);
      throw new Error('Failed to generate authentication token');
    }
  }

  /**
   * Verify a JWT token
   */
  verifyToken(token: string): JWTPayload {
    const secret = process.env.JWT_SECRET;
    if (!secret) {
      throw new Error('JWT_SECRET is not defined in environment variables');
    }

    try {
      const decoded = jwt.verify(token, secret) as JWTPayload;
      return decoded;
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw new Error('Token has expired');
      } else if (error instanceof jwt.JsonWebTokenError) {
        throw new Error('Invalid token');
      } else {
        logger.error(`Error verifying JWT token: ${error instanceof Error ? error.message : String(error)}`);
        throw new Error('Token verification failed');
      }
    }
  }

  /**
   * Generate a refresh token (longer expiration)
   */
  generateRefreshToken(payload: JWTPayload): string {
    return this.generateToken(payload, { expiresIn: '7d' });
  }

  /**
   * Generate access token (shorter expiration)
   */
  generateAccessToken(payload: JWTPayload): string {
    return this.generateToken(payload, { expiresIn: '15m' });
  }

  /**
   * Decode token without verification (for debugging)
   */
  decodeToken(token: string): any {
    try {
      return jwt.decode(token);
    } catch (error) {
      logger.error(`Error decoding JWT token: ${error instanceof Error ? error.message : String(error)}`);
      return null;
    }
  }

  /**
   * Check if token is expired
   */
  isTokenExpired(token: string): boolean {
    try {
      const decoded = jwt.decode(token) as any;
      if (!decoded || !decoded.exp) {
        return true;
      }
      
      const currentTime = Date.now() / 1000;
      return decoded.exp < currentTime;
    } catch (error) {
      return true;
    }
  }

  /**
   * Extract token from Authorization header
   */
  extractTokenFromHeader(authHeader: string | undefined): string | null {
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }
    return authHeader.split(' ')[1];
  }

  /**
   * Generate admin token with elevated privileges
   */
  generateAdminToken(payload: JWTPayload): string {
    const adminPayload = { ...payload, isAdmin: true };
    return this.generateToken(adminPayload, { expiresIn: '8h' });
  }
}

export const authService = new AuthService();
export default authService;