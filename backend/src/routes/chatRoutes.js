const express = require('express');
const { chatearConAsistente } = require('../controllers/chatController.js');

const router = express.Router();

// Ruta: POST /api/chat
router.post('/', chatearConAsistente);

module.exports = router;