const nodemailer = require('nodemailer');
require('dotenv').config();

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

// ======================
// CORREO RECUPERACIÓN DE CONTRASEÑA
// ======================
const enviarCodigoRecuperacion = async (emailDestino, codigo) => {
  const mailOptions = {
    from: `"MyMeal App" <${process.env.EMAIL_USER}>`,
    to: emailDestino,
    subject: 'Recuperación de contraseña - MyMeal',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto; padding: 30px; border-radius: 12px; border: 1px solid #eee;">
        <h2 style="color: #E8760A; text-align: center;">MyMeal</h2>
        <p style="font-size: 16px; color: #333;">Hola, recibimos una solicitud para restablecer tu contraseña.</p>
        <p style="font-size: 15px; color: #333;">Tu código de verificación es:</p>
        <div style="text-align: center; margin: 30px 0;">
          <span style="font-size: 36px; font-weight: bold; letter-spacing: 10px; color: #E8760A;">${codigo}</span>
        </div>
        <p style="font-size: 13px; color: #888;">Este código expira en <strong>10 minutos</strong>.</p>
        <p style="font-size: 13px; color: #888;">Si no solicitaste esto, ignora este mensaje.</p>
      </div>
    `
  };
  await transporter.sendMail(mailOptions);
};

// ======================
// CORREO VERIFICACIÓN DE CUENTA NUEVA
// ======================
const enviarCodigoVerificacionCuenta = async (emailDestino, codigo) => {
  const mailOptions = {
    from: `"MyMeal App" <${process.env.EMAIL_USER}>`,
    to: emailDestino,
    subject: 'Verifica tu cuenta - MyMeal',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto; padding: 30px; border-radius: 12px; border: 1px solid #eee;">
        <h2 style="color: #E8760A; text-align: center;">MyMeal</h2>
        <p style="font-size: 16px; color: #333;">¡Bienvenido a MyMeal! Estás a un paso de crear tu cuenta.</p>
        <p style="font-size: 15px; color: #333;">Ingresa este código para verificar tu correo electrónico:</p>
        <div style="text-align: center; margin: 30px 0;">
          <span style="font-size: 36px; font-weight: bold; letter-spacing: 10px; color: #E8760A;">${codigo}</span>
        </div>
        <p style="font-size: 13px; color: #888;">Este código expira en <strong>10 minutos</strong>.</p>
        <p style="font-size: 13px; color: #888;">Si no creaste una cuenta en MyMeal, ignora este mensaje.</p>
      </div>
    `
  };
  await transporter.sendMail(mailOptions);
};

// ======================
// CORREO VERIFICACIÓN CAMBIO DE CORREO
// ======================
const enviarCodigoVerificacionEmail = async (emailDestino, codigo) => {
  const mailOptions = {
    from: `"MyMeal App" <${process.env.EMAIL_USER}>`,
    to: emailDestino,
    subject: 'Verifica tu nuevo correo electrónico - MyMeal',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto; padding: 30px; border-radius: 12px; border: 1px solid #eee;">
        <h2 style="color: #E8760A; text-align: center;">MyMeal</h2>
        <p style="font-size: 16px; color: #333;">Recibimos una solicitud para cambiar el correo electrónico de tu cuenta.</p>
        <p style="font-size: 15px; color: #333;">Ingresa este código para confirmar tu nuevo correo:</p>
        <div style="text-align: center; margin: 30px 0;">
          <span style="font-size: 36px; font-weight: bold; letter-spacing: 10px; color: #E8760A;">${codigo}</span>
        </div>
        <p style="font-size: 13px; color: #888;">Este código expira en <strong>10 minutos</strong>.</p>
        <p style="font-size: 13px; color: #888;">Si no solicitaste este cambio, ignora este mensaje.</p>
      </div>
    `
  };
  await transporter.sendMail(mailOptions);
};

module.exports = {
  enviarCodigoRecuperacion,
  enviarCodigoVerificacionCuenta,
  enviarCodigoVerificacionEmail
};