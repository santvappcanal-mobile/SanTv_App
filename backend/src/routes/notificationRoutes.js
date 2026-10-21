const express = require('express');
const router = express.Router();
const {
  createNotification,
  broadcastNotification,
  getUserNotifications,
  markAsRead,
  markAllAsRead,
  deleteReadNotifications,
  deleteNotification,
} = require('../controllers/Notification');
const { protect, authorize } = require('../middleware/auth');

// Rutas privadas (usuario autenticado)
router.get('/', protect, getUserNotifications);
router.put('/read-all', protect, markAllAsRead);
router.put('/:id/read', protect, markAsRead);

// IMPORTANTE: '/read' debe ir ANTES de '/:id', si no Express toma "read" como un id.
router.delete('/read', protect, deleteReadNotifications);
router.delete('/:id', protect, deleteNotification);

// Rutas privadas (solo admin)
router.post('/', protect, authorize('admin'), createNotification);
router.post('/broadcast', protect, authorize('admin'), broadcastNotification);

module.exports = router;