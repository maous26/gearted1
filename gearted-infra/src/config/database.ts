import mongoose from 'mongoose';
import { logger } from '../utils/logger';

const connectDB = async (): Promise<void> => {
  try {
    const uri = process.env.DB_URI || 'mongodb://localhost:27017/gearted';
    
    await mongoose.connect(uri);
    
    logger.info('Connexion à MongoDB établie');
  } catch (error) {
    logger.error(`Erreur de connexion à MongoDB: ${error instanceof Error ? error.message : String(error)}`);
    process.exit(1);
  }
};

export default connectDB;
