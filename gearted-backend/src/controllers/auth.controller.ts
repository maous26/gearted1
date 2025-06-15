import { Request, Response, NextFunction } from 'express';
import User from '../models/user.model';
import { logger } from '../utils/logger';
import notificationService from '../services/notification.service';
import { authService } from '../services/auth.service';

// Fonction helper pour formater la réponse utilisateur
const formatUserResponse = (user: any) => ({
  id: user._id,
  username: user.username,
  email: user.email,
  profileImage: user.profileImage,
  rating: user.rating,
  salesCount: user.salesCount,
  provider: user.provider,
  isEmailVerified: user.isEmailVerified,
  isAdmin: user.isAdmin,
  createdAt: user.createdAt,
});

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
      provider: 'local',
    });

    await user.save();

    // Générer un token JWT
    const token = authService.generateToken({
      id: user._id.toString(),
      email: user.email,
      username: user.username,
      isAdmin: user.isAdmin || false
    });

    // Réponse sans le mot de passe
    res.status(201).json({
      success: true,
      token,
      user: formatUserResponse(user),
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
    if (!user.password) {
      return res.status(401).json({
        success: false,
        message: 'Cet utilisateur utilise une connexion OAuth. Veuillez vous connecter avec Google ou Facebook.',
      });
    }

    const isMatch = await user.comparePassword(password);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Email ou mot de passe incorrect',
      });
    }

    // Générer un token JWT
    const token = authService.generateToken({
      id: user._id.toString(),
      email: user.email,
      username: user.username,
      isAdmin: user.isAdmin || false
    });

    // Réponse sans le mot de passe
    res.status(200).json({
      success: true,
      token,
      user: formatUserResponse(user),
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
      user: formatUserResponse(user),
    });
  } catch (error) {
    logger.error(`Erreur lors de la récupération du profil: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};

// OAuth Success - Gestion du succès de l'authentification OAuth
export const oauthSuccess = async (req: Request, res: Response) => {
  try {
    const user = req.user as any;
    
    if (!user) {
      return res.redirect(`${process.env.CLIENT_URL}/login?error=authentication_failed`);
    }

    // Générer un token JWT
    const token = authService.generateToken({
      id: user._id.toString(),
      email: user.email,
      username: user.username,
      isAdmin: user.isAdmin || false
    });

    // Rediriger vers le frontend avec le token
    res.redirect(`${process.env.CLIENT_URL}/auth/success?token=${token}`);
  } catch (error) {
    logger.error(`Erreur OAuth success: ${error instanceof Error ? error.message : String(error)}`);
    res.redirect(`${process.env.CLIENT_URL}/login?error=server_error`);
  }
};

// OAuth Failure - Gestion de l'échec de l'authentification OAuth
export const oauthFailure = (req: Request, res: Response) => {
  logger.error('Échec de l\'authentification OAuth');
  res.redirect(`${process.env.CLIENT_URL}/login?error=oauth_failed`);
};

// Mobile OAuth - Google
export const mobileGoogleAuth = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { idToken, email, displayName, photoUrl } = req.body;

    if (!idToken || !email) {
      return res.status(400).json({
        success: false,
        message: 'Token ID et email requis',
      });
    }

    // Vérifier si l'utilisateur existe déjà
    let user = await User.findOne({ email });
    let isNewUser = false;
    let wasAccountLinked = false;

    if (user) {
      // Mettre à jour les informations Google si nécessaire
      if (!user.googleId) {
        const hadMultipleMethods = await notificationService.hasMultipleLoginMethods(user._id.toString());
        user.googleId = idToken; // Store some identifier
        user.provider = 'google';
        user.isEmailVerified = true;
        if (!user.profileImage && photoUrl) {
          user.profileImage = photoUrl;
        }
        await user.save();
        wasAccountLinked = true;

        // Notification de compte OAuth associé
        if (hadMultipleMethods) {
          await notificationService.sendOAuthAccountLinkedNotification(
            user._id.toString(),
            'google'
          );
        } else {
          await notificationService.sendNewOAuthProviderAddedNotification(
            user._id.toString(),
            'google',
            ['email']
          );
        }
      }

      // Notification de connexion OAuth réussie
      await notificationService.sendOAuthLoginSuccessNotification(
        user._id.toString(),
        'google',
        req.get('User-Agent') || 'Mobile App',
        new Date()
      );
    } else {
      // Créer un nouvel utilisateur
      user = new User({
        username: displayName || email.split('@')[0],
        email,
        googleId: idToken,
        profileImage: photoUrl,
        provider: 'google',
        isEmailVerified: true,
      });
      await user.save();
      isNewUser = true;

      // Notification de bienvenue OAuth
      await notificationService.sendOAuthWelcomeNotification(
        user._id.toString(),
        'google',
        true
      );

      // Notification de vérification email automatique
      await notificationService.sendOAuthEmailVerificationNotification(
        user._id.toString(),
        'google'
      );
    }

    // Générer un token JWT
    const token = authService.generateToken({
      id: user._id.toString(),
      email: user.email,
      username: user.username,
      isAdmin: user.isAdmin || false
    });

    res.status(200).json({
      success: true,
      token,
      user: formatUserResponse(user),
    });
  } catch (error) {
    logger.error(`Erreur Mobile Google Auth: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};

// Mobile OAuth - Facebook
export const mobileFacebookAuth = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { accessToken, email, name, picture } = req.body;

    if (!accessToken || !email) {
      return res.status(400).json({
        success: false,
        message: 'Token d\'accès et email requis',
      });
    }

    // Vérifier si l'utilisateur existe déjà
    let user = await User.findOne({ email });
    let isNewUser = false;
    let wasAccountLinked = false;

    if (user) {
      // Mettre à jour les informations Facebook si nécessaire
      if (!user.facebookId) {
        const hadMultipleMethods = await notificationService.hasMultipleLoginMethods(user._id.toString());
        user.facebookId = accessToken; // Store some identifier
        user.provider = 'facebook';
        user.isEmailVerified = true;
        if (!user.profileImage && picture) {
          user.profileImage = picture;
        }
        await user.save();
        wasAccountLinked = true;

        // Notification de compte OAuth associé
        if (hadMultipleMethods) {
          await notificationService.sendOAuthAccountLinkedNotification(
            user._id.toString(),
            'facebook'
          );
        } else {
          await notificationService.sendNewOAuthProviderAddedNotification(
            user._id.toString(),
            'facebook',
            ['email']
          );
        }
      }

      // Notification de connexion OAuth réussie
      await notificationService.sendOAuthLoginSuccessNotification(
        user._id.toString(),
        'facebook',
        req.get('User-Agent') || 'Mobile App',
        new Date()
      );
    } else {
      // Créer un nouvel utilisateur
      user = new User({
        username: name || email.split('@')[0],
        email,
        facebookId: accessToken,
        profileImage: picture,
        provider: 'facebook',
        isEmailVerified: true,
      });
      await user.save();
      isNewUser = true;

      // Notification de bienvenue OAuth
      await notificationService.sendOAuthWelcomeNotification(
        user._id.toString(),
        'facebook',
        true
      );

      // Notification de vérification email automatique
      await notificationService.sendOAuthEmailVerificationNotification(
        user._id.toString(),
        'facebook'
      );
    }

    // Générer un token JWT
    const token = authService.generateToken({
      id: user._id.toString(),
      email: user.email,
      username: user.username,
      isAdmin: user.isAdmin || false
    });

    res.status(200).json({
      success: true,
      token,
      user: formatUserResponse(user),
    });
  } catch (error) {
    logger.error(`Erreur Mobile Facebook Auth: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};

// Mobile OAuth - Instagram
export const mobileInstagramAuth = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { accessToken, userId, username, fullName, profilePicture } = req.body;

    if (!accessToken || !userId || !username) {
      return res.status(400).json({
        success: false,
        message: 'Token d\'accès, ID utilisateur et nom d\'utilisateur requis',
      });
    }

    // For now, we'll use the username as email since Instagram doesn't always provide email
    const email = `${username}@instagram.local`;

    // Vérifier si l'utilisateur existe déjà
    let user = await User.findOne({ 
      $or: [
        { email: email },
        { instagramId: userId },
        { username: username }
      ]
    });
    let isNewUser = false;
    let wasAccountLinked = false;

    if (user) {
      // Mettre à jour les informations Instagram si nécessaire
      if (!user.instagramId) {
        const hadMultipleMethods = await notificationService.hasMultipleLoginMethods(user._id.toString());
        user.instagramId = userId;
        user.provider = 'instagram';
        user.isEmailVerified = true; // Instagram accounts are considered verified
        if (!user.profileImage && profilePicture) {
          user.profileImage = profilePicture;
        }
        await user.save();
        wasAccountLinked = true;

        // Notification de compte OAuth associé
        if (hadMultipleMethods) {
          await notificationService.sendOAuthAccountLinkedNotification(
            user._id.toString(),
            'instagram'
          );
        } else {
          await notificationService.sendNewOAuthProviderAddedNotification(
            user._id.toString(),
            'instagram',
            ['local']
          );
        }
      }

      // Notification de connexion OAuth réussie
      await notificationService.sendOAuthLoginSuccessNotification(
        user._id.toString(),
        'instagram',
        req.get('User-Agent') || 'Mobile App',
        new Date()
      );
    } else {
      // Créer un nouvel utilisateur
      user = new User({
        username: username,
        email: email,
        instagramId: userId,
        profileImage: profilePicture,
        provider: 'instagram',
        isEmailVerified: true,
      });
      await user.save();
      isNewUser = true;

      // Notification de bienvenue OAuth
      await notificationService.sendOAuthWelcomeNotification(
        user._id.toString(),
        'instagram',
        true
      );

      // Notification de vérification email automatique
      await notificationService.sendOAuthEmailVerificationNotification(
        user._id.toString(),
        'instagram'
      );
    }

    // Générer un token JWT
    const token = authService.generateToken({
      id: user._id.toString(),
      email: user.email,
      username: user.username,
      isAdmin: user.isAdmin || false
    });

    res.status(200).json({
      success: true,
      token,
      user: formatUserResponse(user),
    });
  } catch (error) {
    logger.error(`Erreur Mobile Instagram Auth: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};

// Update FCM Token
export const updateFCMToken = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { fcmToken } = req.body;
    const userId = (req as any).user?.id;

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Utilisateur non authentifié',
      });
    }

    if (!fcmToken) {
      return res.status(400).json({
        success: false,
        message: 'Token FCM requis',
      });
    }

    await notificationService.updateUserFCMToken(userId, fcmToken);

    res.status(200).json({
      success: true,
      message: 'Token FCM mis à jour avec succès',
    });
  } catch (error) {
    logger.error(`Erreur mise à jour FCM token: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};

// Remove FCM Token (logout)
export const removeFCMToken = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = (req as any).user?.id;

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Utilisateur non authentifié',
      });
    }

    await notificationService.removeUserFCMToken(userId);

    res.status(200).json({
      success: true,
      message: 'Token FCM supprimé avec succès',
    });
  } catch (error) {
    logger.error(`Erreur suppression FCM token: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};

// Test OAuth Notifications (Development only)
export const testOAuthNotifications = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (process.env.NODE_ENV === 'production') {
      return res.status(403).json({
        success: false,
        message: 'Endpoint de test non disponible en production',
      });
    }

    const { userId, notificationType, provider } = req.body;

    if (!userId || !notificationType || !provider) {
      return res.status(400).json({
        success: false,
        message: 'userId, notificationType et provider requis',
      });
    }

    // Test different OAuth notification types
    switch (notificationType) {
      case 'login_success':
        await notificationService.sendOAuthLoginSuccessNotification(
          userId,
          provider,
          'Test Device',
          new Date()
        );
        break;
      case 'account_linked':
        await notificationService.sendOAuthAccountLinkedNotification(userId, provider);
        break;
      case 'welcome':
        await notificationService.sendOAuthWelcomeNotification(userId, provider, true);
        break;
      case 'email_verified':
        await notificationService.sendOAuthEmailVerificationNotification(userId, provider);
        break;
      case 'security_alert':
        await notificationService.sendOAuthSecurityAlertNotification(
          userId,
          'new_device',
          provider,
          { location: 'Test Location', ip: '192.168.1.1' }
        );
        break;
      default:
        return res.status(400).json({
          success: false,
          message: 'Type de notification non supporté',
        });
    }

    res.status(200).json({
      success: true,
      message: `Notification OAuth ${notificationType} envoyée avec succès`,
    });
  } catch (error) {
    logger.error(`Erreur test notification OAuth: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};
