const asyncHandler = require('express-async-handler');
const User = require('../models/User');
const Content = require('../models/Content');
const Ad = require('../models/Ad');
const LiveEvent = require('../models/LiveEvent');

// @desc    Obtener estadísticas generales para el dashboard de admin
// @route   GET /api/admin/stats
// @access  Private/Admin
const getDashboardStats = asyncHandler(async (req, res) => {
  const [
    totalUsers,
    activeUsers,
    totalContent,
    activeContent,
    inactiveContent,
    totalLiveEvents,
    liveNow,
    totalAds,
    activeAds,
    viewsAgg,
    contentByType,
    usersByRole,
  ] = await Promise.all([
    User.countDocuments(),
    User.countDocuments({ isActive: true }),
    Content.countDocuments(),
    Content.countDocuments({ isActive: true }),
    Content.countDocuments({ isActive: false }),
    LiveEvent.countDocuments(),
    LiveEvent.countDocuments({ status: 'live' }),
    Ad.countDocuments(),
    Ad.countDocuments({ isActive: true }),
    Content.aggregate([{ $group: { _id: null, totalViews: { $sum: '$views' } } }]),
    Content.aggregate([{ $group: { _id: '$type', count: { $sum: 1 } } }]),
    User.aggregate([{ $group: { _id: '$role', count: { $sum: 1 } } }]),
  ]);

  const totalViews = viewsAgg[0]?.totalViews || 0;

  // Top 5 contenido más visto, útil para el dashboard
  const topContent = await Content.find({ isActive: true })
    .sort({ views: -1 })
    .limit(5)
    .select('title views type thumbnailUrl');

  res.json({
    success: true,
    data: {
      users: {
        total: totalUsers,
        active: activeUsers,
        byRole: usersByRole.reduce((acc, r) => ({ ...acc, [r._id]: r.count }), {}),
      },
      content: {
        total: totalContent,
        active: activeContent,
        inactive: inactiveContent,
        totalViews,
        byType: contentByType.reduce((acc, t) => ({ ...acc, [t._id]: t.count }), {}),
        topContent,
      },
      ads: {
        total: totalAds,
        active: activeAds,
      },
      liveEvents: {
        total: totalLiveEvents,
        live: liveNow,
      },
    },
  });
});

module.exports = { getDashboardStats };