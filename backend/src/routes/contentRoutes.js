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

// Rutas públicas
router.get('/', getContents);
router.get('/:id', getContentById);
router.put('/:id/view', registerView);

// Rutas privadas (solo editor o admin)
router.post('/', protect, authorize('editor', 'admin'), createContent);
router.put('/:id', protect, authorize('editor', 'admin'), updateContent);
router.delete('/:id', protect, authorize('editor', 'admin'), deleteContent);

module.exports = router;