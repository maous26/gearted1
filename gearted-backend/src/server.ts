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
    await connectDB();
    
    // Connect to PostgreSQL if configured
    if (process.env.POSTGRES_HOST) {
      try {
        await connectPostgres();
        // Run the compatibility schema migration
        await migrateCompatibilitySchema();
      } catch (pgError) {
        logger.error(`❌ PostgreSQL connection failed: ${pgError instanceof Error ? pgError.message : String(pgError)}`);
        logger.warn('⚠️ Continuing without PostgreSQL - compatibility features will be limited');
      }
    } else {
      logger.warn('⚠️ PostgreSQL not configured, compatibility features will be limited');
    }
    
    // Connect to Redis if configured
    if (process.env.REDIS_HOST) {
      try {
        await connectRedis();
      } catch (redisError) {
        logger.error(`❌ Redis connection failed: ${redisError instanceof Error ? redisError.message : String(redisError)}`);
        logger.warn('⚠️ Continuing without Redis - using fallback caching');
      }
    } else {
      logger.warn('⚠️ Redis not configured, using fallback caching');
    }
    
    const server = app.listen(PORT, '0.0.0.0', () => {
      logger.info(`🚀 Serveur démarré sur le port ${PORT}`);
      logger.info(`📁 Environment: ${process.env.NODE_ENV || 'development'}`);
    });

    // Gestion des erreurs de port
    server.on('error', (error: any) => {
      if (error.code === 'EADDRINUSE') {
        logger.error(`❌ Le port ${PORT} est déjà utilisé.`);
        logger.error(`💡 Utilisez 'npm run dev:safe' pour démarrer avec nettoyage automatique du port.`);
        logger.error(`🔧 Ou tuez manuellement le processus: lsof -ti :${PORT} | xargs kill`);
        process.exit(1);
      } else {
        logger.error(`❌ Erreur serveur: ${error.message}`);
        process.exit(1);
      }
    });

  } catch (error) {
    logger.error(`Erreur lors du démarrage du serveur: ${error instanceof Error ? error.message : String(error)}`);
    process.exit(1);
  }
};

startServer();