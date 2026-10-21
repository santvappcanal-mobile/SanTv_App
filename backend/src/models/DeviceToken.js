const mongoose = require('mongoose');

// Un documento por dispositivo (token FCM). Un usuario puede tener varios
// dispositivos y un mismo token solo pertenece a un usuario a la vez.
const deviceTokenSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    token: {
      type: String,
      required: true,
      unique: true,
    },
    platform: {
      type: String,
      enum: ['android', 'ios', 'web'],
      default: 'android',
    },
    lastUsedAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('DeviceToken', deviceTokenSchema);
