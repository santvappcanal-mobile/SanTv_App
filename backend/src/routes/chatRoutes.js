const express = require('express');
const { chatearConAsistente } = require('../controllers/chatController');

const router = express.Router();

// Ruta: POST /api/chat
router.post('/', chatearConAsistente);

module.exports = router;