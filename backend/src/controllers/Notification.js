const asyncHandler = require('express-async-handler');
const Notification = require('../models/Notification');

// @desc    Crear notificación para un usuario
// @route   POST /api/notifications
// @access  Private/Admin
const createNotification = asyncHandler(async (req, res) => {
  const { user, title, message, type, relatedContent, relatedModel } = req.body;

  if (!user || !title || !message) {
    res.status(400);
    throw new Error('user, title y message son obligatorios');
  }

  const notification = await Notification.create({
    user,
    title,
    message,
    type,
    relatedContent,
    relatedModel,
  });

  res.status(201).json({ success: true, data: notification });
});

// @desc    Crear notificación masiva para varios usuarios
// @route   POST /api/notifications/broadcast
// @access  Private/Admin
const broadcastNotification = asyncHandler(async (req, res) => {
  const { userIds, title, message, type } = req.body;

  if (!userIds || !Array.isArray(userIds) || userIds.length === 0 || !title || !message) {
    res.status(400);
    throw new Error('userIds (array), title y message son obligatorios');
  }

  const docs = userIds.map((userId) => ({ user: userId, title, message, type }));
  const notifications = await Notification.insertMany(docs);

  res.status(201).json({ success: true, count: notifications.length, data: notifications });
});

// @desc    Obtener notificaciones del usuario autenticado
// @route   GET /api/notifications
// @access  Private
const getUserNotifications = asyncHandler(async (req, res) => {
  const filter = { user: req.user._id };
  if (req.query.isRead !== undefined) filter.isRead = req.query.isRead === 'true';

  const notifications = await Notification.find(filter).sort({ createdAt: -1 });
  const unreadCount = await Notification.countDocuments({ user: req.user._id, isRead: false });

  res.json({ success: true, count: notifications.length, unreadCount, data: notifications });
});

// @desc    Marcar notificación como leída
// @route   PUT /api/notifications/:id/read
// @access  Private
const markAsRead = asyncHandler(async (req, res) => {
  const notification = await Notification.findOne({ _id: req.params.id, user: req.user._id });

  if (!notification) {
    res.status(404);
    throw new Error('Notificación no encontrada');
  }

  notification.isRead = true;
  await notification.save();

  res.json({ success: true, data: notification });
});

// @desc    Marcar todas las notificaciones del usuario como leídas
// @route   PUT /api/notifications/read-all
// @access  Private
const markAllAsRead = asyncHandler(async (req, res) => {
  await Notification.updateMany({ user: req.user._id, isRead: false }, { isRead: true });
  res.json({ success: true, message: 'Todas las notificaciones marcadas como leídas' });
});

// @desc    Eliminar notificación
// @route   DELETE /api/notifications/:id
// @access  Private
const deleteNotification = asyncHandler(async (req, res) => {
  const notification = await Notification.findOne({ _id: req.params.id, user: req.user._id });

  if (!notification) {
    res.status(404);
    throw new Error('Notificación no encontrada');
  }

  await notification.deleteOne();
  res.json({ success: true, message: 'Notificación eliminada correctamente' });
});

module.exports = {
  createNotification,
  broadcastNotification,
  getUserNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification,
};
