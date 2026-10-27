const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinaryModule = require('../config/cloudinary');

// Tu config/cloudinary.js puede exportar el objeto v2 directamente o { v2 }.
const cloudinary = cloudinaryModule.v2 || cloudinaryModule;

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'santv/reports',
    resource_type: 'image',
    allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
  },
});

const reportUpload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
  fileFilter: (req, file, cb) => {
    if (file.mimetype && file.mimetype.startsWith('image/')) return cb(null, true);
    const err = new Error('El reporte debe incluir una imagen (jpg, png o webp)');
    err.statusCode = 400;
    cb(err);
  },
});

module.exports = reportUpload;
