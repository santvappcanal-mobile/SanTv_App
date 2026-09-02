const asyncHandler = require('express-async-handler');
const User = require('../models/User');
const generateToken = require('../utils/generateToken');
const { enviarCodigoVerificacion, enviarCodigoRecuperacion } = require('../utils/mailer');

// Genera un código numérico de 6 dígitos, ej: "042819"
const generarCodigo = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// Reglas de validación de nombre y contraseña
const nameRegex = /^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/;

// Devuelve la lista de requisitos de la contraseña, marcando
// cuáles cumple y cuáles no, para mostrarlos como checklist.
const checkPasswordRequirements = (password = '') => {
  const requirements = [
    { key: 'length', label: 'Mínimo 6 caracteres', valid: password.length >= 6 },
    { key: 'letter', label: 'Al menos una letra', valid: /[A-Za-z]/.test(password) },
    { key: 'number', label: 'Al menos un número', valid: /[0-9]/.test(password) },
    {
      key: 'special',
      label: 'Al menos un carácter especial (!@#$%^&*.,_-)',
      valid: /[!@#$%^&*(),.?":{}|<>_\-]/.test(password),
    },
  ];
  const isValid = requirements.every((r) => r.valid);
  return { isValid, requirements };
};

// @desc    Registrar nuevo usuario
// @route   POST /api/users/register
// @access  Public
const registerUser = asyncHandler(async (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    res.status(400);
    throw new Error('Nombre, email y contraseña son obligatorios');
  }

  if (!nameRegex.test(name.trim())) {
    res.status(400);
    throw new Error('El nombre solo puede contener letras');
  }

  const { isValid, requirements } = checkPasswordRequirements(password);
  if (!isValid) {
    return res.status(400).json({
      success: false,
      message: 'La contraseña no cumple los requisitos de seguridad',
      requirements,
    });
  }

  const userExists = await User.findOne({ email });
  if (userExists) {
    res.status(400);
    throw new Error('Ya existe un usuario con ese email');
  }

  const codigo = generarCodigo();
  const expiracion = new Date(Date.now() + 15 * 60 * 1000); // 15 minutos

  const user = await User.create({
    name,
    email,
    password,
    isVerified: false,
    codigoVerificacion: codigo,
    codigoVerificacionExpiracion: expiracion,
  });

  try {
    await enviarCodigoVerificacion(user.email, user.name, codigo);
  } catch (error) {
    console.error('❌ Error al enviar correo de verificación:', error.message);
  }

  res.status(201).json({
    success: true,
    pendingVerification: true,
    data: {
      _id: user._id,
      name: user.name,
      email: user.email,
    },
  });
});

// @desc    Verificar código de correo
// @route   POST /api/users/verify-code
// @access  Public
const verifyCode = asyncHandler(async (req, res) => {
  const { email, code } = req.body;

  if (!email || !code) {
    res.status(400);
    throw new Error('Email y código son obligatorios');
  }

  const user = await User.findOne({ email });

  if (!user) {
    res.status(404);
    throw new Error('Usuario no encontrado');
  }

  if (user.isVerified) {
    res.status(400);
    throw new Error('Esta cuenta ya está verificada');
  }

  if (
    !user.codigoVerificacion ||
    !user.codigoVerificacionExpiracion ||
    user.codigoVerificacionExpiracion < new Date()
  ) {
    res.status(400);
    throw new Error('El código expiró, solicita uno nuevo');
  }

  if (user.codigoVerificacion !== code.trim()) {
    res.status(400);
    throw new Error('Código incorrecto');
  }

  user.isVerified = true;
  user.codigoVerificacion = undefined;
  user.codigoVerificacionExpiracion = undefined;
  await user.save();

  res.json({
    success: true,
    data: {
      _id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      token: generateToken(user._id),
    },
  });
});

// @desc    Reenviar código de verificación
// @route   POST /api/users/resend-code
// @access  Public
const resendCode = asyncHandler(async (req, res) => {
  const { email } = req.body;

  if (!email) {
    res.status(400);
    throw new Error('El email es obligatorio');
  }

  const user = await User.findOne({ email });

  if (!user) {
    res.status(404);
    throw new Error('Usuario no encontrado');
  }

  if (user.isVerified) {
    res.status(400);
    throw new Error('Esta cuenta ya está verificada');
  }

  const codigo = generarCodigo();
  user.codigoVerificacion = codigo;
  user.codigoVerificacionExpiracion = new Date(Date.now() + 15 * 60 * 1000);
  await user.save();

  await enviarCodigoVerificacion(user.email, user.name, codigo);

  res.json({ success: true, message: 'Código reenviado correctamente' });
});

// @desc    Login de usuario
// @route   POST /api/users/login
// @access  Public
const loginUser = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    res.status(400);
    throw new Error('Email y contraseña son obligatorios');
  }

  const user = await User.findOne({ email }).select('+password');

  if (!user || !(await user.matchPassword(password))) {
    res.status(401);
    throw new Error('Email o contraseña incorrectos');
  }

  if (!user.isActive) {
    res.status(403);
    throw new Error('Esta cuenta ha sido desactivada');
  }

  if (!user.isVerified) {
    res.status(403);
    return res.status(403).json({
      success: false,
      pendingVerification: true,
      message: 'Debes verificar tu correo antes de iniciar sesión',
      email: user.email,
    });
  }

  res.json({
    success: true,
    data: {
      _id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      token: generateToken(user._id),
    },
  });
});

// @desc    Solicitar recuperación de contraseña (envía código por correo)
// @route   POST /api/users/forgot-password
// @access  Public
const forgotPassword = asyncHandler(async (req, res) => {
  const { email } = req.body;

  if (!email) {
    res.status(400);
    throw new Error('El email es obligatorio');
  }

  const user = await User.findOne({ email });

  if (!user) {
    return res.json({
      success: true,
      message: 'Si el correo existe, se enviará un código de recuperación',
    });
  }

  const codigo = generarCodigo();
  user.codigoRecuperacion = codigo;
  user.codigoRecuperacionExpiracion = new Date(Date.now() + 15 * 60 * 1000);
  await user.save();

  try {
    await enviarCodigoRecuperacion(user.email, user.name, codigo);
  } catch (error) {
    console.error('❌ Error al enviar correo de recuperación:', error.message);
    res.status(500);
    throw new Error('No se pudo enviar el correo de recuperación');
  }

  res.json({
    success: true,
    message: 'Si el correo existe, se enviará un código de recuperación',
  });
});

// @desc    Restablecer contraseña usando el código enviado por correo
// @route   POST /api/users/reset-password
// @access  Public
const resetPassword = asyncHandler(async (req, res) => {
  const { email, code, newPassword } = req.body;

  if (!email || !code || !newPassword) {
    res.status(400);
    throw new Error('Email, código y nueva contraseña son obligatorios');
  }

  const { isValid, requirements } = checkPasswordRequirements(newPassword);
  if (!isValid) {
    return res.status(400).json({
      success: false,
      message: 'La contraseña no cumple los requisitos de seguridad',
      requirements,
    });
  }

  const user = await User.findOne({ email }).select('+password');

  if (!user) {
    res.status(404);
    throw new Error('Usuario no encontrado');
  }

  if (
    !user.codigoRecuperacion ||
    !user.codigoRecuperacionExpiracion ||
    user.codigoRecuperacionExpiracion < new Date()
  ) {
    res.status(400);
    throw new Error('El código expiró, solicita uno nuevo');
  }

  if (user.codigoRecuperacion !== code.trim()) {
    res.status(400);
    throw new Error('Código incorrecto');
  }

  user.password = newPassword; // el pre('save') del modelo la hashea sola
  user.codigoRecuperacion = undefined;
  user.codigoRecuperacionExpiracion = undefined;
  await user.save();

  res.json({
    success: true,
    message: 'Contraseña actualizada correctamente',
  });
});

// @desc    Obtener perfil del usuario autenticado
// @route   GET /api/users/profile
// @access  Private
const getUserProfile = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);

  if (!user) {
    res.status(404);
    throw new Error('Usuario no encontrado');
  }

  res.json({ success: true, data: user });
});

// @desc    Actualizar perfil del usuario autenticado
// @route   PUT /api/users/profile
// @access  Private
const updateUserProfile = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);

  if (!user) {
    res.status(404);
    throw new Error('Usuario no encontrado');
  }

  if (req.body.name && !nameRegex.test(req.body.name.trim())) {
    res.status(400);
    throw new Error('El nombre solo puede contener letras');
  }

  if (req.body.password) {
    const { isValid, requirements } = checkPasswordRequirements(req.body.password);
    if (!isValid) {
      return res.status(400).json({
        success: false,
        message: 'La contraseña no cumple los requisitos de seguridad',
        requirements,
      });
    }
  }

  user.name = req.body.name || user.name;
  user.email = req.body.email || user.email;
  user.avatar = req.body.avatar || user.avatar;
  if (req.body.password) {
    user.password = req.body.password;
  }

  const updatedUser = await user.save();

  res.json({
    success: true,
    data: {
      _id: updatedUser._id,
      name: updatedUser.name,
      email: updatedUser.email,
      role: updatedUser.role,
      avatar: updatedUser.avatar,
    },
  });
});

// @desc    Obtener todos los usuarios
// @route   GET /api/users
// @access  Private/Admin
const getUsers = asyncHandler(async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const skip = (page - 1) * limit;

  const users = await User.find().skip(skip).limit(limit);
  const total = await User.countDocuments();

  res.json({
    success: true,
    count: users.length,
    total,
    page,
    pages: Math.ceil(total / limit),
    data: users,
  });
});

// @desc    Obtener usuario por ID
// @route   GET /api/users/:id
// @access  Private/Admin
const getUserById = asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);

  if (!user) {
    res.status(404);
    throw new Error('Usuario no encontrado');
  }

  res.json({ success: true, data: user });
});

// @desc    Actualizar usuario (admin)
// @route   PUT /api/users/:id
// @access  Private/Admin
const updateUser = asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);

  if (!user) {
    res.status(404);
    throw new Error('Usuario no encontrado');
  }

  if (req.body.name && !nameRegex.test(req.body.name.trim())) {
    res.status(400);
    throw new Error('El nombre solo puede contener letras');
  }

  user.name = req.body.name ?? user.name;
  user.email = req.body.email ?? user.email;
  user.role = req.body.role ?? user.role;
  user.subscriptionPlan = req.body.subscriptionPlan ?? user.subscriptionPlan;
  user.isActive = req.body.isActive ?? user.isActive;

  const updatedUser = await user.save();
  res.json({ success: true, data: updatedUser });
});

// @desc    Eliminar usuario
// @route   DELETE /api/users/:id
// @access  Private/Admin
const deleteUser = asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);

  if (!user) {
    res.status(404);
    throw new Error('Usuario no encontrado');
  }

  await user.deleteOne();
  res.json({ success: true, message: 'Usuario eliminado correctamente' });
});

module.exports = {
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
};