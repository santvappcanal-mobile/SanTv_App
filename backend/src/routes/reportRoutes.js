const express = require('express');
const router = express.Router();

const { protect, authorize } = require('../middleware/auth');
const reportUpload = require('../middleware/reportUpload');
const {
  createReport,
  getMyReports,
  getMapReports,
  getFeaturedNews,
  getPendingReports,
  approveReport,
  rejectReport,
} = require('../controllers/reportController');

// Usuario
router.post('/', protect, reportUpload.single('image'), createReport);
router.get('/mine', protect, getMyReports);
router.get('/map', protect, getMapReports);
router.get('/featured', protect, getFeaturedNews);

// Admin / editor
router.get('/pending', protect, authorize('admin', 'editor'), getPendingReports);
router.put('/:id/approve', protect, authorize('admin', 'editor'), approveReport);
router.put('/:id/reject', protect, authorize('admin', 'editor'), rejectReport);

module.exports = router;