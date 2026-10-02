const express = require('express');
const router = express.Router();
const {
  getLiveStatus,
  startLive,
  endLive,
} = require('../controllers/LiveChannel');
const { protect, authorize } = require('../middleware/auth');

router.get('/status', getLiveStatus);
router.post('/start', protect, authorize('editor', 'admin'), startLive);
router.post('/end', protect, authorize('editor', 'admin'), endLive);

module.exports = router;
