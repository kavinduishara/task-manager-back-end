import mongoose,{Schema} from "mongoose";

const taskSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },

    description: {
      type: String,
      required: true,
    },

    status: {
      type: String,
      required: true,
      enum: ['TODO', 'IN_PROGRESS', 'DONE'],
      default: 'TODO',
    },

    creator: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    assignee: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: false,
    },

    dueDate: {
      type: Date,
      required: false,
    },
  },
  {
    timestamps: true,
  }
);

export default mongoose.model('Task', taskSchema);