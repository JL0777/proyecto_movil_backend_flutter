const { TransactionalEmailsApi, SendSmtpEmail, ApiClient } = require('@getbrevo/brevo');
require('dotenv').config();

const apiInstance = new TransactionalEmailsApi();
apiInstance.authentications['apiKey'].apiKey = process.env.BREVO_API_KEY;

const enviarCorreo = async (emailDestino, subject, htmlContent) => {
  const sendSmtpEmail = new SendSmtpEmail();
  sendSmtpEmail.subject = subject;
  sendSmtpEmail.htmlContent = htmlContent;
  sendSmtpEmail.sender = { name: 'MyMeal App', email: 'noreply.mymeal@gmail.com' };
  sendSmtpEmail.to = [{ email: emailDestino }];
  await apiInstance.sendTransacEmail(sendSmtpEmail);
};

// ======================
// CORREO RECUPERACIÓN DE CONTRASEÑA
// ======================
const enviarCodigoRecuperacion = async (emailDestino, codigo) => {
  await enviarCorreo(emailDestino, 'Recuperación de contraseña - MyMeal', `
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
  `);
};

// ======================
// CORREO VERIFICACIÓN DE CUENTA NUEVA
// ======================
const enviarCodigoVerificacionCuenta = async (emailDestino, codigo) => {
  await enviarCorreo(emailDestino, 'Verifica tu cuenta - MyMeal', `
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
  `);
};

// ======================
// CORREO VERIFICACIÓN CAMBIO DE CORREO
// ======================
const enviarCodigoVerificacionEmail = async (emailDestino, codigo) => {
  await enviarCorreo(emailDestino, 'Verifica tu nuevo correo electrónico - MyMeal', `
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
  `);
};

module.exports = {
  enviarCodigoRecuperacion,
  enviarCodigoVerificacionCuenta,
  enviarCodigoVerificacionEmail
};