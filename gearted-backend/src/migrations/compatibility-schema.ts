import { pgPool } from '../config/postgres';
import { logger } from '../utils/logger';
import fs from 'fs';
import path from 'path';

// Run the schema migration
export const migrateCompatibilitySchema = async (): Promise<void> => {
  try {
    const schemaPath = path.join(__dirname, '../../sql/compatibility-schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');
    
    const client = await pgPool.connect();
    try {
      await client.query(schema);
      logger.info('✅ Compatibility schema migration completed successfully');
    } finally {
      client.release();
    }
  } catch (error) {
    logger.error(`❌ Schema migration error: ${error instanceof Error ? error.message : String(error)}`);
    throw error;
  }
};
