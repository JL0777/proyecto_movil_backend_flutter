const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { Usuario, EmailVerificationCode } = require('../models');
const { enviarCodigoRecuperacion, enviarCodigoVerificacionCuenta } = require('../utils/mailer');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET;

// ======================
// REGISTRO
// ======================
exports.register = async (req, res) => {
  const { email, password, telefono } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email y contraseña son requeridos' });
  }

  try {
    const existing = await Usuario.findOne({ where: { email } });
    if (existing) {
      return res.status(400).json({ error: 'Este correo ya está registrado' });
    }

    await EmailVerificationCode.update(
      { usado: true },
      { where: { email, usado: false } }
    );

    const hashedPassword = await bcrypt.hash(password, 10);
    const codigo = Math.floor(100000 + Math.random() * 900000).toString();
    const expira_en = new Date(Date.now() + 10 * 60 * 1000);

    await EmailVerificationCode.create({
      email,
      codigo,
      password: hashedPassword,
      telefono,
      expira_en
    });

    await enviarCodigoVerificacionCuenta(email, codigo);

    res.status(200).json({
      success: true,
      message: 'Código de verificación enviado al correo'
    });

  } catch (error) {
    console.error("ERROR REGISTER:", error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
};

// ======================
// VERIFICAR CÓDIGO Y CREAR CUENTA
// ======================
exports.verificarRegistro = async (req, res) => {
  const { email, codigo } = req.body;

  if (!email || !codigo) {
    return res.status(400).json({ error: 'Correo y código son requeridos' });
  }

  try {
    const existing = await Usuario.findOne({ where: { email } });
    if (existing) {
      return res.status(400).json({ error: 'Este correo ya está registrado' });
    }

    const registro = await EmailVerificationCode.findOne({
      where: { email, codigo, usado: false }
    });

    if (!registro) {
      return res.status(400).json({ error: 'Código inválido' });
    }

    if (new Date() > new Date(registro.expira_en)) {
      return res.status(400).json({ error: 'El código ha expirado' });
    }

    await registro.update({ usado: true });

    const user = await Usuario.create({
      email: registro.email,
      password: registro.password,
      telefono: registro.telefono,
      rol: 'cliente'
    });

    const token = jwt.sign(
      { id: user.id, email: user.email, rol: user.rol },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      success: true,
      message: '¡Registro exitoso!',
      token,
      user: {
        id: user.id,
        email: user.email,
        nombre: user.nombre,
        telefono: user.telefono,
        rol: user.rol,
        fotoPerfil: user.fotoPerfil
      }
    });

  } catch (error) {
    console.error("ERROR VERIFICAR REGISTRO:", error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
};

// ======================
// REENVIAR CÓDIGO DE REGISTRO
// ======================
exports.reenviarCodigoRegistro = async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ error: 'El correo es requerido' });
  }

  try {
    const registroExistente = await EmailVerificationCode.findOne({
      where: { email, usado: false },
      order: [['createdAt', 'DESC']]
    });

    if (!registroExistente) {
      return res.status(400).json({
        error: 'No hay un registro pendiente para este correo'
      });
    }

    await EmailVerificationCode.update(
      { usado: true },
      { where: { email, usado: false } }
    );

    const codigo = Math.floor(100000 + Math.random() * 900000).toString();
    const expira_en = new Date(Date.now() + 10 * 60 * 1000);

    await EmailVerificationCode.create({
      email: registroExistente.email,
      codigo,
      password: registroExistente.password,
      telefono: registroExistente.telefono,
      expira_en
    });

    await enviarCodigoVerificacionCuenta(email, codigo);

    res.json({ success: true, message: 'Nuevo código enviado al correo' });

  } catch (error) {
    console.error("ERROR REENVIAR CÓDIGO REGISTRO:", error);
    res.status(500).json({ error: 'Error al reenviar el código' });
  }
};

// ======================
// LOGIN
// ======================
exports.login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email y contraseña son requeridos' });
  }

  try {
    const user = await Usuario.findOne({ where: { email } });

    if (!user) {
      return res.status(401).json({ error: 'Correo o contraseña incorrectos' });
    }

    const isValid = await bcrypt.compare(password, user.password);

    if (!isValid) {
      return res.status(401).json({ error: 'Correo o contraseña incorrectos' });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, rol: user.rol },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      success: true,
      message: '¡Bienvenido de nuevo a MyMeal!',
      token,
      user: {
        id: user.id,
        email: user.email,
        nombre: user.nombre,
        telefono: user.telefono,
        rol: user.rol,
        fotoPerfil: user.fotoPerfil
      }
    });

  } catch (error) {
    console.error("ERROR LOGIN:", error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
};