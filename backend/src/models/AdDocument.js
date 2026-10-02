const mongoose = require('mongoose');

const adDocumentSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'El título del documento es obligatorio'],
      trim: true,
    },
    mediaUrl: {
      type: String,
      required: [true, 'La URL del documento es obligatoria'],
    },
    publicId: {
      type: String,
      default: '',
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('AdDocument', adDocumentSchema);
