const Notification = require('../models/Notification');
const User = require('../models/User');
const { sendToUsers } = require('../services/pushService');

// Crea una notificación para un usuario (bandeja de la app) y además le envía
// un push a sus dispositivos. Si algo falla, no rompe el flujo de pago.
// [orderId] permite que al tocarla la app abra ese pedido.
async function notifyUser(userId, title, message, { orderId } = {}) {
  const extra = { forAdmin: 'false' };
  if (orderId) extra.orderId = String(orderId);

  try {
    await Notification.create({
      user: userId,
      title,
      message,
      type: 'billing', // 'info' no existe en el enum del modelo Notification
      actionUrl: '/ad-orders',
      data: extra,
    });
  } catch (err) {
    console.error('No se pudo crear la notificación:', err.message);
  }

  try {
    await sendToUsers([userId], {
      title,
      body: message,
      data: { type: 'billing', actionUrl: '/ad-orders', ...extra },
    });
  } catch (err) {
    console.error('No se pudo enviar el push:', err.message);
  }
}

// Avisa a todos los administradores activos (bandeja + push), por ejemplo
// cuando alguien solicita una pauta. [exceptUserId] evita avisarle al propio
// admin si fue él quien hizo la solicitud. Nunca lanza errores.
async function notifyAdmins(title, message, { exceptUserId, orderId } = {}) {
  try {
    const filter = { role: 'admin', isActive: { $ne: false } };
    if (exceptUserId) filter._id = { $ne: exceptUserId };

    const admins = await User.find(filter).select('_id').lean();
    if (admins.length === 0) return;
    const ids = admins.map((a) => a._id);

    // forAdmin hace que la app abra la lista de solicitudes como administrador
    const extra = { forAdmin: 'true' };
    if (orderId) extra.orderId = String(orderId);

    await Notification.insertMany(
      ids.map((id) => ({
        user: id,
        title,
        message,
        type: 'billing',
        actionUrl: '/ad-orders',
        data: extra,
      })),
      { ordered: false }
    ).catch((err) => console.error('No se pudo crear la notificación al admin:', err.message));

    await sendToUsers(ids, {
      title,
      body: message,
      data: { type: 'billing', actionUrl: '/ad-orders', ...extra },
    });
  } catch (err) {
    console.error('No se pudo avisar a los administradores:', err.message);
  }
}

module.exports = { notifyUser, notifyAdmins };