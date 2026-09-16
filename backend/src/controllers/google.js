const { OAuth2Client } = require("google-auth-library");
const User = require("../models/User.js");
const generateToken = require("../utils/generateToken.js");

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// POST /api/usuarios/login-google
const loginWithGoogle = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({
        success: false,
        errorMessage: "Falta el idToken de Google",
      });
    }

    // Verificar el token directamente con Google
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    const { sub: googleId, email, given_name, family_name, picture } = payload;

    // Buscar por googleId primero, y por correo como respaldo (usuario que ya se había registrado localmente)
    let user = await User.findOne({
      $or: [{ googleId }, { Correo_Electronico: email }],
    });

    if (!user) {
      user = await User.create({
        Nombre: given_name || "Usuario",
        Apellido: family_name || "",
        Correo_Electronico: email,
        googleId,
        avatar: picture || "",
        isVerified: true, // Google ya verificó el correo
      });
    } else if (!user.googleId) {
      // Ya existía por registro local: se vincula la cuenta de Google
      user.googleId = googleId;
      if (!user.avatar) user.avatar = picture || "";
      user.isVerified = true;
      await user.save();
    }

    const token = generateToken(user._id);

    return res.status(200).json({
      success: true,
      token,
      user: {
        id: user._id,
        nombre: user.Nombre,
        apellido: user.Apellido,
        correo: user.Correo_Electronico,
        avatar: user.avatar,
        rol: user.rol,
        isVerified: user.isVerified,
      },
    });
  } catch (error) {
    console.error("Error en loginWithGoogle:", error);
    return res.status(401).json({
      success: false,
      errorMessage: "No se pudo verificar la cuenta de Google",
    });
  }
};

module.exports = { loginWithGoogle };