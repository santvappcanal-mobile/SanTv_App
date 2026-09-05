const mongoose = require('mongoose');

const adSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    type: {
      type: String,
      enum: ['video', 'banner', 'popup'],
      required: true,
    },
    mediaUrl: {
      type: String,
      required: true,
    },
    targetUrl: {
      type: String,
    },
    duration: {
      // duración en segundos, aplica principalmente a type: 'video'
      type: Number,
    },
    startDate: {
      type: Date,
      required: true,
    },
    endDate: {
      // no es obligatorio: un anuncio puede quedar activo indefinidamente
      type: Date,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    impressions: {
      type: Number,
      default: 0,
    },
    clicks: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Ad', adSchema);