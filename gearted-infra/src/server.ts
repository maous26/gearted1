import app from './app';
import connectDB from './config/database';
import { logger } from './utils/logger';

const PORT = process.env.PORT || 3000;

// Connexion à la base de données
connectDB();

// Démarrage du serveur
const server = app.listen(PORT, () => {
  logger.info(`Serveur démarré sur le port ${PORT}`);
});

// Gestion des erreurs non capturées
process.on('unhandledRejection', (err: Error) => {
  logger.error(`Erreur non capturée: ${err.message}`);
  server.close(() => process.exit(1));
});
