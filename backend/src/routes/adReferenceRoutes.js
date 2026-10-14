const express = require('express');
const router = express.Router();

const {
  getReferences,
  createReference,
  deleteReference,
} = require('../controllers/AdReference');
const { protect, authorize } = require('../middleware/auth');

router
  .route('/')
  .get(getReferences)
  .post(protect, authorize('admin', 'editor'), createReference);

router.route('/:id').delete(protect, authorize('admin', 'editor'), deleteReference);

module.exports = router;