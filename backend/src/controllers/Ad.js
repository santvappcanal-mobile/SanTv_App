const asyncHandler = require('express-async-handler');
const Ad = require('../models/Ad');
const cloudinary = require('../config/cloudinary');

// @desc    Crear anuncio
// @route   POST /api/ads
// @access  Private/Admin
const createAd = asyncHandler(async (req, res) => {
  const { title, type, mediaUrl, targetUrl, duration, startDate, endDate } = req.body;

  if (!title || !type || !mediaUrl || !startDate) {
    res.status(400);
    throw new Error('Título, type, mediaUrl y startDate son obligatorios');
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
    // endDate no es obligatorio: un anuncio sin endDate se considera vigente indefinidamente
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

// @desc    Subir documento/reseña en PDF (crea el Ad con type: 'document')
// @route   POST /api/ads/document
// @access  Private/Admin
const uploadAdDocument = asyncHandler(async (req, res) => {
  if (!req.file) {
    res.status(400);
    throw new Error('No se recibió ningún archivo PDF');
  }

  const { title, targetUrl } = req.body;
  if (!title) {
    res.status(400);
    throw new Error('El título es obligatorio');
  }

  const ad = await Ad.create({
    title,
    type: 'document',
    mediaUrl: req.file.path, // URL de Cloudinary
    mediaPublicId: req.file.filename, // public_id para poder eliminarlo luego
    targetUrl,
    startDate: new Date(),
  });

  res.status(201).json({ success: true, data: ad });
});

// @desc    Listar documentos/reseñas públicos (para la sección de Publicidad)
// @route   GET /api/ads/documents
// @access  Public
const getAdDocuments = asyncHandler(async (req, res) => {
  const ads = await Ad.find({ isActive: true, type: 'document' })
    .select('title mediaUrl createdAt')
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

  // Si el anuncio tiene un archivo asociado en Cloudinary, se elimina también
  if (ad.mediaPublicId) {
    const resourceType = ad.type === 'video' ? 'video' : ad.type === 'document' ? 'raw' : 'image';
    await cloudinary.uploader.destroy(ad.mediaPublicId, { resource_type: resourceType });
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
  uploadAdDocument,
  getAdDocuments,
};