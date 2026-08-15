const asyncHandler = require('express-async-handler');
const Content = require('../models/Content');

// @desc    Crear nuevo contenido
// @route   POST /api/content
// @access  Private/Editor+
const createContent = asyncHandler(async (req, res) => {
  const { title, description, type, category, thumbnailUrl, videoUrl, duration, releaseDate } = req.body;

  if (!title || !type || !videoUrl) {
    res.status(400);
    throw new Error('Título, tipo y videoUrl son obligatorios');
  }

  const content = await Content.create({
    title,
    description,
    type,
    category,
    thumbnailUrl,
    videoUrl,
    duration,
    releaseDate,
    createdBy: req.user._id,
  });

  res.status(201).json({ success: true, data: content });
});

// @desc    Obtener todo el contenido (con filtros y paginación)
// @route   GET /api/content
// @access  Public
const getContents = asyncHandler(async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const skip = (page - 1) * limit;

  const filter = { isPublished: true };
  if (req.query.type) filter.type = req.query.type;
  if (req.query.category) filter.category = req.query.category;
  if (req.query.search) filter.$text = { $search: req.query.search };

  const contents = await Content.find(filter)
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit);
  const total = await Content.countDocuments(filter);

  res.json({
    success: true,
    count: contents.length,
    total,
    page,
    pages: Math.ceil(total / limit),
    data: contents,
  });
});

// @desc    Obtener contenido por ID
// @route   GET /api/content/:id
// @access  Public
const getContentById = asyncHandler(async (req, res) => {
  const content = await Content.findById(req.params.id);

  if (!content) {
    res.status(404);
    throw new Error('Contenido no encontrado');
  }

  res.json({ success: true, data: content });
});

// @desc    Registrar una vista de contenido
// @route   PUT /api/content/:id/view
// @access  Public
const registerView = asyncHandler(async (req, res) => {
  const content = await Content.findByIdAndUpdate(
    req.params.id,
    { $inc: { views: 1 } },
    { new: true }
  );

  if (!content) {
    res.status(404);
    throw new Error('Contenido no encontrado');
  }

  res.json({ success: true, data: { views: content.views } });
});

// @desc    Actualizar contenido
// @route   PUT /api/content/:id
// @access  Private/Editor+
const updateContent = asyncHandler(async (req, res) => {
  const content = await Content.findById(req.params.id);

  if (!content) {
    res.status(404);
    throw new Error('Contenido no encontrado');
  }

  Object.assign(content, req.body);
  const updatedContent = await content.save();

  res.json({ success: true, data: updatedContent });
});

// @desc    Eliminar contenido
// @route   DELETE /api/content/:id
// @access  Private/Editor+
const deleteContent = asyncHandler(async (req, res) => {
  const content = await Content.findById(req.params.id);

  if (!content) {
    res.status(404);
    throw new Error('Contenido no encontrado');
  }

  await content.deleteOne();
  res.json({ success: true, message: 'Contenido eliminado correctamente' });
});

module.exports = {
  createContent,
  getContents,
  getContentById,
  registerView,
  updateContent,
  deleteContent,
};
