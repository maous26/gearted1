// Ajouter ces lignes AU TOUT DÉBUT du fichier server.ts
import dotenv from 'dotenv';
dotenv.config();

// Le reste de vos imports
import app from './app';
import connectDB from './config/database';
import { connectPostgres } from './config/postgres';
import { connectRedis } from './config/redis';
import { migrateCompatibilitySchema } from './migrations/compatibility-schema';
import { logger } from './utils/logger';

const PORT = parseInt(process.env.PORT || '3000', 10);

// Vérifier les variables critiques
if (!process.env.DB_URI) {
  logger.error('❌ DB_URI manquant dans le fichier .env');
  process.exit(1);
}

// Démarrer le serveur
const startServer = async () => {
  try {
    // In production, be more tolerant of database connection issues
    const isProduction = process.env.NODE_ENV === 'production';
    
    // Always try to connect to MongoDB first
    logger.info('🔗 Connecting to MongoDB...');
    await connectDB();
    logger.info('✅ MongoDB connected successfully');
    
    // Connect to PostgreSQL if configured (optional in production)
    if (process.env.POSTGRES_HOST) {
      try {
        await connectPostgres();
        await migrateCompatibilitySchema();
        logger.info('✅ PostgreSQL connected and migrated');
      } catch (pgError) {
        logger.error(`❌ PostgreSQL connection failed: ${pgError instanceof Error ? pgError.message : String(pgError)}`);
        if (!isProduction) {
          logger.warn('⚠️ Continuing without PostgreSQL - compatibility features will be limited');
        }
      }
    } else {
      logger.info('⚠️ PostgreSQL not configured, compatibility features will be limited');
    }
    
    // Connect to Redis if configured (optional in production)
    if (process.env.REDIS_HOST) {
      try {
        await connectRedis();
        logger.info('✅ Redis connected successfully');
      } catch (redisError) {
        logger.error(`❌ Redis connection failed: ${redisError instanceof Error ? redisError.message : String(redisError)}`);
        if (!isProduction) {
          logger.warn('⚠️ Continuing without Redis - using fallback caching');
        }
      }
    } else {
      logger.info('⚠️ Redis not configured, using fallback caching');
    }
    
    const server = app.listen(PORT, '0.0.0.0', () => {
      logger.info(`🚀 Gearted Backend Server started successfully`);
      logger.info(`📍 Server running on: http://0.0.0.0:${PORT}`);
      logger.info(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
      logger.info(`🔗 Health check: http://0.0.0.0:${PORT}/api/health`);
      
      // Log that server is ready to accept connections
      if (isProduction) {
        logger.info(`✅ Production server ready - all systems operational`);
      }
    });

    // Enhanced error handling for server
    server.on('error', (error: any) => {
      if (error.code === 'EADDRINUSE') {
        logger.error(`❌ Port ${PORT} is already in use`);
        logger.error(`💡 Use a different port or kill the existing process`);
        process.exit(1);
      } else if (error.code === 'EACCES') {
        logger.error(`❌ Permission denied for port ${PORT}`);
        logger.error(`💡 Try using a port > 1024 or run with appropriate permissions`);
        process.exit(1);
      } else {
        logger.error(`❌ Server error: ${error.message}`);
        process.exit(1);
      }
    });

    // Graceful shutdown handling
    const gracefulShutdown = (signal: string) => {
      logger.info(`🛑 Received ${signal}, starting graceful shutdown`);
      server.close(() => {
        logger.info('✅ HTTP server closed');
        process.exit(0);
      });
    };

    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));

  } catch (error) {
    logger.error(`Erreur lors du démarrage du serveur: ${error instanceof Error ? error.message : String(error)}`);
    process.exit(1);
  }
};

startServer();