const express = require('express');
const router = express.Router();
const {
  createLiveEvent,
  getLiveEvents,
  getActiveLiveEvents,
  getLiveEventById,
  startLiveEvent,
  endLiveEvent,
  updateViewersCount,
  updateLiveEvent,
  deleteLiveEvent,
} = require('../controllers/LiveEvent');
const { protect, authorize } = require('../middleware/auth');

// Rutas públicas
router.get('/', getLiveEvents);
router.get('/active', getActiveLiveEvents);
router.get('/:id', getLiveEventById);
router.put('/:id/viewers', updateViewersCount);

// Rutas privadas (solo editor o admin)
router.post('/', protect, authorize('editor', 'admin'), createLiveEvent);
router.put('/:id/start', protect, authorize('editor', 'admin'), startLiveEvent);
router.put('/:id/end', protect, authorize('editor', 'admin'), endLiveEvent);
router.put('/:id', protect, authorize('editor', 'admin'), updateLiveEvent);
router.delete('/:id', protect, authorize('editor', 'admin'), deleteLiveEvent);

module.exports = router;