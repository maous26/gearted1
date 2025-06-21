import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import session from 'express-session';
import { config } from 'dotenv';
import { errorMiddleware } from './api/middlewares/error.middleware';
import passport from './config/passport';

// Routes
import authRoutes from './api/routes/auth.routes';
import userRoutes from './api/routes/user.routes';
import listingRoutes from './api/routes/listing.routes';
import uploadRoutes from './api/routes/upload.routes';
import healthRoutes from './api/routes/health.routes';
import adminRoutes from './api/routes/admin.routes';
import compatibilityRoutes from './routes/compatibility';

// Configuration
config();

// App
const app: Application = express();

// Middlewares
app.use(helmet());

// Dynamic CORS configuration
const getAllowedOrigins = () => {
  const defaultOrigins = [
    // Production domains
    'https://www.gearted.eu',
    'https://gearted.eu',
    'https://admin.gearted.eu',
    'https://api.gearted.eu',
    // Render frontend URLs
    'https://gearted1.onrender.com',
    'https://gearted-frontend.onrender.com',
    'https://gearted-admin.onrender.com',
    // Vercel deployments
    'https://gearted1-fwilkxzy6-moussas-projects-6dc9792f.vercel.app',
    'https://gearted1-chnet6wqd-moussas-projects-6dc9792f.vercel.app',
    'https://gearted1-7lb3xzrmy-moussas-projects-6dc9792f.vercel.app',
    'https://gearted1.vercel.app',
    // Development domains
    process.env.CLIENT_URL || 'http://localhost:3000',
    'http://localhost:8080', // Flutter dev port
    'http://localhost:8081', // Flutter alt port
    'http://localhost:8082', // Flutter alt port
    'http://localhost:3001', // Admin console (port 3001)
    'http://localhost:3002', // Admin console (port 3002)
    'http://localhost:3003', // Admin console (port 3003)
    'http://localhost:3005'  // Admin console (port 3005)
  ];

  // Add origins from environment variable if available
  if (process.env.CORS_ORIGIN) {
    const envOrigins = process.env.CORS_ORIGIN.split(',').map(origin => origin.trim());
    return [...defaultOrigins, ...envOrigins];
  }

  return defaultOrigins;
};

app.use(cors({
  origin: getAllowedOrigins(),
  credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// Session middleware pour OAuth
app.use(session({
  secret: process.env.JWT_SECRET || 'default_secret',
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    maxAge: 24 * 60 * 60 * 1000, // 24 heures
    httpOnly: true, // Sécurité supplémentaire
    sameSite: 'strict' // Protection CSRF
  },
  name: 'gearted.sid' // Nom de session personnalisé
}));

// Initialiser Passport
app.use(passport.initialize());
app.use(passport.session());

// Route racine pour /api
app.get('/api', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'Gearted Backend API',
    version: '1.0.0',
    endpoints: {
      health: '/api/health',
      auth: '/api/auth',
      users: '/api/users',
      listings: '/api/listings',
      upload: '/api/upload',
      admin: '/api/admin',
      compatibility: '/v1/compatibility'
    }
  });
});

// Route racine pour /
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'Gearted Backend Server',
    version: '1.0.0',
    api: '/api',
    health: '/api/health',
    docs: 'Marketplace pour équipements Airsoft'
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/listings', listingRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/health', healthRoutes);
app.use('/api/admin', adminRoutes);
app.use('/v1/compatibility', compatibilityRoutes);

// Gestion des erreurs
app.use(errorMiddleware);

export default app;
