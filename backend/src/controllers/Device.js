const asyncHandler = require('express-async-handler');
const DeviceToken = require('../models/DeviceToken');
const { sendToUsers } = require('../services/pushService');

// @desc    Registrar (o actualizar) el token FCM del dispositivo del usuario
// @route   POST /api/devices/register
// @access  Private
const registerDevice = asyncHandler(async (req, res) => {
  const token = String(req.body.token || '').trim();
  const platform = ['android', 'ios', 'web'].includes(req.body.platform)
    ? req.body.platform
    : 'android';

  if (token.length < 20) {
    res.status(400);
    throw new Error('El token del dispositivo no es válido');
  }

  // Si el token ya existía (otro usuario usó este teléfono), pasa al usuario actual.
  await DeviceToken.findOneAndUpdate(
    { token },
    { user: req.user._id, platform, lastUsedAt: new Date() },
    { upsert: true, new: true, setDefaultsOnInsert: true }
  );

  res.json({ success: true, message: 'Dispositivo registrado' });
});

// @desc    Quitar el token del dispositivo (al cerrar sesión)
// @route   POST /api/devices/unregister
// @access  Private
const unregisterDevice = asyncHandler(async (req, res) => {
  const token = String(req.body.token || '').trim();
  if (token) {
    await DeviceToken.deleteOne({ token, user: req.user._id });
  }
  res.json({ success: true, message: 'Dispositivo eliminado' });
});

// @desc    Enviar una notificación de prueba a MIS dispositivos
// @route   POST /api/devices/test
// @access  Private
const sendTestPush = asyncHandler(async (req, res) => {
  const result = await sendToUsers([req.user._id], {
    title: '🔔 Prueba SAN TV',
    body: 'Si ves esto, las notificaciones push funcionan.',
    data: { type: 'system', actionUrl: '' },
  });

  if (!result.enabled) {
    res.status(503);
    throw new Error('Firebase no está configurado en el servidor');
  }

  res.json({ success: true, ...result });
});

module.exports = { registerDevice, unregisterDevice, sendTestPush };
