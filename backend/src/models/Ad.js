const mongoose = require('mongoose');

const adSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'El título del anuncio es obligatorio'],
      trim: true,
    },
    type: {
      type: String,
      enum: ['video', 'banner', 'popup'], // Tipos de anuncios típicos en apps de TV/Streaming
      default: 'video',
      required: [true, 'El tipo de anuncio es obligatorio'],
    },
    mediaUrl: {
      type: String,
      required: [true, 'La URL del recurso multimedia (video o imagen) es obligatoria'],
    },
    targetUrl: {
      type: String,
      trim: true,
      description: 'URL a la que el usuario será redirigido al hacer clic',
    },
    duration: {
      type: Number,
      default: 0, // Duración en segundos (útil si el tipo es 'video')
    },
    isActive: {
      type: Boolean,
      default: true, // Permite activar o desactivar el anuncio temporalmente
    },
    startDate: {
      type: Date,
      default: Date.now, // Cuándo empieza la campaña del anuncio
    },
    endDate: {
      type: Date, // Cuándo termina la campaña del anuncio
    },
    // Estadísticas básicas
    impressions: {
      type: Number,
      default: 0, // Cantidad de veces que se ha mostrado
    },
    clicks: {
      type: Number,
      default: 0, // Cantidad de veces que los usuarios han hecho clic
    }
  },
  {
    timestamps: true, // Añade automáticamente 'createdAt' y 'updatedAt'
  }
);

module.exports = mongoose.model('Ad', adSchema);