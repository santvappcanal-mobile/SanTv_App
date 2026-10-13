const asyncHandler = require('express-async-handler');
const Ad = require('../models/Ad');

// @desc    Subir una o varias imágenes a la galería del portafolio
// @route   POST /api/ads/gallery
// @access  Private/Admin
const uploadGallery = asyncHandler(async (req, res) => {
  if (!req.files || req.files.length === 0) {
    res.status(400);
    throw new Error('No se recibió ninguna imagen');
  }

  const baseTitle = req.body.title?.trim();

  const docs = req.files.map((f, i) => ({
    title: baseTitle
      ? req.files.length > 1
        ? `${baseTitle} ${i + 1}`
        : baseTitle
      : 'Imagen del portafolio',
    type: 'gallery',
    mediaUrl: f.path, // URL de Cloudinary
    mediaPublicId: f.filename, // public_id para poder eliminarla luego
    startDate: new Date(),
  }));

  const ads = await Ad.insertMany(docs);
  res.status(201).json({ success: true, count: ads.length, data: ads });
});

// @desc    Listar las imágenes de la galería (para la pestaña Portafolio)
// @route   GET /api/ads/gallery
// @access  Public
const getGallery = asyncHandler(async (req, res) => {
  const ads = await Ad.find({ isActive: true, type: 'gallery' })
    .select('title mediaUrl createdAt')
    .sort({ createdAt: -1 });

  res.json({ success: true, count: ads.length, data: ads });
});

module.exports = { uploadGallery, getGallery };