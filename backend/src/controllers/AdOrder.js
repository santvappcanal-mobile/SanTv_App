const asyncHandler = require('express-async-handler');
const cloudinary = require('../config/cloudinary');
const AdOrder = require('../models/AdOrder');
const { notifyUser, notifyAdmins } = require('../utils/adOrderNotify');

const PHONE_RE = /^[0-9+\s()-]{7,20}$/;
const METHODS = ['transferencia', 'efectivo'];

const fail = (res, code, message) => {
  res.status(code);
  throw new Error(message);
};

// POST /api/ad-orders  (usuario logueado)
const createOrder = asyncHandler(async (req, res) => {
  const { company, contactName, contactPhone, planName, amount, notes, paymentMethod } =
    req.body;

  if (!company?.trim() || !contactName?.trim() || !planName?.trim()) {
    fail(res, 400, 'Completa empresa, contacto y plan');
  }
  if (!PHONE_RE.test(String(contactPhone || '').trim())) {
    fail(res, 400, 'El teléfono de contacto no es válido');
  }
  if (!METHODS.includes(paymentMethod)) {
    fail(res, 400, 'Método de pago no válido');
  }
  const parsedAmount = Number(amount);
  if (!Number.isFinite(parsedAmount) || parsedAmount < 0) {
    fail(res, 400, 'El valor del plan no es válido');
  }

  const order = await AdOrder.create({
    user: req.user._id,
    company,
    contactName,
    contactPhone,
    planName,
    amount: parsedAmount,
    notes: notes || '',
    paymentMethod,
  });

  // Avisa a los administradores que hay una nueva solicitud de pauta
  notifyAdmins(
    'Nueva solicitud de pauta',
    `${order.company} solicitó el ${order.planName}.`,
    { exceptUserId: req.user._id, orderId: order._id }
  );

  res.status(201).json({ success: true, data: order });
});

// POST /api/ad-orders/:id/receipt  (dueño de la solicitud, campo "comprobante")
const uploadReceipt = asyncHandler(async (req, res) => {
  const discardUpload = async () => {
    if (req.file) await cloudinary.uploader.destroy(req.file.filename).catch(() => {});
  };

  const order = await AdOrder.findById(req.params.id);
  if (!order) {
    await discardUpload();
    fail(res, 404, 'Solicitud no encontrada');
  }
  if (String(order.user) !== String(req.user._id)) {
    await discardUpload();
    fail(res, 403, 'No puedes modificar esta solicitud');
  }
  if (!req.file) fail(res, 400, 'No se envió ningún comprobante');
  if (order.paymentMethod !== 'transferencia' || order.status !== 'pendiente') {
    await discardUpload();
    fail(res, 400, 'Esta solicitud ya no admite comprobante');
  }

  // Si ya había un comprobante, se reemplaza
  if (order.receiptPublicId) {
    await cloudinary.uploader.destroy(order.receiptPublicId).catch(() => {});
  }

  order.receiptUrl = req.file.path;
  order.receiptPublicId = req.file.filename;
  order.receiptUploadedAt = new Date();
  await order.save();

  res.json({ success: true, data: order });
});

// GET /api/ad-orders/mine
const getMyOrders = asyncHandler(async (req, res) => {
  const orders = await AdOrder.find({ user: req.user._id }).sort('-createdAt');
  res.json({ success: true, count: orders.length, data: orders });
});

// GET /api/ad-orders  (admin) — opcional ?status=pendiente|validado|cancelado
const getAllOrders = asyncHandler(async (req, res) => {
  const filter = {};
  if (['pendiente', 'validado', 'cancelado'].includes(req.query.status)) {
    filter.status = req.query.status;
  }
  const orders = await AdOrder.find(filter)
    .populate('user', 'name email')
    .sort('-createdAt');
  res.json({ success: true, count: orders.length, data: orders });
});

// PUT /api/ad-orders/:id/validate  (admin)
const validateOrder = asyncHandler(async (req, res) => {
  const order = await AdOrder.findById(req.params.id);
  if (!order) fail(res, 404, 'Solicitud no encontrada');
  if (order.status !== 'pendiente') fail(res, 400, 'Esta solicitud ya fue revisada');
  if (order.paymentMethod === 'transferencia' && !order.receiptUrl) {
    fail(res, 400, 'El cliente aún no ha subido el comprobante');
  }

  order.status = 'validado';
  order.reviewedBy = req.user._id;
  order.reviewedAt = new Date();
  await order.save();

  await notifyUser(
    order.user,
    'Pago validado',
    `Tu pago del ${order.planName} fue validado. Iniciamos la preparación de tu pauta y nuestro equipo te contactará.`,
    { orderId: order._id }
  );

  res.json({ success: true, data: order });
});

// PUT /api/ad-orders/:id/invalidate  (admin) — cancela la solicitud
const invalidateOrder = asyncHandler(async (req, res) => {
  const order = await AdOrder.findById(req.params.id);
  if (!order) fail(res, 404, 'Solicitud no encontrada');
  if (order.status !== 'pendiente') fail(res, 400, 'Esta solicitud ya fue revisada');

  const reason = String(req.body.reason || '').trim().slice(0, 200);

  order.status = 'cancelado';
  order.cancelReason = reason;
  order.reviewedBy = req.user._id;
  order.reviewedAt = new Date();
  await order.save();

  await notifyUser(
    order.user,
    'Pago invalidado',
    `No pudimos validar tu pago del ${order.planName} y la solicitud fue cancelada.` +
      (reason ? ` Motivo: ${reason}` : ''),
    { orderId: order._id }
  );

  res.json({ success: true, data: order });
});

module.exports = {
  createOrder,
  uploadReceipt,
  getMyOrders,
  getAllOrders,
  validateOrder,
  invalidateOrder,
};