import { Pool } from 'pg';
import { logger } from '../utils/logger';

// PostgreSQL connection pool
export const pgPool = new Pool({
  host: process.env.POSTGRES_HOST || 'localhost',
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
  user: process.env.POSTGRES_USER || 'gearted',
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB || 'gearted_db',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Initialize PostgreSQL connection
export const connectPostgres = async (): Promise<void> => {
  try {
    const client = await pgPool.connect();
    logger.info('✅ PostgreSQL connected successfully');
    client.release();
  } catch (error) {
    logger.error(`❌ PostgreSQL connection error: ${error instanceof Error ? error.message : String(error)}`);
    throw error;
  }
};

// Get a client from the pool
export const getClient = async () => {
  return await pgPool.connect();
};
