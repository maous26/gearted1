import passport from 'passport';
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';
import { Strategy as FacebookStrategy } from 'passport-facebook';
import User from '../models/user.model';
import { logger } from '../utils/logger';

// Configuration Google OAuth - seulement si les variables d'environnement sont présentes
if (process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET) {
  passport.use(
    new GoogleStrategy(
      {
        clientID: process.env.GOOGLE_CLIENT_ID,
        clientSecret: process.env.GOOGLE_CLIENT_SECRET,
        callbackURL: '/api/auth/google/callback',
      },
      async (accessToken, refreshToken, profile, done) => {
        try {
          // Vérifier si l'utilisateur existe déjà
          let user = await User.findOne({ 
            $or: [
              { googleId: profile.id },
              { email: profile.emails?.[0]?.value }
            ]
          });

          if (user) {
            // Si l'utilisateur existe mais n'a pas de googleId, l'ajouter
            if (!user.googleId) {
              user.googleId = profile.id;
              user.provider = 'google';
              if (!user.profileImage && profile.photos?.[0]?.value) {
                user.profileImage = profile.photos[0].value;
              }
              await user.save();
            }
            return done(null, user);
          } else {
            // Créer un nouvel utilisateur
            const newUser = new User({
              googleId: profile.id,
              username: profile.displayName || profile.emails?.[0]?.value?.split('@')[0] || 'user',
              email: profile.emails?.[0]?.value,
              profileImage: profile.photos?.[0]?.value,
              provider: 'google',
              isEmailVerified: true,
            });

            await newUser.save();
            return done(null, newUser);
          }
        } catch (error) {
          logger.error(`Erreur Google OAuth: ${error instanceof Error ? error.message : String(error)}`);
          return done(error as Error, false);
        }
      }
    )
  );
} else {
  logger.warn('Google OAuth non configuré - GOOGLE_CLIENT_ID et GOOGLE_CLIENT_SECRET manquants');
}

// Configuration Facebook OAuth - seulement si les variables d'environnement sont présentes
if (process.env.FACEBOOK_APP_ID && process.env.FACEBOOK_APP_SECRET) {
  passport.use(
    new FacebookStrategy(
      {
        clientID: process.env.FACEBOOK_APP_ID,
        clientSecret: process.env.FACEBOOK_APP_SECRET,
        callbackURL: '/api/auth/facebook/callback',
        profileFields: ['id', 'displayName', 'email', 'photos'],
      },
      async (accessToken, refreshToken, profile, done) => {
        try {
          // Vérifier si l'utilisateur existe déjà
          let user = await User.findOne({ 
            $or: [
              { facebookId: profile.id },
              { email: profile.emails?.[0]?.value }
            ]
          });

          if (user) {
            // Si l'utilisateur existe mais n'a pas de facebookId, l'ajouter
            if (!user.facebookId) {
              user.facebookId = profile.id;
              user.provider = 'facebook';
              if (!user.profileImage && profile.photos?.[0]?.value) {
                user.profileImage = profile.photos[0].value;
              }
              await user.save();
            }
            return done(null, user);
          } else {
            // Créer un nouvel utilisateur
            const newUser = new User({
              facebookId: profile.id,
              username: profile.displayName || profile.emails?.[0]?.value?.split('@')[0] || 'user',
              email: profile.emails?.[0]?.value,
              profileImage: profile.photos?.[0]?.value,
              provider: 'facebook',
              isEmailVerified: true,
            });

            await newUser.save();
            return done(null, newUser);
          }
        } catch (error) {
          logger.error(`Erreur Facebook OAuth: ${error instanceof Error ? error.message : String(error)}`);
          return done(error as Error, false);
        }
      }
    )
  );
} else {
  logger.warn('Facebook OAuth non configuré - FACEBOOK_APP_ID et FACEBOOK_APP_SECRET manquants');
}

// Sérialisation et désérialisation des utilisateurs
passport.serializeUser((user: any, done) => {
  done(null, user._id);
});

passport.deserializeUser(async (id: string, done) => {
  try {
    const user = await User.findById(id);
    done(null, user);
  } catch (error) {
    done(error as Error, false);
  }
});

export default passport;
