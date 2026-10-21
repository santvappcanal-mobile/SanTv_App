const DeviceToken = require('../models/DeviceToken');
const Notification = require('../models/Notification');
const User = require('../models/User');
const { getMessaging } = require('../config/firebase');

// Debe coincidir con el canal que crea la app en MainActivity.kt
const ANDROID_CHANNEL_ID = 'santv_default';

// FCM permite máximo 500 tokens por envío
const BATCH_SIZE = 500;

// Códigos de error que indican que el token ya no sirve (app desinstalada, etc.)
const INVALID_TOKEN_CODES = [
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
];

// FCM exige que todos los valores de "data" sean texto
const toStringMap = (obj = {}) =>
  Object.fromEntries(
    Object.entries(obj)
      .filter(([, v]) => v !== undefined && v !== null)
      .map(([k, v]) => [k, String(v)])
  );

const chunk = (arr, size) => {
  const out = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
};

// Envía una notificación a una lista de tokens. Nunca lanza errores.
async function sendToTokens(tokens, { title, body, data, imageUrl }) {
  const result = { sent: 0, failed: 0, enabled: true };

  const messaging = getMessaging();
  if (!messaging) return { ...result, enabled: false };
  if (!tokens || tokens.length === 0) return result;

  const notification = { title, body };
  if (imageUrl && /^https:\/\//.test(imageUrl)) notification.imageUrl = imageUrl;

  const invalidTokens = [];

  for (const group of chunk([...new Set(tokens)], BATCH_SIZE)) {
    try {
      const response = await messaging.sendEachForMulticast({
        tokens: group,
        notification,
        data: toStringMap(data),
        android: {
          priority: 'high',
          notification: { channelId: ANDROID_CHANNEL_ID },
        },
        apns: { payload: { aps: { sound: 'default' } } },
      });

      response.responses.forEach((r, i) => {
        if (r.success) {
          result.sent += 1;
        } else {
          result.failed += 1;
          const code = r.error && r.error.code;
          if (INVALID_TOKEN_CODES.includes(code)) {
            invalidTokens.push(group[i]);
          } else {
            console.error('Error FCM:', code, r.error && r.error.message);
          }
        }
      });
    } catch (error) {
      result.failed += group.length;
      console.error('Error enviando lote FCM:', error.message);
    }
  }

  // Limpia los tokens muertos para no seguir intentando con ellos
  if (invalidTokens.length > 0) {
    await DeviceToken.deleteMany({ token: { $in: invalidTokens } }).catch(() => {});
  }

  return result;
}

// Push a usuarios concretos (todos sus dispositivos).
async function sendToUsers(userIds, payload) {
  try {
    const ids = (Array.isArray(userIds) ? userIds : [userIds]).filter(Boolean);
    if (ids.length === 0) return { sent: 0, failed: 0, enabled: true };

    const tokens = await DeviceToken.find({ user: { $in: ids } }).distinct('token');
    return await sendToTokens(tokens, payload);
  } catch (error) {
    console.error('sendToUsers falló:', error.message);
    return { sent: 0, failed: 0, enabled: true };
  }
}

// Push a todos los dispositivos de usuarios activos.
async function sendToAll(payload) {
  try {
    const inactiveIds = await User.find({ isActive: false }).distinct('_id');
    const tokens = await DeviceToken.find({ user: { $nin: inactiveIds } }).distinct('token');
    return await sendToTokens(tokens, payload);
  } catch (error) {
    console.error('sendToAll falló:', error.message);
    return { sent: 0, failed: 0, enabled: true };
  }
}

// Guarda la notificación en la bandeja de cada usuario activo (pantalla
// "Notificaciones" de la app) Y envía el push a sus dispositivos.
// "data" (contentId, etc.) se guarda también en la bandeja para que, al tocar
// la notificación dentro de la app, se pueda abrir la pantalla correcta.
async function notifyAllUsers({
  title,
  message,
  type = 'system',
  actionUrl = '',
  data = {},
  imageUrl,
}) {
  try {
    const users = await User.find({ isActive: { $ne: false } }).select('_id').lean();
    if (users.length > 0) {
      const storedData = toStringMap(data);
      await Notification.insertMany(
        users.map((u) => ({
          user: u._id,
          title,
          message,
          type,
          actionUrl,
          data: storedData,
        })),
        { ordered: false }
      );
    }
  } catch (error) {
    console.error('No se pudieron guardar las notificaciones:', error.message);
  }

  return sendToAll({
    title,
    body: message,
    data: { type, actionUrl, ...data },
    imageUrl,
  });
}

module.exports = { sendToTokens, sendToUsers, sendToAll, notifyAllUsers };