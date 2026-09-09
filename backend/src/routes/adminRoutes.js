const express = require('express');
const router = express.Router();
const { getDashboardStats } = require('../controllers/Admin');
const { protect, authorize } = require('../middleware/auth');

// Todo este router requiere ser admin
router.use(protect, authorize('admin'));

router.get('/stats', getDashboardStats);

module.exports = router;
