const express = require('express');
const router = express.Router();
const {
  createContent,
  getContents,
  getContentById,
  registerView,
  updateContent,
  deleteContent,
} = require('../controllers/Content');
const { protect, authorize } = require('../middleware/auth');
const { uploadVideo } = require('../middleware/upload');

// Rutas públicas
router.get('/', getContents);
router.get('/:id', getContentById);
router.put('/:id/view', registerView);

// Rutas privadas (solo editor o admin)
// uploadVideo.single('video') procesa el archivo ANTES de createContent,
// y deja el resultado en req.file (con la URL de Cloudinary en req.file.path)
router.post('/', protect, authorize('editor', 'admin'), uploadVideo.single('video'), createContent);
router.put('/:id', protect, authorize('editor', 'admin'), updateContent);
router.delete('/:id', protect, authorize('editor', 'admin'), deleteContent);

module.exports = router;