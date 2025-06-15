import * as admin from 'firebase-admin';
import { logger } from '../utils/logger';

// Initialiser Firebase Admin si pas déjà fait
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\n/g, '\n')
    }),
  });
}

export enum NotificationType {
  NEW_MESSAGE = 'new_message',
  NEW_OFFER = 'new_offer',
  LISTING_SOLD = 'listing_sold',
  NEW_REVIEW = 'new_review'
}

export const sendPushNotification = async (
  userId: string,
  title: string,
  body: string,
  type: NotificationType,
  data: Record<string, string> = {}
): Promise<void> => {
  try {
    // Dans un cas réel, vous récupéreriez le token FCM de l'utilisateur depuis la base de données
    // const user = await User.findById(userId);
    // if (!user || !user.fcmToken) return;
    
    // Pour la démo, on suppose qu'on a un token
    const fcmToken = 'user_fcm_token_here';
    
    const message = {
      notification: {
        title,
        body
      },
      data: {
        ...data,
        type
      },
      token: fcmToken
    };
    
    await admin.messaging().send(message);
    logger.info(`Notification envoyée à l'utilisateur ${userId}`);
  } catch (error) {
    logger.error(`Erreur lors de l'envoi de la notification: ${error instanceof Error ? error.message : String(error)}`);
  }
};
