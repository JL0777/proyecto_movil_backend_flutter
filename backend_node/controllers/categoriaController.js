const { Categoria } = require('../models');

// ======================
// LISTAR POR TIPO
// ======================
exports.getByTipo = async (req, res) => {
  try {
    const categorias = await Categoria.findAll({
      where: {
        tipo: req.params.tipo,
        disponible: true
      },
      order: [['nombre', 'ASC']]
    });

    res.json(categorias);
  } catch (error) {
    console.error("ERROR GET CATEGORIAS:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// LISTAR TODAS (admin)
// ======================
exports.getAll = async (req, res) => {
  try {
    const categorias = await Categoria.findAll({
      order: [['tipo', 'ASC'], ['nombre', 'ASC']]
    });

    res.json(categorias);
  } catch (error) {
    console.error("ERROR GET ALL CATEGORIAS:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// CREAR (admin)
// ======================
exports.create = async (req, res) => {
  try {
    const { nombre, tipo, icono } = req.body;

    if (!nombre || !tipo) {
      return res.status(400).json({
        error: "Nombre y tipo son requeridos"
      });
    }

    const categoria = await Categoria.create({ nombre, tipo, icono });

    res.status(201).json(categoria);
  } catch (error) {
    console.error("ERROR CREATE CATEGORIA:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// ACTUALIZAR (admin)
// ======================
exports.update = async (req, res) => {
  try {
    const categoria = await Categoria.findByPk(req.params.id);

    if (!categoria) {
      return res.status(404).json({ error: "Categoría no encontrada" });
    }

    await categoria.update(req.body);

    res.json(categoria);
  } catch (error) {
    console.error("ERROR UPDATE CATEGORIA:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// ELIMINAR (admin)
// ======================
exports.destroy = async (req, res) => {
  try {
    const categoria = await Categoria.findByPk(req.params.id);

    if (!categoria) {
      return res.status(404).json({ error: "Categoría no encontrada" });
    }

    await categoria.destroy();

    res.json({ success: true, message: "Categoría eliminada correctamente" });
  } catch (error) {
    console.error("ERROR DELETE CATEGORIA:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

const { buscarNutricional } = require('../services/usdaService');

// ======================
// BUSCAR NUTRICIONAL (USDA)
// ======================
exports.buscarNutricional = async (req, res) => {
  try {
    const { nombre } = req.query;

    if (!nombre || nombre.trim().length < 2) {
      return res.status(400).json({ error: 'Nombre requerido (mínimo 2 caracteres)' });
    }

    const datos = await buscarNutricional(nombre.trim());

    if (!datos) {
      return res.status(404).json({ error: 'Alimento no encontrado en USDA' });
    }

    res.json({ success: true, datos });
  } catch (error) {
    console.error('ERROR USDA:', error.message);
    res.status(500).json({ error: 'Error al consultar USDA' });
  }
};