import mongoose, { Document, Schema } from 'mongoose';

export interface IConversation extends Document {
  participants: Schema.Types.ObjectId[];
  listingId: Schema.Types.ObjectId;
  lastMessage: Schema.Types.ObjectId;
  updatedAt: Date;
  createdAt: Date;
}

const conversationSchema = new Schema<IConversation>(
  {
    participants: [{
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true
    }],
    listingId: {
      type: Schema.Types.ObjectId,
      ref: 'Listing',
      required: true
    },
    lastMessage: {
      type: Schema.Types.ObjectId,
      ref: 'Message'
    }
  },
  {
    timestamps: true
  }
);

export default mongoose.model<IConversation>('Conversation', conversationSchema);
