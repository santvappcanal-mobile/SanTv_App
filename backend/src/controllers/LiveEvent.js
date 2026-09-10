const asyncHandler = require('express-async-handler');
const LiveEvent = require('../models/LiveEvent');

// @desc    Crear evento en vivo
// @route   POST /api/live-events
// @access  Private/Editor+
const createLiveEvent = asyncHandler(async (req, res) => {
  const { title, description, streamUrl, thumbnailUrl, thumbnailPublicId, scheduledStartTime, isPremium } = req.body;

  if (!title || !streamUrl || !scheduledStartTime) {
    res.status(400);
    throw new Error('Título, streamUrl y scheduledStartTime son obligatorios');
  }

  const event = await LiveEvent.create({
    title,
    description,
    streamUrl,
    thumbnailUrl,
    thumbnailPublicId,
    scheduledStartTime,
    isPremium,
  });

  res.status(201).json({ success: true, data: event });
});

// @desc    Obtener todos los eventos (filtrable por status)
// @route   GET /api/live-events
// @access  Public
const getLiveEvents = asyncHandler(async (req, res) => {
  const filter = {};
  if (req.query.status) filter.status = req.query.status;

  const events = await LiveEvent.find(filter).sort({ scheduledStartTime: 1 });
  res.json({ success: true, count: events.length, data: events });
});

// @desc    Obtener eventos actualmente en vivo
// @route   GET /api/live-events/active
// @access  Public
const getActiveLiveEvents = asyncHandler(async (req, res) => {
  const events = await LiveEvent.find({ status: 'live' }).sort({ actualStartTime: -1 });
  res.json({ success: true, count: events.length, data: events });
});

// @desc    Obtener evento por ID
// @route   GET /api/live-events/:id
// @access  Public
const getLiveEventById = asyncHandler(async (req, res) => {
  const event = await LiveEvent.findById(req.params.id);

  if (!event) {
    res.status(404);
    throw new Error('Evento no encontrado');
  }

  res.json({ success: true, data: event });
});

// @desc    Iniciar transmisión (cambia status a 'live')
// @route   PUT /api/live-events/:id/start
// @access  Private/Editor+
const startLiveEvent = asyncHandler(async (req, res) => {
  const event = await LiveEvent.findById(req.params.id);

  if (!event) {
    res.status(404);
    throw new Error('Evento no encontrado');
  }

  event.status = 'live';
  event.actualStartTime = new Date();
  await event.save();

  res.json({ success: true, data: event });
});

// @desc    Finalizar transmisión (cambia status a 'ended')
// @route   PUT /api/live-events/:id/end
// @access  Private/Editor+
const endLiveEvent = asyncHandler(async (req, res) => {
  const event = await LiveEvent.findById(req.params.id);

  if (!event) {
    res.status(404);
    throw new Error('Evento no encontrado');
  }

  event.status = 'ended';
  event.endTime = new Date();
  await event.save();

  res.json({ success: true, data: event });
});

// @desc    Actualizar contador de espectadores actuales
// @route   PUT /api/live-events/:id/viewers
// @access  Private
const updateViewersCount = asyncHandler(async (req, res) => {
  const { currentViewers } = req.body;

  if (currentViewers === undefined || currentViewers < 0) {
    res.status(400);
    throw new Error('currentViewers debe ser un número mayor o igual a 0');
  }

  const event = await LiveEvent.findById(req.params.id);

  if (!event) {
    res.status(404);
    throw new Error('Evento no encontrado');
  }

  const wasZero = event.currentViewers === 0;

  event.currentViewers = currentViewers;

  // Si pasó de 0 a más de 0, contamos que "entró" un nuevo espectador al total histórico
  if (wasZero && currentViewers > 0) {
    event.totalViews += 1;
  }

  await event.save();

  res.json({ success: true, data: { currentViewers: event.currentViewers, totalViews: event.totalViews } });
});

// @desc    Actualizar evento
// @route   PUT /api/live-events/:id
// @access  Private/Editor+
const updateLiveEvent = asyncHandler(async (req, res) => {
  const event = await LiveEvent.findById(req.params.id);

  if (!event) {
    res.status(404);
    throw new Error('Evento no encontrado');
  }

  Object.assign(event, req.body);
  const updatedEvent = await event.save();

  res.json({ success: true, data: updatedEvent });
});

// @desc    Eliminar/cancelar evento (incluye limpieza en Cloudinary)
// @route   DELETE /api/live-events/:id
// @access  Private/Editor+
const deleteLiveEvent = asyncHandler(async (req, res) => {
  const cloudinary = require('../config/cloudinary');
  const event = await LiveEvent.findById(req.params.id);

  if (!event) {
    res.status(404);
    throw new Error('Evento no encontrado');
  }

  if (event.thumbnailPublicId) {
    await cloudinary.uploader.destroy(event.thumbnailPublicId);
  }

  await event.deleteOne();
  res.json({ success: true, message: 'Evento eliminado correctamente' });
});

module.exports = {
  createLiveEvent,
  getLiveEvents,
  getActiveLiveEvents,
  getLiveEventById,
  startLiveEvent,
  endLiveEvent,
  updateViewersCount,
  updateLiveEvent,
  deleteLiveEvent,
};