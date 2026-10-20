const Notification = require('../models/Notification');

// Crea una notificación para un usuario. Si falla, no rompe el flujo de pago.
// AJUSTA los campos si tu modelo Notification usa otros nombres.
async function notifyUser(userId, title, message) {
  try {
    await Notification.create({
      user: userId,
      title,
      message,
      type: 'info',
    });
  } catch (err) {
    console.error('No se pudo crear la notificación:', err.message);
  }
}

module.exports = { notifyUser };
