const mongoose = require('mongoose');

// Historial de videos vistos: un documento por usuario + video.
// Sirve para (1) el contador "Vistos" del perfil y
// (2) sumar la vista pública solo la primera vez que cada usuario ve un video.
const watchHistorySchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'El usuario es obligatorio'],
    },
    content: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Content',
      required: [true, 'El contenido es obligatorio'],
    },
    firstViewedAt: {
      type: Date,
      default: Date.now,
    },
    lastViewedAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: false }
);

// Un usuario solo puede tener un registro por video
watchHistorySchema.index({ user: 1, content: 1 }, { unique: true });

module.exports = mongoose.model('WatchHistory', watchHistorySchema);