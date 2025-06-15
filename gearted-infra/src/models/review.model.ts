import mongoose, { Document, Schema } from 'mongoose';

export interface IReview extends Document {
  reviewerId: Schema.Types.ObjectId;
  receiverId: Schema.Types.ObjectId;
  listingId: Schema.Types.ObjectId;
  rating: number;
  comment: string;
  createdAt: Date;
}

const reviewSchema = new Schema<IReview>(
  {
    reviewerId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    receiverId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    listingId: {
      type: Schema.Types.ObjectId,
      ref: 'Listing',
      required: true
    },
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5
    },
    comment: {
      type: String,
      required: true,
      trim: true
    }
  },
  {
    timestamps: true
  }
);

// Empêcher les utilisateurs de s'évaluer eux-mêmes
reviewSchema.pre('save', function(next) {
  if (this.reviewerId.toString() === this.receiverId.toString()) {
    const err = new Error('Vous ne pouvez pas vous évaluer vous-même');
    return next(err);
  }
  next();
});

export default mongoose.model<IReview>('Review', reviewSchema);
