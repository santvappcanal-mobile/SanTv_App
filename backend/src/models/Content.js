const mongoose = require('mongoose');

const contentSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'El título del contenido es obligatorio'],
      trim: true,
    },
    description: {
      type: String,
      required: [true, 'La descripción es obligatoria'],
    },
    type: {
      type: String,
      enum: ['movie', 'series', 'documentary'], // Tipos de contenido
      required: [true, 'El tipo de contenido es obligatorio'],
    },
    genres: [
      {
        type: String,
        trim: true, // Ej: ['Acción', 'Drama', 'Sci-Fi']
      },
    ],
    videoUrl: {
      type: String,
      required: [true, 'La URL del video es obligatoria'],
    },
    thumbnailUrl: {
      type: String,
      default: '', // Imagen de miniatura o póster
    },
    duration: {
      type: Number,
      default: 0, // Duración en minutos
    },
    releaseYear: {
      type: Number,
    },
    isPremium: {
      type: Boolean,
      default: false, // Si es 'true', solo usuarios con subscriptionPlan 'premium' o 'pro' pueden verlo
    },
    isActive: {
      type: Boolean,
      default: true, // Permite ocultar el contenido sin borrarlo de la base de datos
    },
    views: {
      type: Number,
      default: 0, // Contador de reproducciones
    }
  },
  {
    timestamps: true, // Añade createdAt y updatedAt
  }
);

module.exports = mongoose.model('Content', contentSchema);