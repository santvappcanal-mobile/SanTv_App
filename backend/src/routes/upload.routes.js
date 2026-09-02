const express = require('express');
const router = express.Router();
const { uploadImage, uploadVideo } = require('../middleware/upload');
const cloudinary = require('../config/cloudinary');

// POST /api/uploads/image  (form-data, campo: "file")
router.post('/image', uploadImage.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No se envió ningún archivo' });
  }
  res.status(200).json({
    url: req.file.path,
    publicId: req.file.filename,
  });
});

// POST /api/uploads/video  (form-data, campo: "file")
router.post('/video', uploadVideo.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No se envió ningún archivo' });
  }
  res.status(200).json({
    url: req.file.path,
    publicId: req.file.filename,
  });
});

// DELETE /api/uploads/:publicId
router.delete('/:publicId(*)', async (req, res) => {
  try {
    const result = await cloudinary.uploader.destroy(req.params.publicId);
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ error: 'No se pudo eliminar el archivo' });
  }
});

module.exports = router;