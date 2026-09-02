const express = require('express');
const router = express.Router();
const {
  registerUser,
  loginUser,
  verifyCode,
  resendCode,
  forgotPassword,
  resetPassword,
  getUserProfile,
  updateUserProfile,
  getUsers,
  getUserById,
  updateUser,
  deleteUser,
} = require('../controllers/User');
const { protect, authorize } = require('../middleware/auth');

// Rutas públicas
router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/verify-code', verifyCode);
router.post('/resend-code', resendCode);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

// Rutas privadas (usuario autenticado)
router.get('/profile', protect, getUserProfile);
router.put('/profile', protect, updateUserProfile);

// Rutas privadas (solo admin)
router.get('/', protect, authorize('admin'), getUsers);
router.get('/:id', protect, authorize('admin'), getUserById);
router.put('/:id', protect, authorize('admin'), updateUser);
router.delete('/:id', protect, authorize('admin'), deleteUser);

module.exports = router;