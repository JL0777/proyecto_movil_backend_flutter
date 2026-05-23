require('dotenv').config();

const enviarCorreo = async (emailDestino, subject, htmlContent) => {
  const response = await fetch('https://api.brevo.com/v3/smtp/email', {
    method: 'POST',
    headers: {
      'accept': 'application/json',
      'api-key': process.env.BREVO_API_KEY,
      'content-type': 'application/json'
    },
    body: JSON.stringify({
      sender: { name: 'MyMeal App', email: 'joseluismercado227@gmail.com' },
      to: [{ email: emailDestino }],
      subject: subject,
      htmlContent: htmlContent
    })
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(JSON.stringify(error));
  }
};

const enviarCodigoRecuperacion = async (emailDestino, codigo) => {
  await enviarCorreo(emailDestino, 'Recuperación de contraseña - MyMeal', `
    <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto; padding: 30px; border-radius: 12px; border: 1px solid #eee;">
      <h2 style="color: #E8760A; text-align: center;">MyMeal</h2>
      <p>Hola, recibimos una solicitud para restablecer tu contraseña.</p>
      <p>Tu código de verificación es:</p>
      <div style="text-align: center; margin: 30px 0;">
        <span style="font-size: 36px; font-weight: bold; letter-spacing: 10px; color: #E8760A;">${codigo}</span>
      </div>
      <p style="font-size: 13px; color: #888;">Este código expira en <strong>10 minutos</strong>.</p>
    </div>
  `);
};

const enviarCodigoVerificacionCuenta = async (emailDestino, codigo) => {
  await enviarCorreo(emailDestino, 'Verifica tu cuenta - MyMeal', `
    <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto; padding: 30px; border-radius: 12px; border: 1px solid #eee;">
      <h2 style="color: #E8760A; text-align: center;">MyMeal</h2>
      <p>¡Bienvenido a MyMeal! Estás a un paso de crear tu cuenta.</p>
      <p>Ingresa este código para verificar tu correo electrónico:</p>
      <div style="text-align: center; margin: 30px 0;">
        <span style="font-size: 36px; font-weight: bold; letter-spacing: 10px; color: #E8760A;">${codigo}</span>
      </div>
      <p style="font-size: 13px; color: #888;">Este código expira en <strong>10 minutos</strong>.</p>
    </div>
  `);
};

const enviarCodigoVerificacionEmail = async (emailDestino, codigo) => {
  await enviarCorreo(emailDestino, 'Verifica tu nuevo correo electrónico - MyMeal', `
    <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto; padding: 30px; border-radius: 12px; border: 1px solid #eee;">
      <h2 style="color: #E8760A; text-align: center;">MyMeal</h2>
      <p>Recibimos una solicitud para cambiar el correo electrónico de tu cuenta.</p>
      <p>Ingresa este código para confirmar tu nuevo correo:</p>
      <div style="text-align: center; margin: 30px 0;">
        <span style="font-size: 36px; font-weight: bold; letter-spacing: 10px; color: #E8760A;">${codigo}</span>
      </div>
      <p style="font-size: 13px; color: #888;">Este código expira en <strong>10 minutos</strong>.</p>
    </div>
  `);
};

module.exports = {
  enviarCodigoRecuperacion,
  enviarCodigoVerificacionCuenta,
  enviarCodigoVerificacionEmail
};