const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../config/cloudinary'); // ajusta la ruta si tu archivo de Cloudinary está en otro lugar

const storage = new CloudinaryStorage({
  cloudinary,
  params: async (req) => ({
    folder: 'santv/avatars',
    allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
    public_id: `user_${req.user._id}_${Date.now()}`,
    transformation: [{ width: 400, height: 400, crop: 'fill', gravity: 'face' }],
  }),
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB
  fileFilter: (req, file, cb) => {
    const esImagen = file.mimetype.startsWith('image/');

    // Algunos teléfonos mandan la foto sin tipo (application/octet-stream).
    // En ese caso se deja pasar: Cloudinary revisa el formato real del
    // archivo con allowed_formats y rechaza lo que no sea jpg, png o webp.
    const sinTipo = file.mimetype === 'application/octet-stream';

    if (esImagen || sinTipo) cb(null, true);
    else cb(new Error('Solo se permiten imágenes'));
  },
});

// El campo del formulario multipart se llama "foto"
module.exports = upload.single('foto');