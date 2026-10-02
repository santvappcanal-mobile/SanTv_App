const express = require('express');
const router = express.Router();
const {
  getYoutubePreview,
  createContentFromYoutube,
  createContent,
  getContents,
  getContentById,
  registerView,
  updateContent,
  deleteContent,
} = require('../controllers/Content');
const { protect, authorize } = require('../middleware/auth');

// Rutas públicas
router.get('/', getContents);

// Rutas fijas: SIEMPRE antes de las que usan /:id
router.get('/youtube-preview', protect, authorize('editor', 'admin'), getYoutubePreview);
router.post('/from-youtube', protect, authorize('editor', 'admin'), createContentFromYoutube);

// Rutas con /:id
router.get('/:id', getContentById);
router.put('/:id/view', registerView);

// Crear / editar / eliminar
router.post('/', protect, authorize('editor', 'admin'), createContent);
router.put('/:id', protect, authorize('editor', 'admin'), updateContent);
router.delete('/:id', protect, authorize('editor', 'admin'), deleteContent);

module.exports = router;