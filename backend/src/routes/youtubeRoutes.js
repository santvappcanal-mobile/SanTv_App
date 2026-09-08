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
router.get('/:id', getContentById);
router.put('/:id/view', registerView);

// Preview de un link de YouTube (título, thumbnail) antes de guardar
router.get('/youtube-preview', protect, authorize('editor', 'admin'), getYoutubePreview);

// Crear contenido directo desde un link de YouTube
router.post('/from-youtube', protect, authorize('editor', 'admin'), createContentFromYoutube);

// Crear contenido genérico (si ya tienes todas las URLs a mano)
router.post('/', protect, authorize('editor', 'admin'), createContent);
router.put('/:id', protect, authorize('editor', 'admin'), updateContent);
router.delete('/:id', protect, authorize('editor', 'admin'), deleteContent);

module.exports = router;
