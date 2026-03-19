const { Pedido, DetallePedido, Menu, Ingrediente, Usuario, Direccion } = require('../models');

// ======================
// CREAR PEDIDO (cliente)
// ======================
exports.create = async (req, res) => {
  const { direccionId, tipo, metodoPago, items } = req.body;
  const usuarioId = req.user.id;

  if (!direccionId || !tipo || !metodoPago || !items || items.length === 0) {
    return res.status(400).json({
      error: "Todos los campos son requeridos"
    });
  }

  try {
    let subtotal = 0;

    // Calcular subtotal
    for (const item of items) {
      if (tipo === 'predefinido') {
        const menu = await Menu.findByPk(item.menuId);
        if (!menu) return res.status(404).json({ error: "Menú no encontrado" });
        subtotal += parseFloat(menu.precio) * item.cantidad;
      } else {
        const ingrediente = await Ingrediente.findByPk(item.ingredienteId);
        if (!ingrediente) return res.status(404).json({ error: "Ingrediente no encontrado" });
        subtotal += parseFloat(ingrediente.precio) * item.cantidad;
      }
    }

    const iva = subtotal * 0.19;
    const total = subtotal + iva;

    // Crear pedido
    const pedido = await Pedido.create({
      usuarioId,
      direccionId,
      tipo,
      metodoPago,
      subtotal,
      iva,
      total
    });

    // Crear detalles
    for (const item of items) {
      if (tipo === 'predefinido') {
        const menu = await Menu.findByPk(item.menuId);
        await DetallePedido.create({
          pedidoId: pedido.id,
          menuId: item.menuId,
          ingredienteId: null,
          cantidad: item.cantidad,
          precioUnitario: menu.precio
        });
      } else {
        const ingrediente = await Ingrediente.findByPk(item.ingredienteId);
        await DetallePedido.create({
          pedidoId: pedido.id,
          menuId: null,
          ingredienteId: item.ingredienteId,
          cantidad: item.cantidad,
          precioUnitario: ingrediente.precio
        });
      }
    }

    res.status(201).json({ success: true, pedido });

  } catch (error) {
    console.error("ERROR CREATE PEDIDO:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// MIS PEDIDOS (cliente)
// ======================
exports.getMisPedidos = async (req, res) => {
  try {
    const pedidos = await Pedido.findAll({
      where: { usuarioId: req.user.id },
      include: [
        {
          model: Direccion,
          attributes: ['direccion', 'barrio', 'tipoVivienda']
        },
        {
          model: DetallePedido,
          include: [
            {
              model: Menu,
              attributes: ['nombre', 'imagenUrl', 'precio'],
              required: false
            },
            {
              model: Ingrediente,
              attributes: ['nombre', 'cantidad', 'precio'],
              required: false
            }
          ]
        }
      ],
      order: [['createdAt', 'DESC']]
    });

    res.json(pedidos);
  } catch (error) {
    console.error("ERROR GET MIS PEDIDOS:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// TODOS LOS PEDIDOS (admin)
// ======================
exports.getAll = async (req, res) => {
  try {
    const pedidos = await Pedido.findAll({
      include: [
        {
          model: Usuario,
          attributes: ['id', 'nombre', 'email', 'telefono']
        },
        {
          model: Direccion,
          attributes: ['direccion', 'barrio', 'tipoVivienda', 'instrucciones']
        },
        {
          model: DetallePedido,
          include: [
            {
              model: Menu,
              attributes: ['nombre', 'imagenUrl', 'precio'],
              required: false
            },
            {
              model: Ingrediente,
              attributes: ['nombre', 'cantidad', 'precio'],
              required: false
            }
          ]
        }
      ],
      order: [['createdAt', 'DESC']]
    });

    res.json(pedidos);
  } catch (error) {
    console.error("ERROR GET ALL PEDIDOS:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// ACTUALIZAR ESTADO (admin)
// ======================
exports.updateEstado = async (req, res) => {
  const { estado } = req.body;

  if (estado !== 'Enviado') {
    return res.status(400).json({ error: "Estado no válido" });
  }

  try {
    const pedido = await Pedido.findByPk(req.params.id);

    if (!pedido) {
      return res.status(404).json({ error: "Pedido no encontrado" });
    }

    if (pedido.estado !== 'Realizado') {
      return res.status(400).json({
        error: "Solo se pueden enviar pedidos Realizados"
      });
    }

    pedido.estado = estado;
    await pedido.save();

    res.json({ success: true, pedido });
  } catch (error) {
    console.error("ERROR UPDATE ESTADO:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// PEDIDOS PARA COCINA
// ======================
exports.getPedidosCocina = async (req, res) => {
  try {
    const pedidos = await Pedido.findAll({
      where: {
        estado: ['Pendiente', 'Activo', 'Realizado']
      },
      include: [
        {
          model: Usuario,
          attributes: ['id', 'nombre', 'email', 'telefono']
        },
        {
          model: Direccion,
          attributes: ['direccion', 'barrio', 'tipoVivienda']
        },
        {
          model: DetallePedido,
          include: [
            {
              model: Menu,
              attributes: ['nombre', 'imagenUrl', 'descripcion'],
              required: false
            },
            {
              model: Ingrediente,
              attributes: ['nombre', 'cantidad', 'tipo'],
              required: false
            }
          ]
        }
      ],
      order: [['createdAt', 'DESC']]
    });

    res.json(pedidos);
  } catch (error) {
    console.error("ERROR GET PEDIDOS COCINA:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};

// ======================
// CAMBIAR ESTADO COCINA
// ======================
exports.updateEstadoCocina = async (req, res) => {
  const { estado } = req.body;
  const estadosValidos = ['Activo', 'Realizado'];

  if (!estadosValidos.includes(estado)) {
    return res.status(400).json({ error: "Estado no válido" });
  }

  try {
    const pedido = await Pedido.findByPk(req.params.id);

    if (!pedido) {
      return res.status(404).json({ error: "Pedido no encontrado" });
    }

    pedido.estado = estado;
    await pedido.save();

    res.json({ success: true, pedido });
  } catch (error) {
    console.error("ERROR UPDATE ESTADO COCINA:", error);
    res.status(500).json({ error: "Error del servidor" });
  }
};