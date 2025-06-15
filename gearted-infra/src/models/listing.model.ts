import mongoose, { Document, Schema } from 'mongoose';

export enum ListingCondition {
  NEW = 'new',
  VERY_GOOD = 'veryGood',
  GOOD = 'good',
  ACCEPTABLE = 'acceptable',
  FOR_REPAIR = 'forRepair',
}

export interface IListing extends Document {
  title: string;
  description: string;
  price: number;
  sellerId: Schema.Types.ObjectId;
  imageUrls: string[];
  condition: ListingCondition;
  category: string;
  subcategory: string;
  tags: string[];
  isExchangeable: boolean;
  isSold: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const listingSchema = new Schema<IListing>(
  {
    title: {
      type: String,
      required: [true, 'Le titre est requis'],
      trim: true,
      maxlength: [100, 'Le titre ne peut pas dépasser 100 caractères'],
    },
    description: {
      type: String,
      required: [true, 'La description est requise'],
      trim: true,
    },
    price: {
      type: Number,
      required: [true, 'Le prix est requis'],
      min: [0, 'Le prix doit être positif'],
    },
    sellerId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Le vendeur est requis'],
    },
    imageUrls: {
      type: [String],
      required: [true, 'Au moins une image est requise'],
    },
    condition: {
      type: String,
      enum: Object.values(ListingCondition),
      required: [true, 'L\'état est requis'],
    },
    category: {
      type: String,
      required: [true, 'La catégorie est requise'],
      trim: true,
    },
    subcategory: {
      type: String,
      required: [true, 'La sous-catégorie est requise'],
      trim: true,
    },
    tags: {
      type: [String],
      default: [],
    },
    isExchangeable: {
      type: Boolean,
      default: false,
    },
    isSold: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Index pour la recherche
listingSchema.index({ title: 'text', description: 'text', tags: 'text' });

export default mongoose.model<IListing>('Listing', listingSchema);
