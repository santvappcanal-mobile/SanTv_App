const asyncHandler = require('express-async-handler');
const Report = require('../models/Report');
const User = require('../models/User');
const Content = require('../models/Content');
const Notification = require('../models/Notification');
const { analyzeReport } = require('../services/reportAI');
const { sendToUsers } = require('../services/pushService');

const POINTS_PER_APPROVED = 10;
const BADGES = [
  { min: 15, name: 'Corresponsal' },
  { min: 5, name: 'Reportero verificado' },
  { min: 1, name: 'Reportero' },
];

const NEARBY_DEGREES = 0.01; // ≈ 1 km
const NEARBY_WINDOW_MS = 24 * 60 * 60 * 1000;

const userId = (req) => req.user._id || req.user.id;
const isStaff = (req) => ['admin', 'editor'].includes(req.user.role);
const isOwner = (report, req) =>
  String(report.author?._id || report.author) === String(userId(req));

function badgeFor(approvedCount) {
  const found = BADGES.find((b) => approvedCount >= b.min);
  return found ? found.name : '';
}

/* ------------------------------------------------------------------ */
/*  Publicación en Content                                             */
/* ------------------------------------------------------------------ */

// Crea la noticia en Content al aprobar (reporte ciudadano = solo foto, sin video).
async function publishAsContent(report, authorName) {
  return Content.create({
    title: report.title,
    description: `${report.description}\n\nReportado por ${authorName}`,
    type: 'documentary',
    // Explorar filtra comparando genres en minúsculas con la categoría
    genres: [report.category.toLowerCase()],
    thumbnailUrl: report.imageUrl,
    thumbnailPublicId: report.imagePublicId || '',
    releaseYear: new Date().getFullYear(),
    isActive: true,
    reportId: report._id,
    reportedBy: report.author,
  });
}

// Borra la foto de Cloudinary (si falla no se detiene el borrado del reporte).
async function removeImage(publicId) {
  if (!publicId) return;
  try {
    const mod = require('../config/cloudinary');
    const cloud = mod.uploader ? mod : mod.v2 || mod.cloudinary;
    if (cloud && cloud.uploader) await cloud.uploader.destroy(publicId);
  } catch (err) {
    console.error('No se pudo borrar la imagen del reporte:', err.message);
  }
}

/* ------------------------------------------------------------------ */
/*  Notificaciones                                                     */
/* ------------------------------------------------------------------ */

// Push FCM a todos los dispositivos de esos usuarios.
// pushService nunca lanza errores y convierte "data" a texto por su cuenta.
async function sendPush(userIds, { title, body, data }) {
  await sendToUsers(userIds, { title, body, data });
}

// Guarda la notificación en la bandeja de cada usuario y dispara el push.
async function notifyMany(userIds, { title, message, type, data = {} }) {
  if (!userIds || userIds.length === 0) return;
  try {
    await Notification.insertMany(
      userIds.map((id) => ({ user: id, title, message, type, data }))
    );
    await sendPush(userIds, { title, body: message, data: { type, ...data } });
  } catch (err) {
    console.error('No se pudo enviar la notificación del reporte:', err.message);
  }
}

// A los admins/editores: llegó un reporte nuevo por revisar.
async function notifyAdminsNewReport(report, authorName) {
  const staff = await User.find({
    role: { $in: ['admin', 'editor'] },
    isActive: { $ne: false },
    _id: { $ne: report.author },
  }).select('_id');

  await notifyMany(
    staff.map((u) => u._id),
    {
      title: 'Nuevo reporte por revisar',
      message: `${authorName} envió: "${report.title}"`,
      type: 'report_pending',
      data: { reportId: String(report._id), forAdmin: 'true' },
    }
  );
}

// Al autor: su reporte fue aceptado (o rechazado).
async function notifyAuthor(report, { title, message, type }) {
  await notifyMany([report.author], {
    title,
    message,
    type,
    data: { reportId: String(report._id) },
  });
}

// A todos los usuarios (menos al autor): hay un reporte nuevo publicado.
async function notifyCommunity(report, authorName) {
  const users = await User.find({
    isActive: { $ne: false },
    _id: { $ne: report.author },
  }).select('_id');

  await notifyMany(
    users.map((u) => u._id),
    {
      title: `Nuevo reporte de ${authorName}`,
      message: `${report.title}. ¡Tú también puedes contribuir!`,
      type: 'community_report',
      data: { reportId: String(report._id) },
    }
  );
}

/* ------------------------------------------------------------------ */
/*  Usuario                                                            */
/* ------------------------------------------------------------------ */

// POST /api/reports   (multipart: image + campos)
const createReport = asyncHandler(async (req, res) => {
  if (!req.file) {
    res.status(400);
    throw new Error('Debes adjuntar una imagen del suceso');
  }

  const { title, description, category, address } = req.body;
  const latitude = parseFloat(req.body.latitude);
  const longitude = parseFloat(req.body.longitude);

  if (Number.isNaN(latitude) || Number.isNaN(longitude)) {
    res.status(400);
    throw new Error('La ubicación es obligatoria');
  }

  // Reportes cercanos de las últimas 24 h (aprobados o pendientes)
  const since = new Date(Date.now() - NEARBY_WINDOW_MS);
  const nearby = await Report.find({
    status: { $in: ['pending', 'approved'] },
    createdAt: { $gte: since },
    latitude: { $gte: latitude - NEARBY_DEGREES, $lte: latitude + NEARBY_DEGREES },
    longitude: { $gte: longitude - NEARBY_DEGREES, $lte: longitude + NEARBY_DEGREES },
  })
    .select('_id')
    .limit(20);

  const safeCategory = Report.CATEGORIES.includes(category) ? category : 'Noticias';

  const ai = await analyzeReport({
    title,
    description,
    category: safeCategory,
    address,
    nearbyReports: nearby.length,
  });

  const report = await Report.create({
    author: userId(req),
    title,
    description,
    category: safeCategory,
    imageUrl: req.file.path,
    imagePublicId: req.file.filename,
    latitude,
    longitude,
    address,
    nearbyReports: nearby.length,
    possibleDuplicateOf: nearby.length ? nearby[0]._id : undefined,
    ai,
  });

  // Aviso a los admins: hay un reporte por revisar
  await notifyAdminsNewReport(report, req.user.name || 'Un usuario');

  res.status(201).json({ success: true, data: report });
});

// GET /api/reports/mine
const getMyReports = asyncHandler(async (req, res) => {
  const reports = await Report.find({ author: userId(req) }).sort({ createdAt: -1 });
  const me = await User.findById(userId(req)).select(
    'reporterPoints approvedReports reporterBadge'
  );

  res.json({
    success: true,
    count: reports.length,
    stats: {
      points: me?.reporterPoints || 0,
      approved: me?.approvedReports || 0,
      badge: me?.reporterBadge || '',
    },
    data: reports,
  });
});

// GET /api/reports/map   (solo aprobados, últimos 30 días)
const getMapReports = asyncHandler(async (req, res) => {
  const since = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const reports = await Report.find({ status: 'approved', createdAt: { $gte: since } })
    .select('title description category imageUrl latitude longitude address createdAt author')
    .populate('author', 'name avatar reporterBadge')
    .sort({ createdAt: -1 })
    .limit(200);

  res.json({ success: true, count: reports.length, data: reports });
});

// GET /api/reports/featured   (noticias ciudadanas recientes, para Destacados)
const getFeaturedNews = asyncHandler(async (req, res) => {
  const limit = Math.min(parseInt(req.query.limit, 10) || 2, 10);
  const since = new Date(Date.now() - 14 * 24 * 60 * 60 * 1000);

  const items = await Content.find({
    reportId: { $exists: true, $ne: null },
    isActive: true,
    createdAt: { $gte: since },
  })
    .sort({ createdAt: -1 })
    .limit(limit);

  res.json({ success: true, count: items.length, data: items });
});

// GET /api/reports/:id   (publicados: cualquiera; pendientes/rechazados: autor o staff)
// Lo usan las notificaciones para abrir el reporte al tocarlas.
const getReportById = asyncHandler(async (req, res) => {
  const report = await Report.findById(req.params.id).populate(
    'author',
    'name avatar reporterPoints approvedReports reporterBadge'
  );
  if (!report) {
    res.status(404);
    throw new Error('Reporte no encontrado');
  }
  if (report.status !== 'approved' && !isOwner(report, req) && !isStaff(req)) {
    res.status(403);
    throw new Error('No tienes permiso para ver este reporte');
  }

  res.json({ success: true, data: report });
});

// PUT /api/reports/:id   (solo el autor; body: title, description, category, address)
const updateReport = asyncHandler(async (req, res) => {
  const report = await Report.findById(req.params.id);
  if (!report) {
    res.status(404);
    throw new Error('Reporte no encontrado');
  }
  if (!isOwner(report, req)) {
    res.status(403);
    throw new Error('Solo puedes editar tus propios reportes');
  }

  const { title, description, category, address } = req.body || {};

  if (title !== undefined) {
    const t = String(title).trim();
    if (t.length < 5 || t.length > 120) {
      res.status(400);
      throw new Error('El título debe tener entre 5 y 120 caracteres');
    }
    report.title = t;
  }
  if (description !== undefined) {
    const d = String(description).trim();
    if (d.length < 10 || d.length > 1000) {
      res.status(400);
      throw new Error('La descripción debe tener entre 10 y 1000 caracteres');
    }
    report.description = d;
  }
  if (category !== undefined && Report.CATEGORIES.includes(category)) {
    report.category = category;
  }
  if (address !== undefined) report.address = String(address).trim().slice(0, 200);

  // Si estaba rechazado, al editarlo vuelve a la cola de revisión
  const wasRejected = report.status === 'rejected';
  if (wasRejected) {
    report.status = 'pending';
    report.rejectionReason = undefined;
    report.reviewedBy = undefined;
    report.reviewedAt = undefined;
  }

  // Mientras está en revisión, la IA vuelve a analizar el texto nuevo
  if (report.status === 'pending') {
    try {
      report.ai = await analyzeReport({
        title: report.title,
        description: report.description,
        category: report.category,
        address: report.address,
        nearbyReports: report.nearbyReports,
      });
    } catch (err) {
      console.error('No se pudo re-analizar el reporte:', err.message);
    }
  }

  await report.save();

  // Si ya estaba publicado, la noticia en Content se actualiza igual
  if (report.status === 'approved' && report.publishedContent) {
    const author = await User.findById(report.author).select('name');
    await Content.findByIdAndUpdate(report.publishedContent, {
      title: report.title,
      description: `${report.description}\n\nReportado por ${author?.name || 'un ciudadano'}`,
      genres: [report.category.toLowerCase()],
    });
  }

  if (wasRejected) {
    await notifyAdminsNewReport(report, req.user.name || 'Un usuario');
  }

  res.json({ success: true, data: report });
});

// DELETE /api/reports/:id   (el autor, o un admin/editor)
const deleteReport = asyncHandler(async (req, res) => {
  const report = await Report.findById(req.params.id);
  if (!report) {
    res.status(404);
    throw new Error('Reporte no encontrado');
  }
  if (!isOwner(report, req) && !isStaff(req)) {
    res.status(403);
    throw new Error('No tienes permiso para eliminar este reporte');
  }

  // Si estaba publicado, también sale de Noticias/Explorar
  // (deleteOne del documento, así el hook de Content también borra sus comentarios)
  if (report.publishedContent) {
    const content = await Content.findById(report.publishedContent);
    if (content) await content.deleteOne();
  }
  await removeImage(report.imagePublicId);

  // Las notificaciones de este reporte ya no tendrían a dónde llevar
  await Notification.deleteMany({ 'data.reportId': String(report._id) });

  await report.deleteOne();

  res.json({ success: true, message: 'Reporte eliminado correctamente' });
});

/* ------------------------------------------------------------------ */
/*  Admin / editor                                                     */
/* ------------------------------------------------------------------ */

// GET /api/reports/pending
const getPendingReports = asyncHandler(async (req, res) => {
  const reports = await Report.find({ status: 'pending' })
    .populate('author', 'name email avatar reporterPoints approvedReports reporterBadge')
    .sort({ createdAt: 1 });

  res.json({ success: true, count: reports.length, data: reports });
});

// PUT /api/reports/:id/approve   (body opcional: title, description, category)
const approveReport = asyncHandler(async (req, res) => {
  const report = await Report.findById(req.params.id);
  if (!report) {
    res.status(404);
    throw new Error('Reporte no encontrado');
  }
  if (report.status !== 'pending') {
    res.status(400);
    throw new Error('Este reporte ya fue revisado');
  }

  // El editor puede ajustar el texto antes de publicar
  const { title, description, category } = req.body || {};
  if (title) report.title = title;
  if (description) report.description = description;
  if (category && Report.CATEGORIES.includes(category)) report.category = category;

  const author = await User.findById(report.author).select(
    'name approvedReports reporterPoints reporterBadge'
  );
  const authorName = author?.name || 'un ciudadano';

  const content = await publishAsContent(report, authorName);

  report.status = 'approved';
  report.reviewedBy = userId(req);
  report.reviewedAt = new Date();
  report.publishedContent = content._id;
  await report.save();

  if (author) {
    const approved = (author.approvedReports || 0) + 1;
    await User.findByIdAndUpdate(author._id, {
      $inc: { reporterPoints: POINTS_PER_APPROVED, approvedReports: 1 },
      $set: { reporterBadge: badgeFor(approved) },
    });
  }

  // Al autor: tu reporte fue aceptado
  await notifyAuthor(report, {
    title: '¡Tu reporte fue aceptado!',
    message: `"${report.title}" ya está publicado. +${POINTS_PER_APPROVED} puntos`,
    type: 'report_approved',
  });
  // A todos los demás: nuevo reporte de la comunidad
  await notifyCommunity(report, authorName);

  res.json({ success: true, data: report });
});

// PUT /api/reports/:id/reject   (body: reason)
const rejectReport = asyncHandler(async (req, res) => {
  const report = await Report.findById(req.params.id);
  if (!report) {
    res.status(404);
    throw new Error('Reporte no encontrado');
  }
  if (report.status !== 'pending') {
    res.status(400);
    throw new Error('Este reporte ya fue revisado');
  }

  report.status = 'rejected';
  report.rejectionReason = (req.body && req.body.reason) || 'No cumple los criterios editoriales';
  report.reviewedBy = userId(req);
  report.reviewedAt = new Date();
  await report.save();

  await notifyAuthor(report, {
    title: 'Tu reporte no fue publicado',
    message: `"${report.title}": ${report.rejectionReason}`,
    type: 'system',
  });

  res.json({ success: true, data: report });
});

module.exports = {
  createReport,
  getMyReports,
  getMapReports,
  getFeaturedNews,
  getReportById,
  updateReport,
  deleteReport,
  getPendingReports,
  approveReport,
  rejectReport,
};