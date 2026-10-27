const mongoose = require('mongoose');

const CATEGORIES = ['Noticias', 'Deportes', 'Educación', 'Comunidad'];

const reportSchema = new mongoose.Schema(
  {
    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    title: { type: String, required: true, trim: true, minlength: 5, maxlength: 120 },
    description: { type: String, required: true, trim: true, minlength: 10, maxlength: 1000 },
    category: { type: String, enum: CATEGORIES, default: 'Noticias' },

    imageUrl: { type: String, required: true },
    imagePublicId: { type: String },

    latitude: { type: Number, required: true, min: -90, max: 90 },
    longitude: { type: Number, required: true, min: -180, max: 180 },
    address: { type: String, trim: true, maxlength: 200 },

    status: {
      type: String,
      enum: ['pending', 'approved', 'rejected'],
      default: 'pending',
      index: true,
    },
    rejectionReason: { type: String, trim: true, maxlength: 300 },
    reviewedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    reviewedAt: { type: Date },

    // Noticia publicada en la colección Content al aprobar
    publishedContent: { type: mongoose.Schema.Types.ObjectId, ref: 'Content' },

    // Resultado del análisis de la IA (Groq)
    ai: {
      analyzed: { type: Boolean, default: false },
      suggestedTitle: String,
      summary: String,
      suggestedCategory: String,
      suspicionScore: { type: Number, min: 0, max: 100 },
      suspicionReason: String,
    },

    // Reportes cercanos (≈1 km) de las últimas 24 h
    nearbyReports: { type: Number, default: 0 },
    possibleDuplicateOf: { type: mongoose.Schema.Types.ObjectId, ref: 'Report' },
  },
  { timestamps: true }
);

reportSchema.index({ status: 1, createdAt: -1 });
reportSchema.index({ latitude: 1, longitude: 1 });

reportSchema.statics.CATEGORIES = CATEGORIES;

module.exports = mongoose.model('Report', reportSchema);
