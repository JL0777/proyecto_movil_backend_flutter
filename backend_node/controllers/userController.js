const bcrypt = require('bcrypt');
const { Usuario, EmailChangeCode } = require('../models');
const { enviarCodigoVerificacionEmail } = require('../utils/mailer');

// ======================
// ACTUALIZAR NOMBRE
// ======================
exports.updateName = async (req, res) => {
  const { nombre } = req.body;
  const userId = req.user.id;

  if (!nombre) {
    return res.status(400).json({ error: "El nombre es requerido" });
  }

  try {
    const user = await Usuario.findByPk(userId);
    user.nombre = nombre;
    await user.save();

    res.json({
      success: true,
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
    console.error("ERROR UPDATE NAME:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// SOLICITAR CÓDIGO PARA CAMBIO DE EMAIL
// ======================
exports.solicitarCodigoEmail = async (req, res) => {
  const { newEmail } = req.body;
  const userId = req.user.id;

  if (!newEmail) {
    return res.status(400).json({ error: "El nuevo correo es requerido" });
  }

  try {
    const existing = await Usuario.findOne({ where: { email: newEmail } });
    if (existing) {
      return res.status(400).json({ error: "Ese correo ya está registrado" });
    }

    await EmailChangeCode.update(
      { usado: true },
      { where: { email: newEmail, usado: false } }
    );

    const codigo = Math.floor(100000 + Math.random() * 900000).toString();
    const expira_en = new Date(Date.now() + 10 * 60 * 1000);

    await EmailChangeCode.create({ email: newEmail, codigo, expira_en });
    await enviarCodigoVerificacionEmail(newEmail, codigo);

    res.json({ success: true, message: 'Código enviado al nuevo correo' });

  } catch (error) {
    console.error("ERROR SOLICITAR CÓDIGO EMAIL:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// VERIFICAR CÓDIGO Y ACTUALIZAR EMAIL
// ======================
exports.updateEmail = async (req, res) => {
  const { currentEmail, newEmail, codigo } = req.body;
  const userId = req.user.id;

  try {
    const user = await Usuario.findByPk(userId);

    if (user.email !== currentEmail) {
      return res.status(400).json({ error: "El correo actual no coincide" });
    }

    const existing = await Usuario.findOne({ where: { email: newEmail } });
    if (existing) {
      return res.status(400).json({ error: "Ese correo ya está registrado" });
    }

    const registro = await EmailChangeCode.findOne({
      where: { email: newEmail, codigo, usado: false }
    });

    if (!registro) {
      return res.status(400).json({ error: "Código inválido" });
    }

    if (new Date() > new Date(registro.expira_en)) {
      return res.status(400).json({ error: "El código ha expirado" });
    }

    await registro.update({ usado: true });
    user.email = newEmail;
    await user.save();

    res.json({
      success: true,
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
    console.error("ERROR UPDATE EMAIL:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// ACTUALIZAR TELEFONO
// ======================
exports.updatePhone = async (req, res) => {
  const { currentPhone, newPhone } = req.body;
  const userId = req.user.id;

  try {
    const user = await Usuario.findByPk(userId);

    if (user.telefono !== currentPhone) {
      return res.status(400).json({ error: "El teléfono actual no coincide" });
    }

    user.telefono = newPhone;
    await user.save();

    res.json({
      success: true,
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
    console.error("ERROR UPDATE PHONE:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// CAMBIAR CONTRASEÑA
// ======================
exports.updatePassword = async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  const userId = req.user.id;

  try {
    const user = await Usuario.findByPk(userId);
    const valid = await bcrypt.compare(currentPassword, user.password);

    if (!valid) {
      return res.status(400).json({ error: "Contraseña actual incorrecta" });
    }

    const hashed = await bcrypt.hash(newPassword, 10);
    user.password = hashed;
    await user.save();

    res.json({
      success: true,
      message: "Contraseña actualizada correctamente"
    });
  } catch (error) {
    console.error("ERROR UPDATE PASSWORD:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// ACTUALIZAR FOTO DE PERFIL
// ======================
exports.updateFotoPerfil = async (req, res) => {
  try {
    const { fotoPerfil } = req.body;
    const usuario = await Usuario.findByPk(req.user.id);

    if (!usuario) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    usuario.fotoPerfil = fotoPerfil || null;
    await usuario.save();

    res.json({
      success: true,
      user: {
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email,
        telefono: usuario.telefono,
        rol: usuario.rol,
        fotoPerfil: usuario.fotoPerfil,
      }
    });
  } catch (error) {
    console.error('ERROR UPDATE FOTO:', error);
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// ======================
// LISTAR TODOS (admin)
// ======================
exports.getAllUsers = async (req, res) => {
  try {
    const users = await Usuario.findAll({
      where: { rol: 'cliente' },
      attributes: ['id', 'nombre', 'email', 'telefono', 'rol', 'createdAt', 'fotoPerfil'],
      order: [['createdAt', 'DESC']]
    });

    res.json(users);
  } catch (error) {
    console.error("ERROR GET ALL USERS:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// OBTENER UNO (admin)
// ======================
exports.getUserById = async (req, res) => {
  try {
    const user = await Usuario.findOne({
      where: { id: req.params.id, rol: 'cliente' },
      attributes: ['id', 'nombre', 'email', 'telefono', 'rol', 'createdAt']
    });

    if (!user) {
      return res.status(404).json({ error: "Usuario no encontrado" });
    }

    res.json(user);
  } catch (error) {
    console.error("ERROR GET USER BY ID:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// EDITAR USUARIO (admin)
// ======================
exports.adminUpdateUser = async (req, res) => {
  try {
    const { nombre, email, telefono } = req.body;

    const user = await Usuario.findOne({
      where: { id: req.params.id, rol: 'cliente' }
    });

    if (!user) {
      return res.status(404).json({ error: "Usuario no encontrado" });
    }

    if (email && email !== user.email) {
      const existing = await Usuario.findOne({ where: { email } });
      if (existing) {
        return res.status(400).json({ error: "Ese correo ya está registrado" });
      }
    }

    await user.update({ nombre, email, telefono });

    res.json({
      success: true,
      user: {
        id: user.id,
        nombre: user.nombre,
        email: user.email,
        telefono: user.telefono,
        rol: user.rol,
        fotoPerfil: user.fotoPerfil
      }
    });
  } catch (error) {
    console.error("ERROR ADMIN UPDATE USER:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// CAMBIAR CONTRASEÑA (admin)
// ======================
exports.adminUpdatePassword = async (req, res) => {
  try {
    const { newPassword } = req.body;

    if (!newPassword || newPassword.length < 6) {
      return res.status(400).json({
        error: "La contraseña debe tener mínimo 6 caracteres"
      });
    }

    const user = await Usuario.findOne({
      where: { id: req.params.id, rol: 'cliente' }
    });

    if (!user) {
      return res.status(404).json({ error: "Usuario no encontrado" });
    }

    const hashed = await bcrypt.hash(newPassword, 10);
    user.password = hashed;
    await user.save();

    res.json({
      success: true,
      message: "Contraseña actualizada correctamente"
    });
  } catch (error) {
    console.error("ERROR ADMIN UPDATE PASSWORD:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// ELIMINAR USUARIO (admin)
// ======================
exports.deleteUser = async (req, res) => {
  try {
    const user = await Usuario.findOne({
      where: { id: req.params.id, rol: 'cliente' }
    });

    if (!user) {
      return res.status(404).json({ error: "Usuario no encontrado" });
    }

    await user.destroy();

    res.json({
      success: true,
      message: "Usuario eliminado correctamente"
    });
  } catch (error) {
    console.error("ERROR DELETE USER:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// OBTENER PERFIL NUTRICIONAL (cliente)
// ======================
exports.getPerfilNutricional = async (req, res) => {
  try {
    const user = await Usuario.findByPk(req.user.id, {
      attributes: [
        'id', 'nombre', 'peso', 'altura', 'edad',
        'sexo', 'nivelActividad', 'imc', 'tdee',
        'objetivoRecomendado', 'restriccionesAlimentarias'
      ]
    });

    if (!user) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    // Si no tiene datos físicos aún
    if (!user.peso || !user.altura) {
      return res.json({
        success: true,
        tieneDatos: false,
        user: null
      });
    }

    // Descripción del IMC
    let categoriaImc = '';
    let descripcionImc = '';
    if (user.imc < 18.5) {
      categoriaImc = 'Bajo peso';
      descripcionImc = 'Tu peso está por debajo del rango saludable';
    } else if (user.imc <= 24.9) {
      categoriaImc = 'Peso normal';
      descripcionImc = 'Tu peso está en el rango saludable';
    } else if (user.imc <= 29.9) {
      categoriaImc = 'Sobrepeso';
      descripcionImc = 'Tu peso está ligeramente por encima del rango saludable';
    } else {
      categoriaImc = 'Obesidad';
      descripcionImc = 'Te recomendamos consultar con un profesional de salud';
    }

    res.json({
      success: true,
      tieneDatos: true,
      user: {
        nombre: user.nombre,
        peso: user.peso,
        altura: user.altura,
        edad: user.edad,
        sexo: user.sexo,
        nivelActividad: user.nivelActividad,
        imc: user.imc,
        tdee: user.tdee,
        objetivoRecomendado: user.objetivoRecomendado,
        restriccionesAlimentarias: user.restriccionesAlimentarias ?? [],
        categoriaImc,
        descripcionImc,
      }
    });
  } catch (error) {
    console.error('ERROR GET PERFIL NUTRICIONAL:', error);
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// ======================
// GUARDAR/ACTUALIZAR PERFIL NUTRICIONAL (cliente)
// ======================
exports.updatePerfilNutricional = async (req, res) => {
  try {
    const { peso, altura, edad, sexo, nivelActividad } = req.body;

    // Validar campos requeridos
    if (!peso || !altura || !edad || !sexo || !nivelActividad) {
      return res.status(400).json({
        error: 'Todos los campos son requeridos: peso, altura, edad, sexo y nivel de actividad'
      });
    }

    // Validar rangos
    if (peso < 20 || peso > 300) {
      return res.status(400).json({ error: 'El peso debe estar entre 20 y 300 kg' });
    }
    if (altura < 100 || altura > 250) {
      return res.status(400).json({ error: 'La altura debe estar entre 100 y 250 cm' });
    }
    if (edad < 10 || edad > 100) {
      return res.status(400).json({ error: 'La edad debe estar entre 10 y 100 años' });
    }

    const user = await Usuario.findByPk(req.user.id);

    if (!user) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    // El hook beforeSave calcula IMC, TDEE y objetivoRecomendado automáticamente
    await user.update({ peso, altura, edad, sexo, nivelActividad });

    // Recargar para obtener los valores calculados
    await user.reload();

    res.json({
      success: true,
      message: 'Perfil nutricional actualizado correctamente',
      data: {
        peso: user.peso,
        altura: user.altura,
        edad: user.edad,
        sexo: user.sexo,
        nivelActividad: user.nivelActividad,
        imc: user.imc,
        tdee: user.tdee,
        objetivoRecomendado: user.objetivoRecomendado,
      }
    });
  } catch (error) {
    console.error('ERROR UPDATE PERFIL NUTRICIONAL:', error);
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// ======================
// GUARDAR RESTRICCIONES ALIMENTARIAS (cliente)
// ======================
exports.updateRestricciones = async (req, res) => {
  try {
    const { restricciones } = req.body;

    if (!Array.isArray(restricciones)) {
      return res.status(400).json({ error: 'Las restricciones deben ser un arreglo' });
    }

    const user = await Usuario.findByPk(req.user.id);
    if (!user) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    user.restriccionesAlimentarias = restricciones;
    await user.save();

    res.json({
      success: true,
      message: 'Restricciones guardadas correctamente',
      restricciones: user.restriccionesAlimentarias,
    });
  } catch (error) {
    console.error('ERROR UPDATE RESTRICCIONES:', error);
    res.status(500).json({ error: 'Error del servidor' });
  }
};