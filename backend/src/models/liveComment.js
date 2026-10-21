const mongoose = require('mongoose');

// Comentarios del en vivo. Se borran solos 4 horas después de creados
// (índice TTL de MongoDB; el borrado corre cada ~60 s en segundo plano).
const FOUR_HOURS_IN_SECONDS = 4 * 60 * 60;

const liveCommentSchema = new mongoose.Schema({
  roomId: { type: String, required: true, index: true },
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  userName: { type: String, required: true },
  userAvatar: { type: String, default: '' },
  text: { type: String, required: true, maxlength: 300 },
  createdAt: { type: Date, default: Date.now, expires: FOUR_HOURS_IN_SECONDS },
});

module.exports = mongoose.model('LiveComment', liveCommentSchema);