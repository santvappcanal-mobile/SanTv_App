const asyncHandler = require('express-async-handler');
const Watchlist = require('../models/Watchlist');

// @desc    Agregar contenido a la watchlist del usuario
// @route   POST /api/watchlist
// @access  Private
const addToWatchlist = asyncHandler(async (req, res) => {
  const { content } = req.body;

  if (!content) {
    res.status(400);
    throw new Error('El campo content es obligatorio');
  }

  const exists = await Watchlist.findOne({ user: req.user._id, content });
  if (exists) {
    res.status(400);
    throw new Error('Este contenido ya está en tu watchlist');
  }

  const item = await Watchlist.create({ user: req.user._id, content });
  res.status(201).json({ success: true, data: item });
});

// @desc    Obtener watchlist del usuario autenticado
// @route   GET /api/watchlist
// @access  Private
const getUserWatchlist = asyncHandler(async (req, res) => {
  const items = await Watchlist.find({ user: req.user._id })
    .populate('content')
    .sort({ addedAt: -1 });

  res.json({ success: true, count: items.length, data: items });
});

// @desc    Verificar si un contenido está en la watchlist del usuario
// @route   GET /api/watchlist/check/:contentId
// @access  Private
const checkInWatchlist = asyncHandler(async (req, res) => {
  const item = await Watchlist.findOne({ user: req.user._id, content: req.params.contentId });
  res.json({ success: true, inWatchlist: !!item, data: item || null });
});

// @desc    Actualizar progreso de visualización
// @route   PUT /api/watchlist/:id/progress
// @access  Private
const updateProgress = asyncHandler(async (req, res) => {
  const { watchProgress, completed } = req.body;

  const item = await Watchlist.findOne({ _id: req.params.id, user: req.user._id });

  if (!item) {
    res.status(404);
    throw new Error('Elemento de watchlist no encontrado');
  }

  if (watchProgress !== undefined) item.watchProgress = watchProgress;
  if (completed !== undefined) item.completed = completed;

  const updatedItem = await item.save();
  res.json({ success: true, data: updatedItem });
});

// @desc    Eliminar contenido de la watchlist
// @route   DELETE /api/watchlist/:id
// @access  Private
const removeFromWatchlist = asyncHandler(async (req, res) => {
  const item = await Watchlist.findOne({ _id: req.params.id, user: req.user._id });

  if (!item) {
    res.status(404);
    throw new Error('Elemento de watchlist no encontrado');
  }

  await item.deleteOne();
  res.json({ success: true, message: 'Contenido eliminado de la watchlist' });
});

module.exports = {
  addToWatchlist,
  getUserWatchlist,
  checkInWatchlist,
  updateProgress,
  removeFromWatchlist,
};
