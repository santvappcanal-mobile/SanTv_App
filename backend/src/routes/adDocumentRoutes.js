const express = require('express');
const router = express.Router();
const { getDocuments, createDocument, deleteDocument } = require('../controllers/AdDocument');
const { protect, authorize } = require('../middleware/auth');

// Pública: cualquiera puede ver los documentos
router.get('/', getDocuments);

// Solo editor/admin puede crear o eliminar
router.post('/', protect, authorize('editor', 'admin'), createDocument);
router.delete('/:id', protect, authorize('editor', 'admin'), deleteDocument);

module.exports = router;