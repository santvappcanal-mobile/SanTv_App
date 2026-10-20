const express = require('express');
const router = express.Router();
const { protect, authorize } = require('../middleware/auth');
const uploadReceiptMw = require('../middleware/uploadReceipt');
const {
  createOrder,
  uploadReceipt,
  getMyOrders,
  getAllOrders,
  validateOrder,
  invalidateOrder,
} = require('../controllers/AdOrder');

router.post('/', protect, createOrder);
router.get('/mine', protect, getMyOrders); // antes de cualquier ruta con :id
router.get('/', protect, authorize('admin'), getAllOrders);
router.post('/:id/receipt', protect, uploadReceiptMw.single('comprobante'), uploadReceipt);
router.put('/:id/validate', protect, authorize('admin'), validateOrder);
router.put('/:id/invalidate', protect, authorize('admin'), invalidateOrder);

module.exports = router;
