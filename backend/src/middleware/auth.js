const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Protege rutas: exige un JWT válido en el header Authorization
const protect = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      req.user = await User.findById(decoded.id).select('-password');

      if (!req.user) {
        return res.status(401).json({ success: false, message: 'Usuario no encontrado, token inválido' });
      }

      return next();
    } catch (error) {
      return res.status(401).json({ success: false, message: 'No autorizado, token inválido o expirado' });
    }
  }

  if (!token) {
    return res.status(401).json({ success: false, message: 'No autorizado, no se proporcionó token' });
  }
};

// Restringe el acceso según el rol del usuario (ej: 'admin', 'editor')
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `El rol '${req.user ? req.user.role : 'desconocido'}' no tiene permiso para esta acción`,
      });
    }
    next();
  };
};

module.exports = { protect, authorize };