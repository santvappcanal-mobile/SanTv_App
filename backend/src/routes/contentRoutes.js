const express = require('express');
const router = express.Router();
const {
  getYoutubePreview,
  createContentFromYoutube,
  createContent,
  getContents,
  getAllContentAdmin,
  getContentById,
  registerView,
  togglePublish,
  updateContent,
  deleteContent,
} = require('../controllers/Content');
const { protect, authorize } = require('../middleware/auth');

// --- Rutas de admin (van antes de "/:id" para que no choquen) ---
router.get('/admin', protect, authorize('editor', 'admin'), getAllContentAdmin);
router.get('/youtube-preview', protect, authorize('editor', 'admin'), getYoutubePreview);
router.post('/from-youtube', protect, authorize('editor', 'admin'), createContentFromYoutube);
router.patch('/:id/publish', protect, authorize('editor', 'admin'), togglePublish);

// --- Rutas públicas ---
router.get('/', getContents);
router.get('/:id', getContentById);
router.put('/:id/view', registerView);

// --- Rutas de edición/creación/borrado ---
router.post('/', protect, authorize('editor', 'admin'), createContent);
router.put('/:id', protect, authorize('editor', 'admin'), updateContent);
router.delete('/:id', protect, authorize('editor', 'admin'), deleteContent);

module.exports = router;
