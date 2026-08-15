const asyncHandler = require('express-async-handler');
const LiveEvent = require('../models/LiveEvent');

// @desc    Crear evento en vivo
// @route   POST /api/live-events
// @access  Private/Editor+
const createLiveEvent = asyncHandler(async (req, res) => {
  const { title, description, streamUrl, thumbnailUrl, scheduledStart, scheduledEnd } = req.body;

  if (!title || !streamUrl || !scheduledStart) {
    res.status(400);
    throw new Error('Título, streamUrl y scheduledStart son obligatorios');
  }

  const event = await LiveEvent.create({
    title,
    description,
    streamUrl,
    thumbnailUrl,
    scheduledStart,
    scheduledEnd,
    createdBy: req.user._id,
  });

  res.status(201).json({ success: true, data: event });
});

// @desc    Obtener todos los eventos (filtrable por status)
// @route   GET /api/live-events
// @access  Public
const getLiveEvents = asyncHandler(async (req, res) => {
  const filter = {};
  if (req.query.status) filter.status = req.query.status;

  const events = await LiveEvent.find(filter).sort({ scheduledStart: 1 });
  res.json({ success: true, count: events.length, data: events });
});

// @desc    Obtener eventos actualmente en vivo
// @route   GET /api/live-events/active
// @access  Public
const getActiveLiveEvents = asyncHandler(async (req, res) => {
  const events = await LiveEvent.find({ status: 'live' }).sort({ actualStart: -1 });
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
  event.actualStart = new Date();
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
  event.actualEnd = new Date();
  await event.save();

  res.json({ success: true, data: event });
});

// @desc    Actualizar contador de espectadores
// @route   PUT /api/live-events/:id/viewers
// @access  Private
const updateViewersCount = asyncHandler(async (req, res) => {
  const { viewersCount } = req.body;

  const event = await LiveEvent.findByIdAndUpdate(
    req.params.id,
    { viewersCount },
    { new: true }
  );

  if (!event) {
    res.status(404);
    throw new Error('Evento no encontrado');
  }

  res.json({ success: true, data: { viewersCount: event.viewersCount } });
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

// @desc    Eliminar/cancelar evento
// @route   DELETE /api/live-events/:id
// @access  Private/Editor+
const deleteLiveEvent = asyncHandler(async (req, res) => {
  const event = await LiveEvent.findById(req.params.id);

  if (!event) {
    res.status(404);
    throw new Error('Evento no encontrado');
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
