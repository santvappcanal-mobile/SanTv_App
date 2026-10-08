const multer = require('multer');
const cloudinary = require('cloudinary').v2;
const Ad = require('../models/Ad');

const TIPOS_OK = ['image/jpeg', 'image/png', 'image/webp'];

const uploadAdImage = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 3 * 1024 * 1024 }, // 3 MB
  fileFilter: (req, file, cb) => {
    // Algunos celulares envían la imagen sin tipo (octet-stream);
    // Cloudinary valida que sea una imagen de verdad.
    const ok =
      TIPOS_OK.includes(file.mimetype) ||
      file.mimetype === 'application/octet-stream';
    cb(ok ? null : new Error('Formato no permitido (usa JPG, PNG o WEBP)'), ok);
  },
});

const subirACloudinary = (buffer) =>
  new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder: 'ads', resource_type: 'image' },
      (err, result) => (err ? reject(err) : resolve(result))
    );
    stream.end(buffer);
  });

const createImageAd = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Falta la imagen' });
    }

    const { title, targetUrl, type, endDate } = req.body;
    const result = await subirACloudinary(req.file.buffer);

    const ad = await Ad.create({
      title: title?.trim() || 'Anuncio',
      type: ['banner', 'popup'].includes(type) ? type : 'popup',
      mediaUrl: result.secure_url,
      mediaPublicId: result.public_id,
      targetUrl: targetUrl?.trim() || undefined,
      startDate: new Date(),
      endDate: endDate || undefined,
      isActive: true,
    });

    res.status(201).json({ success: true, data: ad });
  } catch (error) {
    next(error);
  }
};

module.exports = { uploadAdImage, createImageAd };