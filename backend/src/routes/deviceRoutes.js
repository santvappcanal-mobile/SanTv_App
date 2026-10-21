const express = require('express');
const router = express.Router();
const { registerDevice, unregisterDevice, sendTestPush } = require('../controllers/Device');
const { protect } = require('../middleware/auth');

router.post('/register', protect, registerDevice);
router.post('/unregister', protect, unregisterDevice);
router.post('/test', protect, sendTestPush);

module.exports = router;
