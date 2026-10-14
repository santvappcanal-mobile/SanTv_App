const asyncHandler = require('express-async-handler');
const AdReference = require('../models/AdReference');
const cloudinary = require('../config/cloudinary');

// @desc    Listar videos de Referencias (públicos)
// @route   GET /api/ad-references
// @access  Public
const getReferences = asyncHandler(async (req, res) => {
  const items = await AdReference.find({ isActive: true })
    .select('title description mediaUrl createdAt')
    .sort({ createdAt: -1 });

  res.json({ success: true, count: items.length, data: items });
});

// @desc    Crear referencia (el video ya fue subido a Cloudinary por /api/uploads/video)
// @route   POST /api/ad-references
// @access  Private/Admin-Editor
const createReference = asyncHandler(async (req, res) => {
  const { title, description, mediaUrl, publicId } = req.body;

  if (!title || !mediaUrl) {
    res.status(400);
    throw new Error('Título y mediaUrl son obligatorios');
  }

  const item = await AdReference.create({
    title,
    description: description || '',
    mediaUrl,
    mediaPublicId: publicId || '',
  });

  res.status(201).json({ success: true, data: item });
});

// @desc    Editar título y/o descripción de una referencia
// @route   PUT /api/ad-references/:id
// @access  Private/Admin-Editor
const updateReference = asyncHandler(async (req, res) => {
  const item = await AdReference.findById(req.params.id);

  if (!item) {
    res.status(404);
    throw new Error('Referencia no encontrada');
  }

  const { title, description } = req.body;

  if (title !== undefined) {
    if (!String(title).trim()) {
      res.status(400);
      throw new Error('El título no puede estar vacío');
    }
    item.title = title;
  }
  if (description !== undefined) item.description = description;

  const updated = await item.save();
  res.json({ success: true, data: updated });
});

// @desc    Eliminar referencia (y su video en Cloudinary)
// @route   DELETE /api/ad-references/:id
// @access  Private/Admin-Editor
const deleteReference = asyncHandler(async (req, res) => {
  const item = await AdReference.findById(req.params.id);

  if (!item) {
    res.status(404);
    throw new Error('Referencia no encontrada');
  }

  if (item.mediaPublicId) {
    await cloudinary.uploader.destroy(item.mediaPublicId, { resource_type: 'video' });
  }

  await item.deleteOne();
  res.json({ success: true, message: 'Referencia eliminada correctamente' });
});

module.exports = { getReferences, createReference, updateReference, deleteReference };