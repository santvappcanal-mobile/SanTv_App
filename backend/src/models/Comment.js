const mongoose = require('mongoose');

const commentSchema = new mongoose.Schema(
  {
    content: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Content',
      required: true,
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    text: {
      type: String,
      required: [true, 'El comentario no puede estar vacío'],
      trim: true,
      maxlength: [500, 'El comentario no puede superar los 500 caracteres'],
    },
  },
  {
    timestamps: true,
  }
);

// Para traer rápido los comentarios de un video, del más nuevo al más viejo
commentSchema.index({ content: 1, createdAt: -1 });

module.exports = mongoose.model('Comment', commentSchema);