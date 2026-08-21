const express = require('express');
const router = express.Router();
const {
  addToWatchlist,
  getUserWatchlist,
  checkInWatchlist,
  updateProgress,
  removeFromWatchlist,
} = require('../controllers/Watchlist');
const { protect } = require('../middleware/auth');

// Toda la watchlist requiere estar autenticado
router.use(protect);

router.post('/', addToWatchlist);
router.get('/', getUserWatchlist);
router.get('/check/:contentId', checkInWatchlist);
router.put('/:id/progress', updateProgress);
router.delete('/:id', removeFromWatchlist);

module.exports = router;