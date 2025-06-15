import mongoose, { ConnectOptions } from 'mongoose';
import { logger } from '../utils/logger';

// Configuration Mongoose
mongoose.set('strictQuery', false);

// Detect if using Atlas or local MongoDB
const isAtlas = (uri: string) => uri.includes('mongodb+srv://');

// Options de connexion pour MongoDB Atlas
const atlasOptions: ConnectOptions = {
  maxPoolSize: 10, // Plus de connexions pour Atlas
  serverSelectionTimeoutMS: 10000, // Timeout plus long pour Atlas
  socketTimeoutMS: 45000, // Timeout plus long pour les opérations
  family: 4, // Use IPv4, skip trying IPv6
  retryWrites: true, // Retry writes on network errors
  authSource: 'admin', // Authentication database
  ssl: true, // SSL required for Atlas
};

// Options de connexion pour MongoDB local
const localOptions: ConnectOptions = {
  maxPoolSize: 5,
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 20000,
  family: 4,
  retryWrites: true,
};

const connectDB = async (): Promise<void> => {
  try {
    // Utiliser DB_URI (comme dans votre .env) au lieu de MONGO_URI
    const uri = process.env.DB_URI;
    
    if (!uri) {
      throw new Error('DB_URI n\'est pas défini dans les variables d\'environnement');
    }
    
    // Choose appropriate options based on connection type
    const mongooseOptions = isAtlas(uri) ? atlasOptions : localOptions;
    
    logger.info(`🔗 Connexion à ${isAtlas(uri) ? 'MongoDB Atlas' : 'MongoDB local'}...`);
    
    // Connexion avec options appropriées
    await mongoose.connect(uri, mongooseOptions);
    
    // Événements de connexion
    mongoose.connection.on('connected', () => {
      logger.info(`✅ Connexion à ${isAtlas(uri) ? 'MongoDB Atlas' : 'MongoDB local'} établie`);
      logger.info(`📊 Base de données: ${mongoose.connection.name}`);
      logger.info(`🌐 Host: ${mongoose.connection.host}`);
    });
    
    mongoose.connection.on('error', (err) => {
      logger.error(`❌ Erreur MongoDB: ${err}`);
    });
    
    mongoose.connection.on('disconnected', () => {
      logger.warn('⚠️ Déconnexion de MongoDB');
    });
    
    // Gestion propre de la fermeture
    process.on('SIGINT', async () => {
      await mongoose.connection.close();
      logger.info('Connexion MongoDB fermée suite à l\'arrêt de l\'application');
      process.exit(0);
    });
    
  } catch (error) {
    logger.error(`❌ Erreur de connexion à MongoDB: ${error instanceof Error ? error.message : String(error)}`);
    process.exit(1);
  }
};

// Fonction utilitaire pour vérifier l'état de la connexion
export const isConnected = (): boolean => {
  return mongoose.connection.readyState === 1;
};

// Fonction pour obtenir des statistiques de connexion
export const getConnectionStats = () => {
  const { readyState } = mongoose.connection;
  const states = {
    0: 'Déconnecté',
    1: 'Connecté',
    2: 'En cours de connexion',
    3: 'En cours de déconnexion',
  };
  
  return {
    status: states[readyState as keyof typeof states] || 'Inconnu',
    readyState,
    host: mongoose.connection.host,
    name: mongoose.connection.name,
  };
};

export default connectDB;