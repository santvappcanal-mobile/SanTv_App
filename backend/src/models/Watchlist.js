const mongoose = require('mongoose');

const watchlistSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User', // Relación con el usuario dueño de la lista
      required: [true, 'El usuario es obligatorio para la watchlist'],
    },
    content: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Content', // Relación con la película/serie guardada
      required: [true, 'El contenido es obligatorio'],
    },
    addedAt: {
      type: Date,
      default: Date.now, // Útil para ordenar la lista de "agregados recientemente"
    }
  },
  {
    // Usualmente no necesitamos timestamps completos aquí, 
    // pero podemos dejar que Mongoose maneje el _id
    timestamps: false 
  }
);

// Índice compuesto para evitar que un usuario agregue la misma película dos veces
watchlistSchema.index({ user: 1, content: 1 }, { unique: true });

module.exports = mongoose.model('Watchlist', watchlistSchema);