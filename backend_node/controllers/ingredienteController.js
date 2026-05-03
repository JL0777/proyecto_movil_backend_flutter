const { Ingrediente } = require('../models');

// ======================
// LISTAR POR TIPO (cliente)
// ======================
exports.getByTipo = async (req, res) => {
  try {
    const ingredientes = await Ingrediente.findAll({
      where: {
        tipo: req.params.tipo,
        disponible: true
      },
      order: [['nombre', 'ASC']]
    });

    res.json(ingredientes);
  } catch (error) {
    console.error("ERROR GET INGREDIENTES:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// LISTAR TODOS (admin)
// ======================
exports.getAll = async (req, res) => {
  try {
    const ingredientes = await Ingrediente.findAll({
      order: [['tipo', 'ASC'], ['nombre', 'ASC']]
    });

    res.json(ingredientes);
  } catch (error) {
    console.error("ERROR GET ALL INGREDIENTES:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// CREAR (admin)
// ======================
exports.create = async (req, res) => {
  try {
    const { nombre, tipo, cantidad, precio } = req.body;

    if (!nombre || !tipo) {
      return res.status(400).json({
        error: "Nombre y tipo son requeridos"
      });
    }

    const ingrediente = await Ingrediente.create({
      nombre,
      tipo,
      cantidad,
      precio: precio || 0
    });

    res.status(201).json(ingrediente);
  } catch (error) {
    console.error("ERROR CREATE INGREDIENTE:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// ACTUALIZAR (admin)
// ======================
exports.update = async (req, res) => {
  try {
    const ingrediente = await Ingrediente.findByPk(req.params.id);

    if (!ingrediente) {
      return res.status(404).json({ error: "Ingrediente no encontrado" });
    }

    await ingrediente.update(req.body);

    res.json(ingrediente);
  } catch (error) {
    console.error("ERROR UPDATE INGREDIENTE:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// ELIMINAR (admin)
// ======================
exports.destroy = async (req, res) => {
  try {
    const ingrediente = await Ingrediente.findByPk(req.params.id);

    if (!ingrediente) {
      return res.status(404).json({ error: "Ingrediente no encontrado" });
    }

    await ingrediente.destroy();

    res.json({
      success: true,
      message: "Ingrediente eliminado correctamente"
    });
  } catch (error) {
    console.error("ERROR DELETE INGREDIENTE:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

exports.getByTipoPublico = async (req, res) => {
  try {
    const ingredientes = await Ingrediente.findAll({
      where: { tipo: req.params.tipo },
      attributes: ['id', 'nombre', 'cantidad', 'precio', 'tipo'],
      order: [['nombre', 'ASC']]
    });
    res.json(ingredientes);
  } catch (error) {
    console.error('ERROR GET BY TIPO PUBLICO:', error);
    res.status(500).json({ error: 'Error del servidor' });
  }
};

exports.toggleDisponible = async (req, res) => {
  try {
    const ing = await Ingrediente.findByPk(req.params.id);
    if (!ing) return res.status(404).json({ error: 'No encontrado' });
    ing.disponible = !ing.disponible;
    await ing.save();
    res.json({ disponible: ing.disponible });
  } catch (e) {
    res.status(500).json({ error: 'Error al actualizar' });
  }
};