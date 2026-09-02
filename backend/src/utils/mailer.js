const { BrevoClient } = require('@getbrevo/brevo');

const brevo = new BrevoClient({
  apiKey: process.env.BREVO_API_KEY,
});

const enviarCodigoVerificacion = async (correo, nombre, codigo) => {
  try {
    const result = await brevo.transactionalEmails.sendTransacEmail({
      subject: "¡Gracias por registrarte! Confirma tu cuenta",
      sender: {
        name: "SAN TV",
        email: process.env.EMAIL_USER
      },
      to: [
        {
          email: correo,
          name: nombre
        }
      ],
      htmlContent: `
        <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #e0e0e0; max-width: 500px; margin: auto; padding: 20px; background-color: #0B0B0B; border: 1px solid #2a2a2a; border-radius: 8px;">
          <h2 style="color: #39FF14; text-align: center;">¡Hola, ${nombre}!</h2>
          <p>Gracias por registrarte en nuestra plataforma.</p>
          <p>Para completar tu registro y activar tu cuenta, ingresa el siguiente código de 6 dígitos:</p>
          <div style="background-color: #141414; color: #39FF14; padding: 15px; font-size: 26px; font-weight: bold; letter-spacing: 6px; text-align: center; border-radius: 6px; margin: 20px 0; border: 1px solid #39FF14;">
            ${codigo}
          </div>
          <p style="font-size: 13px; color: #999;">Este código vencerá en <strong style="color: #e0e0e0;">15 minutos</strong>.</p>
          <p style="font-size: 12px; color: #666; margin-top: 20px;">Si no creaste esta cuenta, puedes ignorar este mensaje.</p>
        </div>
      `
    });

    return result;
  } catch (error) {
    console.error("Error enviando correo de verificación con Brevo:", error);
    throw error;
  }
};

const enviarCodigoRecuperacion = async (correo, nombre, codigo) => {
  try {
    const result = await brevo.transactionalEmails.sendTransacEmail({
      subject: "Recupera tu contraseña",
      sender: {
        name: "SAN TV",
        email: process.env.EMAIL_USER
      },
      to: [
        {
          email: correo,
          name: nombre
        }
      ],
      htmlContent: `
        <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #e0e0e0; max-width: 500px; margin: auto; padding: 20px; background-color: #0B0B0B; border: 1px solid #2a2a2a; border-radius: 8px;">
          <h2 style="color: #39FF14; text-align: center;">¡Hola, ${nombre}!</h2>
          <p>Recibimos una solicitud para restablecer tu contraseña.</p>
          <p>Ingresa el siguiente código de 6 dígitos para continuar:</p>
          <div style="background-color: #141414; color: #39FF14; padding: 15px; font-size: 26px; font-weight: bold; letter-spacing: 6px; text-align: center; border-radius: 6px; margin: 20px 0; border: 1px solid #39FF14;">
            ${codigo}
          </div>
          <p style="font-size: 13px; color: #999;">Este código vencerá en <strong style="color: #e0e0e0;">15 minutos</strong>.</p>
          <p style="font-size: 12px; color: #666; margin-top: 20px;">Si no solicitaste este cambio, puedes ignorar este mensaje y tu contraseña seguirá siendo la misma.</p>
        </div>
      `
    });

    return result;
  } catch (error) {
    console.error("Error enviando correo de recuperación con Brevo:", error);
    throw error;
  }
};

module.exports = { enviarCodigoVerificacion, enviarCodigoRecuperacion };