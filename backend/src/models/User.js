const mongoose = require('mongoose');
const bcrypt = require('bcryptjs'); // Necesario para encriptar y comparar contraseñas

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'El nombre es obligatorio'],
      trim: true,
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
      required: [true, 'La contraseña es obligatoria'],
      minlength: 6,
      select: false, // Por defecto no se devuelve en las consultas (coincide con tu .select('+password'))
    },
    role: {
      type: String,
      enum: ['user', 'admin'], // Puedes ajustar los roles según tu necesidad
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
      enum: ['free', 'premium', 'pro'], // Ejemplo de planes, ajusta según tu lógica
      default: 'free',
    },
  },
  {
    timestamps: true, // Crea automáticamente los campos createdAt y updatedAt
  }
);

// Middleware para encriptar la contraseña antes de guardar en la base de datos
userSchema.pre('save', async function (next) {
  // Si la contraseña no ha sido modificada, pasamos al siguiente middleware
  if (!this.isModified('password')) {
    next();
  }

  // Generamos la "sal" y encriptamos la contraseña
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

// Método de instancia para verificar si la contraseña ingresada coincide con la encriptada
userSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', userSchema);