import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import User from '../models/user.model';
import { logger } from '../utils/logger';

// Enregistrement d'un nouvel utilisateur
export const register = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { username, email, password } = req.body;

    // Vérifier si l'utilisateur existe déjà
    const existingUser = await User.findOne({ 
      $or: [{ email: email }, { username: username }] 
    });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Cet email ou nom d\'utilisateur est déjà utilisé',
      });
    }

    // Créer un nouvel utilisateur
    const user = new User({
      username,
      email,
      password,
    });

    await user.save();

    // Générer un token JWT
    const token = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET || 'default_secret',
      { expiresIn: process.env.JWT_EXPIRATION || '24h' }
    );

    // Réponse sans le mot de passe
    res.status(201).json({
      success: true,
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        profileImage: user.profileImage,
        rating: user.rating,
        salesCount: user.salesCount,
        createdAt: user.createdAt,
      },
    });
  } catch (error) {
    logger.error(`Erreur lors de l'enregistrement: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};

// Connexion d'un utilisateur
export const login = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password } = req.body;

    // Trouver l'utilisateur par email
    const user = await User.findOne({ email }).select('+password');

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Email ou mot de passe incorrect',
      });
    }

    // Vérifier le mot de passe
    const isMatch = await user.comparePassword(password);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Email ou mot de passe incorrect',
      });
    }

    // Générer un token JWT
    const token = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET || 'default_secret',
      { expiresIn: process.env.JWT_EXPIRATION || '24h' }
    );

    // Réponse sans le mot de passe
    res.status(200).json({
      success: true,
      token,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        profileImage: user.profileImage,
        rating: user.rating,
        salesCount: user.salesCount,
        createdAt: user.createdAt,
      },
    });
  } catch (error) {
    logger.error(`Erreur lors de la connexion: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};

// Obtenir les informations de l'utilisateur connecté
export const getMe = async (req: Request, res: Response, next: NextFunction) => {
  try {
    // L'ID de l'utilisateur est extrait du middleware d'authentification
    const userId = (req as any).userId;
    
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Utilisateur non trouvé',
      });
    }

    res.status(200).json({
      success: true,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
        profileImage: user.profileImage,
        rating: user.rating,
        salesCount: user.salesCount,
        createdAt: user.createdAt,
      },
    });
  } catch (error) {
    logger.error(`Erreur lors de la récupération du profil: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};
