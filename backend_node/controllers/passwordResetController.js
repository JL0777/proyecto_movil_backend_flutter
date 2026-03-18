const { Usuario, PasswordResetCode } = require('../models');
const { enviarCodigoRecuperacion } = require('../utils/mailer');
const bcrypt = require('bcrypt');

// ======================
// SOLICITAR CÓDIGO
// ======================
exports.solicitarCodigo = async (req, res) => {

  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ error: 'El correo es requerido' });
  }

  try {

    const user = await Usuario.findOne({ where: { email } });

    if (!user) {
      return res.status(404).json({ error: 'No existe una cuenta con ese correo' });
    }

    // Invalidar códigos anteriores del mismo correo
    await PasswordResetCode.update(
      { usado: true },
      { where: { email, usado: false } }
    );

    // Generar código de 6 dígitos
    const codigo = Math.floor(100000 + Math.random() * 900000).toString();

    // Expira en 10 minutos
    const expira_en = new Date(Date.now() + 10 * 60 * 1000);

    await PasswordResetCode.create({ email, codigo, expira_en });

    await enviarCodigoRecuperacion(email, codigo);

    res.json({ success: true, message: 'Código enviado al correo' });

  } catch (error) {
    console.error('ERROR SOLICITAR CÓDIGO:', error);
    res.status(500).json({ error: 'Error al enviar el código' });
  }

};

// ======================
// VERIFICAR CÓDIGO
// ======================
exports.verificarCodigo = async (req, res) => {

  const { email, codigo } = req.body;

  if (!email || !codigo) {
    return res.status(400).json({ error: 'Correo y código son requeridos' });
  }

  try {

    const registro = await PasswordResetCode.findOne({
      where: { email, codigo, usado: false }
    });

    if (!registro) {
      return res.status(400).json({ error: 'Código inválido' });
    }

    if (new Date() > new Date(registro.expira_en)) {
      return res.status(400).json({ error: 'El código ha expirado' });
    }

    res.json({ success: true, message: 'Código verificado correctamente' });

  } catch (error) {
    console.error('ERROR VERIFICAR CÓDIGO:', error);
    res.status(500).json({ error: 'Error al verificar el código' });
  }

};

// ======================
// CAMBIAR CONTRASEÑA
// ======================
exports.cambiarPassword = async (req, res) => {

  const { email, codigo, nuevaPassword } = req.body;

  if (!email || !codigo || !nuevaPassword) {
    return res.status(400).json({ error: 'Todos los campos son requeridos' });
  }

  if (nuevaPassword.length < 6) {
    return res.status(400).json({ error: 'La contraseña debe tener mínimo 6 caracteres' });
  }

  try {

    const registro = await PasswordResetCode.findOne({
      where: { email, codigo, usado: false }
    });

    if (!registro) {
      return res.status(400).json({ error: 'Código inválido' });
    }

    if (new Date() > new Date(registro.expira_en)) {
      return res.status(400).json({ error: 'El código ha expirado' });
    }

    // Marcar código como usado
    await registro.update({ usado: true });

    // Actualizar contraseña
    const hashedPassword = await bcrypt.hash(nuevaPassword, 10);
    await Usuario.update(
      { password: hashedPassword },
      { where: { email } }
    );

    res.json({ success: true, message: 'Contraseña actualizada correctamente' });

  } catch (error) {
    console.error('ERROR CAMBIAR PASSWORD:', error);
    res.status(500).json({ error: 'Error al cambiar la contraseña' });
  }

};