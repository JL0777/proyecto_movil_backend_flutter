const nodemailer = require('nodemailer');
require('dotenv').config();

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

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

module.exports = { enviarCodigoRecuperacion };