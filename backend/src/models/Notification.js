const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User', // Referencia al modelo User
      required: [true, 'El usuario destinatario es obligatorio'],
    },
    title: {
      type: String,
      required: [true, 'El título de la notificación es obligatorio'],
      trim: true,
    },
    message: {
      type: String,
      required: [true, 'El mensaje es obligatorio'],
    },
    type: {
      type: String,
      enum: [
        'system',
        'new_content',
        'live_event',
        'billing',
        'promo',
        // Mi comunidad cuenta
        'report_pending', // a los admins: llegó un reporte nuevo por revisar
        'report_approved', // al autor: su reporte fue aceptado
        'community_report', // a todos: nuevo reporte publicado
      ],
      default: 'system',
    },
    isRead: {
      type: Boolean,
      default: false, // Por defecto, la notificación nace como "no leída"
    },
    actionUrl: {
      type: String,
      default: '', // URL opcional para redirigir al usuario al hacer clic (ej. '/content/123')
    },
    // Datos para abrir la pantalla correcta al tocarla (contentId, orderId, reportId, forAdmin...)
    data: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
  },
  {
    timestamps: true, // Esto crea 'createdAt', ideal para ordenar de la más nueva a la más antigua
  }
);

module.exports = mongoose.model('Notification', notificationSchema);