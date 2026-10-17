const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../config/cloudinary');

// Capturas de pantalla de los comprobantes de pago
const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'santv/comprobantes',
    resource_type: 'image',
    allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
  },
});

const uploadReceipt = multer({
  storage,
  limits: { fileSize: 8 * 1024 * 1024 }, // 8 MB
  fileFilter: (req, file, cb) => {
    if (file.mimetype && file.mimetype.startsWith('image/')) return cb(null, true);
    cb(new Error('El comprobante debe ser una imagen'));
  },
});

module.exports = uploadReceipt;
