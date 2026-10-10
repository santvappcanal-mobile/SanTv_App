const express = require('express');
const router = express.Router();
const {
  createAd,
  getAds,
  getAdsForContent,
  getAdPortfolio,
  getAdById,
  registerImpression,
  registerClick,
  updateAd,
  deleteAd,
  uploadAdDocument,
  getAdDocuments,
} = require('../controllers/Ad');
const { protect, authorize } = require('../middleware/auth');
const { uploadDocument, uploadImage } = require('../middleware/upload');
const { uploadAdImage, createImageAd } = require('../controllers/adImageController');
const { uploadGallery, getGallery } = require('../controllers/adGalleryController');

// Rutas públicas
router.get('/portfolio', getAdPortfolio);
router.get('/documents', getAdDocuments);
router.get('/gallery', getGallery);
router.get('/for-content', getAdsForContent);
router.put('/:id/impression', registerImpression);
router.put('/:id/click', registerClick);

// Rutas privadas (solo admin)
router.get('/', protect, authorize('admin'), getAds);
router.get('/:id', protect, authorize('admin'), getAdById);
router.post('/', protect, authorize('admin'), createAd);
router.post('/image', protect, authorize('admin'), uploadAdImage.single('imagen'), createImageAd);
router.post('/gallery', protect, authorize('admin'), uploadImage.array('imagenes', 10), uploadGallery);
router.post('/document', protect, authorize('admin'), uploadDocument.single('archivo'), uploadAdDocument);
router.put('/:id', protect, authorize('admin'), updateAd);
router.delete('/:id', protect, authorize('admin'), deleteAd);

module.exports = router;