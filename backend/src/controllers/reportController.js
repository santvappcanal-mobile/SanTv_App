const asyncHandler = require('express-async-handler');
const Report = require('../models/Report');
const User = require('../models/User');
const Content = require('../models/Content');
const { analyzeReport } = require('../services/reportAI');

const POINTS_PER_APPROVED = 10;
const BADGES = [
  { min: 15, name: 'Corresponsal' },
  { min: 5, name: 'Reportero verificado' },
  { min: 1, name: 'Reportero' },
];

const NEARBY_DEGREES = 0.01; // ≈ 1 km
const NEARBY_WINDOW_MS = 24 * 60 * 60 * 1000;

const userId = (req) => req.user._id || req.user.id;

function badgeFor(approvedCount) {
  const found = BADGES.find((b) => approvedCount >= b.min);
  return found ? found.name : '';
}

/* ------------------------------------------------------------------ */
/*  Hooks que debes ajustar a tus modelos/servicios reales             */
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

// Envía la push a todos. AJUSTAR al servicio FCM que ya tienes.
async function notifyNewReport(report, authorName) {
  try {
    // const { sendToAll } = require('../services/pushService');
    // await sendToAll({
    //   title: 'Noticia de tu comunidad',
    //   body: `${report.title} · Reportado por ${authorName}`,
    // });
  } catch (err) {
    console.error('No se pudo enviar la notificación del reporte:', err.message);
  }
}

async function notifyAuthor(report, text) {
  try {
    // Notificación individual al autor (modelo Notification / FCM).
  } catch (err) {
    console.error('No se pudo notificar al autor:', err.message);
  }
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

  await notifyNewReport(report, authorName);
  await notifyAuthor(report, `¡Tu reporte "${report.title}" fue publicado! +${POINTS_PER_APPROVED} puntos`);

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

  await notifyAuthor(report, `Tu reporte "${report.title}" no fue publicado: ${report.rejectionReason}`);

  res.json({ success: true, data: report });
});

module.exports = {
  createReport,
  getMyReports,
  getMapReports,
  getPendingReports,
  approveReport,
  rejectReport,
};