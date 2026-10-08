const mongoose = require('mongoose');
const asyncHandler = require('express-async-handler');
const Watchlist = require('../models/Watchlist');
const WatchHistory = require('../models/WatchHistory');
const Content = require('../models/Content');

// Valida el :contentId de la URL y responde 400 si no es un ObjectId
const assertValidId = (res, id) => {
  if (!mongoose.isValidObjectId(id)) {
    res.status(400);
    throw new Error('ID de contenido no válido');
  }
};

// @desc    Obtener Mi Lista (contenido guardado) del usuario logueado
// @route   GET /api/watchlist
// @access  Private
const getMyWatchlist = asyncHandler(async (req, res) => {
  const entries = await Watchlist.find({ user: req.user._id })
    .sort({ addedAt: -1 })
    .populate('content');

  // Se descartan los contenidos que ya no existen o fueron desactivados
  const data = entries
    .map((entry) => entry.content)
    .filter((content) => content && content.isActive);

  res.json({ success: true, count: data.length, data });
});

// @desc    Obtener solo los IDs guardados (para pintar el botón de guardar en las tarjetas)
// @route   GET /api/watchlist/ids
// @access  Private
const getMyWatchlistIds = asyncHandler(async (req, res) => {
  const entries = await Watchlist.find({ user: req.user._id }).select('content');
  res.json({
    success: true,
    data: entries.map((entry) => entry.content.toString()),
  });
});

// @desc    Guardar un contenido en Mi Lista
// @route   POST /api/watchlist/:contentId
// @access  Private
const addToWatchlist = asyncHandler(async (req, res) => {
  const { contentId } = req.params;
  assertValidId(res, contentId);

  const exists = await Content.exists({ _id: contentId });
  if (!exists) {
    res.status(404);
    throw new Error('Contenido no encontrado');
  }

  // upsert: si ya estaba guardado no falla ni duplica
  await Watchlist.updateOne(
    { user: req.user._id, content: contentId },
    { $setOnInsert: { addedAt: new Date() } },
    { upsert: true }
  );

  res.status(201).json({ success: true, message: 'Agregado a Mi Lista' });
});

// @desc    Quitar un contenido de Mi Lista
// @route   DELETE /api/watchlist/:contentId
// @access  Private
const removeFromWatchlist = asyncHandler(async (req, res) => {
  const { contentId } = req.params;
  assertValidId(res, contentId);

  await Watchlist.deleteOne({ user: req.user._id, content: contentId });

  res.json({ success: true, message: 'Eliminado de Mi Lista' });
});

// @desc    Registrar que el usuario vio un video.
//          Suma +1 a las vistas públicas en CADA toque y guarda el
//          video en el historial del usuario (sin repetirlo) para el
//          contador "Vistos" del perfil.
// @route   POST /api/watchlist/viewed/:contentId
// @access  Private
const registerViewed = asyncHandler(async (req, res) => {
  const { contentId } = req.params;
  console.log('VISTA recibida:', contentId, 'usuario:', req.user?._id);
  assertValidId(res, contentId);

  const now = new Date();

  // Historial del usuario: un registro por video, solo se actualiza la fecha
  await WatchHistory.updateOne(
    { user: req.user._id, content: contentId },
    { $setOnInsert: { firstViewedAt: now }, $set: { lastViewedAt: now } },
    { upsert: true }
  );

  // Contador público: +1 por cada toque
  const content = await Content.findByIdAndUpdate(
    contentId,
    { $inc: { views: 1 } },
    { new: true }
  );

  if (!content) {
    res.status(404);
    throw new Error('Contenido no encontrado');
  }

  console.log('VISTAS ahora:', content.title, '->', content.views);

  res.json({ success: true, data: { views: content.views } });
});

// @desc    Contadores del perfil: favoritos (Mi Lista) y vistos
// @route   GET /api/watchlist/stats
// @access  Private
const getMyStats = asyncHandler(async (req, res) => {
  const [favorites, watched] = await Promise.all([
    Watchlist.countDocuments({ user: req.user._id }),
    WatchHistory.countDocuments({ user: req.user._id }),
  ]);

  res.json({ success: true, data: { favorites, watched } });
});

module.exports = {
  getMyWatchlist,
  getMyWatchlistIds,
  addToWatchlist,
  removeFromWatchlist,
  registerViewed,
  getMyStats,
};