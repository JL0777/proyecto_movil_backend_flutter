const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { Usuario } = require('../models');

const JWT_SECRET = 'tu_secreto_super_seguro_cambialo_123';

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

    const hashedPassword = await bcrypt.hash(password, 10);

    await Usuario.create({
      email,
      password: hashedPassword,
      telefono,
      rol: 'cliente'
    });

    res.status(201).json({ message: '¡Registro exitoso!' });

  } catch (error) {
    console.error("ERROR REGISTER:", error);
    res.status(500).json({ error: 'Error en el servidor' });
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
      message: '¡Bienvenido de nuevo a MyMeal!',
      token,
      user: {
        id: user.id,
        email: user.email,
        nombre: user.nombre,
        rol: user.rol
      }
    });

  } catch (error) {
    console.error("ERROR LOGIN:", error);
    res.status(500).json({ error: 'Error en el servidor' });
  }
};