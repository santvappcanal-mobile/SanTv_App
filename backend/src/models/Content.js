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
      // Obligatoria, salvo en las noticias que nacen de un reporte ciudadano (solo foto)
      required: [
        function () {
          return !this.reportId;
        },
        'La URL del video es obligatoria',
      ],
      default: '',
    },
    videoPublicId: {
      type: String,
      default: '', // ID de Cloudinary del video, necesario para poder eliminarlo
    },
    thumbnailUrl: {
      type: String,
      default: '', // Imagen de miniatura o póster
    },
    thumbnailPublicId: {
      type: String,
      default: '', // ID de Cloudinary del thumbnail, necesario para poder eliminarlo
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
    showInLive: {
      type: Boolean,
      default: false, // Si es 'true', también aparece en la pestaña "En vivo" de la app
    },
    views: {
      type: Number,
      default: 0, // Contador de reproducciones
    },

    // --- REPORTERO CIUDADANO ---
    // Solo se llenan cuando la noticia nació de un reporte aprobado
    reportId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Report',
      default: undefined,
    },
    reportedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: undefined,
    },
  },
  {
    timestamps: true, // Añade createdAt y updatedAt
  }
);

// Al eliminar un video (content.deleteOne()) también se borran sus comentarios.
contentSchema.post('deleteOne', { document: true, query: false }, async function () {
  await mongoose.model('Comment').deleteMany({ content: this._id });
});

module.exports = mongoose.model('Content', contentSchema);