const asyncHandler = require('express-async-handler');
const Ad = require('../models/Ad');

// @desc    Crear anuncio
// @route   POST /api/ads
// @access  Private/Admin
const createAd = asyncHandler(async (req, res) => {
  const { title, type, mediaUrl, targetUrl, duration, startDate, endDate } = req.body;

  if (!title || !mediaUrl) {
    res.status(400);
    throw new Error('Título y mediaUrl son obligatorios');
  }

  const ad = await Ad.create({
    title,
    type,
    mediaUrl,
    targetUrl,
    duration,
    startDate,
    endDate,
  });
  res.status(201).json({ success: true, data: ad });
});

// @desc    Obtener todos los anuncios
// @route   GET /api/ads
// @access  Private/Admin
const getAds = asyncHandler(async (req, res) => {
  const filter = {};
  if (req.query.isActive !== undefined) filter.isActive = req.query.isActive === 'true';
  if (req.query.type) filter.type = req.query.type;

  const ads = await Ad.find(filter).sort({ createdAt: -1 });
  res.json({ success: true, count: ads.length, data: ads });
});

// @desc    Obtener anuncios activos vigentes, opcionalmente filtrados por tipo
// @route   GET /api/ads/for-content
// @access  Public
const getAdsForContent = asyncHandler(async (req, res) => {
  const now = new Date();
  const filter = {
    isActive: true,
    startDate: { $lte: now },
    $or: [{ endDate: { $exists: false } }, { endDate: null }, { endDate: { $gte: now } }],
  };
  if (req.query.type) filter.type = req.query.type;

  const ads = await Ad.find(filter);
  res.json({ success: true, count: ads.length, data: ads });
});

// @desc    Portafolio público de anuncios de video ya realizados (para la sección de Publicidad)
// @route   GET /api/ads/portfolio
// @access  Public
const getAdPortfolio = asyncHandler(async (req, res) => {
  const ads = await Ad.find({ isActive: true, type: 'video' })
    .select('title mediaUrl duration createdAt')
    .sort({ createdAt: -1 });

  res.json({ success: true, count: ads.length, data: ads });
});

// @desc    Obtener anuncio por ID
// @route   GET /api/ads/:id
// @access  Private/Admin
const getAdById = asyncHandler(async (req, res) => {
  const ad = await Ad.findById(req.params.id);

  if (!ad) {
    res.status(404);
    throw new Error('Anuncio no encontrado');
  }

  res.json({ success: true, data: ad });
});

// @desc    Registrar impresión de anuncio
// @route   PUT /api/ads/:id/impression
// @access  Public
const registerImpression = asyncHandler(async (req, res) => {
  const ad = await Ad.findByIdAndUpdate(req.params.id, { $inc: { impressions: 1 } }, { new: true });

  if (!ad) {
    res.status(404);
    throw new Error('Anuncio no encontrado');
  }

  res.json({ success: true, data: { impressions: ad.impressions } });
});

// @desc    Registrar clic en anuncio
// @route   PUT /api/ads/:id/click
// @access  Public
const registerClick = asyncHandler(async (req, res) => {
  const ad = await Ad.findByIdAndUpdate(req.params.id, { $inc: { clicks: 1 } }, { new: true });

  if (!ad) {
    res.status(404);
    throw new Error('Anuncio no encontrado');
  }

  res.json({ success: true, data: { clicks: ad.clicks } });
});

// @desc    Actualizar anuncio
// @route   PUT /api/ads/:id
// @access  Private/Admin
const updateAd = asyncHandler(async (req, res) => {
  const ad = await Ad.findById(req.params.id);

  if (!ad) {
    res.status(404);
    throw new Error('Anuncio no encontrado');
  }

  Object.assign(ad, req.body);
  const updatedAd = await ad.save();

  res.json({ success: true, data: updatedAd });
});

// @desc    Eliminar anuncio
// @route   DELETE /api/ads/:id
// @access  Private/Admin
const deleteAd = asyncHandler(async (req, res) => {
  const ad = await Ad.findById(req.params.id);

  if (!ad) {
    res.status(404);
    throw new Error('Anuncio no encontrado');
  }

  await ad.deleteOne();
  res.json({ success: true, message: 'Anuncio eliminado correctamente' });
});

module.exports = {
  createAd,
  getAds,
  getAdsForContent,
  getAdPortfolio,
  getAdById,
  registerImpression,
  registerClick,
  updateAd,
  deleteAd,
};