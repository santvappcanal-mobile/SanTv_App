// backend/src/controllers/google.js
const { OAuth2Client } = require("google-auth-library");
const User = require("../models/User.js");
const generateToken = require("../utils/generateToken.js");

// Debe ser el ID de cliente tipo "Web application" de Google Cloud Console,
// el MISMO que la app Flutter usa como serverClientId.
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// POST /api/users/login-google   (ruta pública, sin `protect`)
const loginWithGoogle = async (req, res) => {
  const { idToken } = req.body;

  if (!idToken) {
    return res.status(400).json({
      success: false,
      message: "Falta el idToken de Google",
    });
  }

  // 1) Verificar el token directamente con Google
  let payload;
  try {
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    payload = ticket.getPayload();
  } catch (error) {
    console.error("Token de Google inválido:", error.message);
    return res.status(401).json({
      success: false,
      message: "No se pudo verificar la cuenta de Google",
    });
  }

  if (!payload.email || !payload.email_verified) {
    return res.status(401).json({
      success: false,
      message: "La cuenta de Google no tiene un correo verificado",
    });
  }

  // 2) Buscar o crear el usuario con el esquema REAL (name, email, role, ...)
  try {
    const { sub: googleId, given_name, family_name, picture } = payload;
    const email = payload.email.toLowerCase();

    let user = await User.findOne({ $or: [{ googleId }, { email }] });

    if (!user) {
      // Tu modelo solo acepta letras y espacios en `name` (misma regex del
      // modelo); se limpia lo que venga de Google (ã, ç, ü, guiones, puntos...)
      const rawName =
        [given_name, family_name].filter(Boolean).join(" ") || payload.name || "";
      const name =
        rawName
          .replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, "")
          .replace(/\s+/g, " ")
          .trim() || "Usuario";

      user = await User.create({
        name,
        email,
        googleId,
        avatar: picture || "",
        isVerified: true, // Google ya verificó el correo
      });
    } else {
      // Ya existía (registro local): se vincula la cuenta de Google
      let changed = false;
      if (!user.googleId) {
        user.googleId = googleId;
        changed = true;
      }
      if (!user.avatar && picture) {
        user.avatar = picture;
        changed = true;
      }
      if (!user.isVerified) {
        user.isVerified = true;
        changed = true;
      }
      if (changed) await user.save();
    }

    if (user.isActive === false) {
      return res.status(403).json({
        success: false,
        message: "Tu cuenta está desactivada",
      });
    }

    const token = generateToken(user._id);

    // Misma forma que loginUser: { success, data: { ...usuario, token } }
    // (auth_service.dart lee body['data'] y AppUser.fromJson(data)).
    return res.status(200).json({
      success: true,
      data: {
        _id: user._id,
        id: user._id,
        name: user.name,
        email: user.email,
        avatar: user.avatar,
        role: user.role,
        isVerified: user.isVerified,
        subscriptionPlan: user.subscriptionPlan,
        token,
      },
    });
  } catch (error) {
    // Errores de base de datos / validación de Mongoose: se ven en consola
    console.error("Error en loginWithGoogle:", error);
    return res.status(500).json({
      success: false,
      message: "Error interno al iniciar sesión con Google",
    });
  }
};

module.exports = { loginWithGoogle };

