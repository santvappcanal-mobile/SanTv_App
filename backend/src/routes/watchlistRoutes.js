const express = require('express');
const router = express.Router();
const {
  getMyWatchlist,
  getMyWatchlistIds,
  addToWatchlist,
  removeFromWatchlist,
  registerViewed,
  getMyStats,
} = require('../controllers/Watchlist');
const { protect } = require('../middleware/auth');

// DIAGNÓSTICO (borrar después): muestra toda petición que llega a /api/watchlist
router.use((req, res, next) => {
  console.log('WATCHLIST ->', req.method, req.originalUrl);
  next();
});

// Todas las rutas requieren sesión
router.use(protect);

// IMPORTANTE: las rutas fijas (/ids, /stats, /viewed/:contentId)
// van ANTES de /:contentId, si no Express las confunde con un id.
router.get('/', getMyWatchlist);
router.get('/ids', getMyWatchlistIds);
router.get('/stats', getMyStats);
router.post('/viewed/:contentId', registerViewed);

router.post('/:contentId', addToWatchlist);
router.delete('/:contentId', removeFromWatchlist);

module.exports = router;