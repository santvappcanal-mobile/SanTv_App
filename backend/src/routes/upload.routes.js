const express = require('express');
const router = express.Router();
const { uploadImage, uploadVideo } = require('../middleware/upload');
const cloudinary = require('../config/cloudinary');
const { protect, authorize } = require('../middleware/auth');

// POST /api/uploads/image  (form-data, campo: "file")
router.post(
  '/image',
  protect,
  authorize('editor', 'admin'),
  uploadImage.single('file'),
  (req, res) => {
    if (!req.file) {
      return res
        .status(400)
        .json({ success: false, message: 'No se envió ningún archivo' });
    }
    res.status(200).json({
      url: req.file.path,
      publicId: req.file.filename,
    });
  }
);

// POST /api/uploads/video  (form-data, campo: "file")
router.post(
  '/video',
  protect,
  authorize('editor', 'admin'),
  uploadVideo.single('file'),
  (req, res) => {
    if (!req.file) {
      return res
        .status(400)
        .json({ success: false, message: 'No se envió ningún archivo' });
    }
    console.log('✅ Video subido:', req.file.filename);
    res.status(200).json({
      url: req.file.path,
      publicId: req.file.filename,
    });
  }
);

// DELETE /api/uploads/:publicId
router.delete(
  '/:publicId(*)',
  protect,
  authorize('editor', 'admin'),
  async (req, res) => {
    try {
      const result = await cloudinary.uploader.destroy(req.params.publicId);
      res.status(200).json(result);
    } catch (error) {
      res
        .status(500)
        .json({ success: false, message: 'No se pudo eliminar el archivo' });
    }
  }
);

module.exports = router;