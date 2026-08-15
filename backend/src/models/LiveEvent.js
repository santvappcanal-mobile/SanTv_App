const mongoose = require('mongoose');

const liveEventSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'El título del evento es obligatorio'],
      trim: true,
    },
    description: {
      type: String,
      required: [true, 'La descripción es obligatoria'],
    },
    streamUrl: {
      type: String,
      required: [true, 'La URL de transmisión (stream) es obligatoria'],
    },
    thumbnailUrl: {
      type: String,
      default: '', // Póster promocional del evento
    },
    status: {
      type: String,
      enum: ['scheduled', 'live', 'ended'], // Estados del evento
      default: 'scheduled',
    },
    scheduledStartTime: {
      type: Date,
      required: [true, 'La fecha y hora programada de inicio es obligatoria'],
    },
    actualStartTime: {
      type: Date, // Cuándo empezó realmente la transmisión
    },
    endTime: {
      type: Date, // Cuándo finalizó
    },
    isPremium: {
      type: Boolean,
      default: false, // Si es exclusivo para suscripciones de pago
    },
    currentViewers: {
      type: Number,
      default: 0, // Espectadores simultáneos actuales
    },
    totalViews: {
      type: Number,
      default: 0, // Total de personas que entraron al stream
    }
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('LiveEvent', liveEventSchema);