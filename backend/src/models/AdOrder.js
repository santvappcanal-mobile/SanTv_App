const mongoose = require('mongoose');

// Solicitud de pauta publicitaria (con su pago)
const adOrderSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    company: { type: String, required: true, trim: true, maxlength: 120 },
    contactName: { type: String, required: true, trim: true, maxlength: 80 },
    contactPhone: { type: String, required: true, trim: true },
    planName: { type: String, required: true, trim: true },
    amount: { type: Number, required: true, min: 0 },
    notes: { type: String, default: '', trim: true, maxlength: 500 },
    paymentMethod: {
      type: String,
      enum: ['transferencia', 'efectivo'],
      required: true,
    },
    // pendiente: esperando comprobante / revisión del admin
    // validado: el admin confirmó el pago
    // cancelado: el admin invalidó el pago
    status: {
      type: String,
      enum: ['pendiente', 'validado', 'cancelado'],
      default: 'pendiente',
    },
    receiptUrl: { type: String, default: '' },
    receiptPublicId: { type: String, default: '' },
    receiptUploadedAt: { type: Date },
    reviewedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    reviewedAt: { type: Date },
    cancelReason: { type: String, default: '' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('AdOrder', adOrderSchema);
