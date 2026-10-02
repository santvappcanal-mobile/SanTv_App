const mongoose = require('mongoose');

// Documento único (key: 'main') que guarda si el canal está en vivo.
const liveChannelStatusSchema = new mongoose.Schema(
  {
    key: { type: String, default: 'main', unique: true },
    isLive: { type: Boolean, default: false },
    title: { type: String, default: 'SAN TV está en vivo' },
    startedAt: { type: Date, default: null },
  },
  { timestamps: true }
);

module.exports = mongoose.model('LiveChannelStatus', liveChannelStatusSchema);
