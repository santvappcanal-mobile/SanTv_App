const asyncHandler = require('express-async-handler');
const AdDocument = require('../models/AdDocument');
const cloudinary = require('../config/cloudinary');

// @desc    Obtener todos los documentos de publicidad
// @route   GET /api/ad-documents
// @access  Public (cualquier usuario puede verlos)
const getDocuments = asyncHandler(async (req, res) => {
  const documents = await AdDocument.find().sort({ createdAt: -1 });
  res.json({ success: true, count: documents.length, data: documents });
});

// @desc    Crear un registro de documento (después de subir el PDF a Cloudinary)
// @route   POST /api/ad-documents
// @access  Private/Editor+
const createDocument = asyncHandler(async (req, res) => {
  const { title, mediaUrl, publicId } = req.body;

  if (!title || !mediaUrl) {
    res.status(400);
    throw new Error('title y mediaUrl son obligatorios');
  }

  const document = await AdDocument.create({ title, mediaUrl, publicId });
  res.status(201).json({ success: true, data: document });
});

// @desc    Eliminar un documento (incluye limpieza en Cloudinary)
// @route   DELETE /api/ad-documents/:id
// @access  Private/Editor+
const deleteDocument = asyncHandler(async (req, res) => {
  const document = await AdDocument.findById(req.params.id);

  if (!document) {
    res.status(404);
    throw new Error('Documento no encontrado');
  }

  if (document.publicId) {
    try {
      await cloudinary.uploader.destroy(document.publicId, { resource_type: 'raw' });
    } catch (error) {
      console.error('No se pudo eliminar el archivo de Cloudinary:', error.message);
    }
  }

  await document.deleteOne();
  res.json({ success: true, message: 'Documento eliminado correctamente' });
});

module.exports = { getDocuments, createDocument, deleteDocument };