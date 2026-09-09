const asyncHandler = require('express-async-handler');
const User = require('../models/User');
const Content = require('../models/Content');
const LiveEvent = require('../models/LiveEvent');

// @desc    Obtener estadísticas generales para el dashboard de admin
// @route   GET /api/admin/stats
// @access  Private/Admin
const getDashboardStats = asyncHandler(async (req, res) => {
  const [
    totalUsers,
    activeUsers,
    totalContent,
    publishedContent,
    unpublishedContent,
    totalLiveEvents,
    activeLiveEvents,
    viewsAgg,
    contentByType,
    usersByRole,
  ] = await Promise.all([
    User.countDocuments(),
    User.countDocuments({ isActive: true }),
    Content.countDocuments(),
    Content.countDocuments({ isPublished: true }),
    Content.countDocuments({ isPublished: false }),
    LiveEvent.countDocuments(),
    LiveEvent.countDocuments({ status: 'live' }),
    Content.aggregate([{ $group: { _id: null, totalViews: { $sum: '$views' } } }]),
    Content.aggregate([{ $group: { _id: '$type', count: { $sum: 1 } } }]),
    User.aggregate([{ $group: { _id: '$role', count: { $sum: 1 } } }]),
  ]);

  const totalViews = viewsAgg[0]?.totalViews || 0;

  // Top 5 contenido más visto, útil para el dashboard
  const topContent = await Content.find({ isPublished: true })
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
        published: publishedContent,
        unpublished: unpublishedContent,
        totalViews,
        byType: contentByType.reduce((acc, t) => ({ ...acc, [t._id]: t.count }), {}),
        topContent,
      },
      liveEvents: {
        total: totalLiveEvents,
        active: activeLiveEvents,
      },
    },
  });
});

module.exports = { getDashboardStats };
