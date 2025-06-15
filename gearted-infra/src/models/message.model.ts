import mongoose, { Document, Schema } from 'mongoose';

export interface IMessage extends Document {
  conversationId: Schema.Types.ObjectId;
  sender: Schema.Types.ObjectId;
  content: string;
  isRead: boolean;
  createdAt: Date;
}

const messageSchema = new Schema<IMessage>(
  {
    conversationId: {
      type: Schema.Types.ObjectId,
      ref: 'Conversation',
      required: true
    },
    sender: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    content: {
      type: String,
      required: true,
      trim: true
    },
    isRead: {
      type: Boolean,
      default: false
    }
  },
  {
    timestamps: true
  }
);

export default mongoose.model<IMessage>('Message', messageSchema);
