const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'El nombre es obligatorio'],
      trim: true,
      match: [/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/, 'El nombre solo puede contener letras'],
    },
    email: {
      type: String,
      required: [true, 'El email es obligatorio'],
      unique: true,
      match: [
        /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
        'Por favor ingresa un email válido',
      ],
    },
    password: {
      type: String,
      required: function () {
        return !this.googleId; // solo obligatoria si NO es cuenta de Google
      },
      minlength: 6,
      select: false,
    },
    googleId: {
      type: String,
      unique: true,
      sparse: true, // sin default: el campo simplemente no existe en usuarios locales
    },
    role: {
      type: String,
      enum: ['user', 'editor', 'admin'],
      default: 'user',
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    avatar: {
      type: String,
      default: '',
    },
    subscriptionPlan: {
      type: String,
      enum: ['free', 'premium', 'pro'],
      default: 'free',
    },

    // --- VERIFICACIÓN DE CUENTA ---
    isVerified: {
      type: Boolean,
      default: false,
    },
    codigoVerificacion: {
      type: String,
    },
    codigoVerificacionExpiracion: {
      type: Date,
    },

    // --- RECUPERACIÓN DE CONTRASEÑA ---
    codigoRecuperacion: {
      type: String,
    },
    codigoRecuperacionExpiracion: {
      type: Date,
    },
  },
  {
    timestamps: true,
  }
);

userSchema.pre('save', async function (next) {
  if (!this.isModified('password') || !this.password) {
    return next();
  }

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

userSchema.methods.matchPassword = async function (enteredPassword) {
  if (!this.password) return false; // cuenta de Google, no tiene password
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', userSchema);