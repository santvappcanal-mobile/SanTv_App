const asyncHandler = require('express-async-handler');
const LiveChannelStatus = require('../models/LiveChannelStatus');
const Notification = require('../models/Notification');
const User = require('../models/User');

const getOrCreateStatus = async () => {
  let status = await LiveChannelStatus.findOne({ key: 'main' });
  if (!status) status = await LiveChannelStatus.create({ key: 'main' });
  return status;
};

// @desc    Estado actual del canal en vivo
// @route   GET /api/live-channel/status
// @access  Public
const getLiveStatus = asyncHandler(async (req, res) => {
  const status = await getOrCreateStatus();
  res.json({ success: true, data: status });
});

// @desc    Marcar el canal como EN VIVO y notificar a todos los usuarios
// @route   POST /api/live-channel/start
// @access  Private/Editor-Admin
const startLive = asyncHandler(async (req, res) => {
  const title = (req.body.title || '').trim() || '🔴 SAN TV está en vivo';
  const message =
    (req.body.message || '').trim() ||
    'Entra ahora y mira la transmisión en vivo.';

  const status = await getOrCreateStatus();
  if (status.isLive) {
    res.status(409);
    throw new Error('El canal ya está en vivo');
  }

  status.isLive = true;
  status.startedAt = new Date();
  status.title = title;
  await status.save();

  // Notificación guardada para cada usuario activo
  // ($ne:false incluye también usuarios viejos sin el campo isActive).
  const users = await User.find({ isActive: { $ne: false } })
    .select('_id')
    .lean();

  const docs = users.map((u) => ({
    user: u._id,
    title,
    message,
    type: 'live_event',
    actionUrl: '/live',
  }));
  if (docs.length > 0) {
    await Notification.insertMany(docs, { ordered: false });
  }

  // Aviso en tiempo real a quienes tienen la app abierta
  const io = req.app.get('io');
  if (io) {
    io.emit('live_started', { title, message, startedAt: status.startedAt });
  }

  res.status(201).json({
    success: true,
    notified: docs.length,
    data: status,
  });
});

// @desc    Marcar el canal como NO en vivo
// @route   POST /api/live-channel/end
// @access  Private/Editor-Admin
const endLive = asyncHandler(async (req, res) => {
  const status = await getOrCreateStatus();

  status.isLive = false;
  await status.save();

  const io = req.app.get('io');
  if (io) io.emit('live_ended', {});

  res.json({ success: true, data: status });
});

module.exports = { getLiveStatus, startLive, endLive };
