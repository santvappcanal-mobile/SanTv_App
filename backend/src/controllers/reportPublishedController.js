const asyncHandler = require('express-async-handler');
const Report = require('../models/Report');

// GET /api/reports/published
// Todos los reportes aprobados (sin el límite de 30 días del mapa).
// Lo usa la pantalla "Publicados" para que el admin pueda ver y borrar
// también los más antiguos.
const getPublishedReports = asyncHandler(async (req, res) => {
  const reports = await Report.find({ status: 'approved' })
    .select(
      'title description category imageUrl latitude longitude address createdAt status author'
    )
    .populate('author', 'name avatar reporterBadge')
    .sort({ createdAt: -1 })
    .limit(500);

  res.json({ success: true, count: reports.length, data: reports });
});

module.exports = { getPublishedReports };