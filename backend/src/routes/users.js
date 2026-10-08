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
  uploadProfilePhoto,
  pingUser,
  setOffline,
  getUsers,
  getUserById,
  updateUser,
  deleteUser,
} = require('../controllers/User');
const { loginWithGoogle } = require('../controllers/google');
const { protect, authorize } = require('../middleware/auth');
const uploadAvatar = require('../middleware/uploadAvatar');

// Rutas públicas
router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/login-google', loginWithGoogle);
router.post('/verify-code', verifyCode);
router.post('/resend-code', resendCode);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

// Rutas privadas (usuario autenticado)
// OJO: /ping y /offline deben ir ANTES de las rutas '/:id'
router.get('/profile', protect, getUserProfile);
router.put('/profile', protect, updateUserProfile);
// protect va antes de uploadAvatar porque el nombre del archivo usa req.user
router.post('/profile/photo', protect, uploadAvatar, uploadProfilePhoto);
router.put('/ping', protect, pingUser);
router.put('/offline', protect, setOffline);

// Rutas privadas (solo admin)
router.get('/', protect, authorize('admin'), getUsers);
router.get('/:id', protect, authorize('admin'), getUserById);
router.put('/:id', protect, authorize('admin'), updateUser);
router.delete('/:id', protect, authorize('admin'), deleteUser);

module.exports = router;