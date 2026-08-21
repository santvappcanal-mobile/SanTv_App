const express = require('express');
const router = express.Router();
const {
  createAd,
  getAds,
  getAdsForContent,
  getAdById,
  registerImpression,
  registerClick,
  updateAd,
  deleteAd,
} = require('../controllers/Ad');
const { protect, authorize } = require('../middleware/auth');

// Rutas públicas
router.get('/for-content/:contentId', getAdsForContent);
router.put('/:id/impression', registerImpression);
router.put('/:id/click', registerClick);

// Rutas privadas (solo admin)
router.get('/', protect, authorize('admin'), getAds);
router.get('/:id', protect, authorize('admin'), getAdById);
router.post('/', protect, authorize('admin'), createAd);
router.put('/:id', protect, authorize('admin'), updateAd);
router.delete('/:id', protect, authorize('admin'), deleteAd);

module.exports = router;