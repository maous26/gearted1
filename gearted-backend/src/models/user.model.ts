import mongoose, { Document, Schema } from 'mongoose';
import * as bcrypt from 'bcrypt';

export interface IUser extends Document {
  username: string;
  email: string;
  password?: string;
  profileImage?: string;
  rating: number;
  salesCount: number;
  googleId?: string;
  facebookId?: string;
  instagramId?: string;
  provider: 'local' | 'google' | 'facebook' | 'instagram';
  isEmailVerified: boolean;
  isAdmin?: boolean;
  fcmToken?: string;
  comparePassword(candidatePassword: string): Promise<boolean>;
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUser>(
  {
    username: {
      type: String,
      required: [true, 'Le nom d\'utilisateur est requis'],
      unique: true,
      trim: true,
    },
    email: {
      type: String,
      required: [true, 'L\'email est requis'],
      unique: true,
      trim: true,
      lowercase: true,
    },
    password: {
      type: String,
      required: function(this: IUser) {
        return this.provider === 'local';
      },
      minlength: [6, 'Le mot de passe doit contenir au moins 6 caractères'],
      select: false,
    },
    profileImage: {
      type: String,
      default: null,
    },
    rating: {
      type: Number,
      default: 0,
    },
    salesCount: {
      type: Number,
      default: 0,
    },
    googleId: {
      type: String,
      unique: true,
      sparse: true,
    },
    facebookId: {
      type: String,
      unique: true,
      sparse: true,
    },
    instagramId: {
      type: String,
      unique: true,
      sparse: true,
    },
    provider: {
      type: String,
      enum: ['local', 'google', 'facebook', 'instagram'],
      default: 'local',
    },
    isEmailVerified: {
      type: Boolean,
      default: false,
    },
    isAdmin: {
      type: Boolean,
      default: false,
    },
    fcmToken: {
      type: String,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

// Hashage du mot de passe avant sauvegarde
userSchema.pre<IUser>('save', async function(next) {
  if (!this.isModified('password') || !this.password) return next();

  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error: any) {
    next(error);
  }
});

// Méthode pour comparer les mots de passe
userSchema.methods.comparePassword = async function(candidatePassword: string): Promise<boolean> {
  try {
    if (!this.password) {
      throw new Error('Aucun mot de passe défini pour cet utilisateur');
    }
    return await bcrypt.compare(candidatePassword, this.password);
  } catch (error) {
    throw new Error(error as any);
  }
};

export default mongoose.model<IUser>('User', userSchema);
