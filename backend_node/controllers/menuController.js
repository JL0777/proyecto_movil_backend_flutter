const { Menu, Categoria } = require('../models');

// ======================
// LISTAR POR CATEGORIA (cliente)
// ======================
exports.getByCategoria = async (req, res) => {
  try {
    const menus = await Menu.findAll({
      where: {
        categoriaId: req.params.categoriaId,
        disponible: true
      },
      order: [['nombre', 'ASC']]
    });

    res.json(menus);
  } catch (error) {
    console.error("ERROR GET MENUS:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// OBTENER UNO
// ======================
exports.getOne = async (req, res) => {
  try {
    const menu = await Menu.findByPk(req.params.id, {
      include: [{ model: Categoria }]
    });

    if (!menu) {
      return res.status(404).json({ error: "Menú no encontrado" });
    }

    res.json(menu);
  } catch (error) {
    console.error("ERROR GET MENU:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// LISTAR TODOS (admin)
// ======================
exports.getAll = async (req, res) => {
  try {
    const menus = await Menu.findAll({
      include: [{ model: Categoria, attributes: ['id', 'nombre', 'tipo'] }],
      order: [['createdAt', 'DESC']]
    });

    res.json(menus);
  } catch (error) {
    console.error("ERROR GET ALL MENUS:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// CREAR (admin)
// ======================
exports.create = async (req, res) => {
  try {
    const { nombre, descripcion, precio, imagenUrl, categoriaId } = req.body;

    if (!nombre || !precio || !categoriaId) {
      return res.status(400).json({
        error: "Nombre, precio y categoría son requeridos"
      });
    }

    const menu = await Menu.create({
      nombre,
      descripcion,
      precio,
      imagenUrl,
      categoriaId
    });

    res.status(201).json(menu);
  } catch (error) {
    console.error("ERROR CREATE MENU:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// ACTUALIZAR (admin)
// ======================
exports.update = async (req, res) => {
  try {
    const menu = await Menu.findByPk(req.params.id);

    if (!menu) {
      return res.status(404).json({ error: "Menú no encontrado" });
    }

    await menu.update(req.body);

    res.json(menu);
  } catch (error) {
    console.error("ERROR UPDATE MENU:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// ELIMINAR (admin)
// ======================
exports.destroy = async (req, res) => {
  try {
    const menu = await Menu.findByPk(req.params.id);

    if (!menu) {
      return res.status(404).json({ error: "Menú no encontrado" });
    }

    await menu.destroy();

    res.json({ success: true, message: "Menú eliminado correctamente" });
  } catch (error) {
    console.error("ERROR DELETE MENU:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// BUSCAR MENUS
// ======================
exports.buscar = async (req, res) => {
  try {
    const { q } = req.query;

    if (!q || q.trim().length === 0) {
      return res.status(400).json({ error: "Ingresa un término de búsqueda" });
    }

    const { Op } = require('sequelize');

    const menus = await Menu.findAll({
      where: {
        disponible: true,
        [Op.or]: [
          { nombre: { [Op.like]: `%${q}%` } },
          { descripcion: { [Op.like]: `%${q}%` } }
        ]
      },
      include: [
        {
          model: Categoria,
          attributes: ['id', 'nombre', 'tipo']
        }
      ],
      order: [['nombre', 'ASC']]
    });

    res.json(menus);
  } catch (error) {
    console.error("ERROR BUSCAR MENUS:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};