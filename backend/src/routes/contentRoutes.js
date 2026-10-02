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

// ---------------------------------------------------------------
// IMPORTANTE: las rutas fijas (/youtube-preview, /from-youtube,
// /admin) van SIEMPRE antes de las que usan /:id. Si no, Express
// interpreta "youtube-preview" o "admin" como un :id.
// ---------------------------------------------------------------

// Rutas públicas
router.get('/', getContents);

// Panel de admin: todo el contenido (activo o no)
router.get('/admin', protect, authorize('editor', 'admin'), getAllContentAdmin);

// Preview de un link de YouTube (título, thumbnail) antes de guardar
router.get('/youtube-preview', protect, authorize('editor', 'admin'), getYoutubePreview);

// Crear contenido directo desde un link de YouTube
router.post('/from-youtube', protect, authorize('editor', 'admin'), createContentFromYoutube);

// Rutas con /:id
router.get('/:id', getContentById);
router.put('/:id/view', registerView);
router.patch('/:id/publish', protect, authorize('editor', 'admin'), togglePublish);

// Crear contenido genérico (si ya tienes todas las URLs a mano)
router.post('/', protect, authorize('editor', 'admin'), createContent);

// Editar / eliminar
router.put('/:id', protect, authorize('editor', 'admin'), updateContent);
router.delete('/:id', protect, authorize('editor', 'admin'), deleteContent);

module.exports = router;