const { Pedido, DetallePedido, Menu, Ingrediente, Usuario, Direccion } = require('../models');

// ======================
// CREAR PEDIDO (cliente)
// ======================
exports.create = async (req, res) => {
  const { direccionId, tipo, metodoPago, items } = req.body;
  const usuarioId = req.user.id;

  if (!direccionId || !tipo || !metodoPago || !items || items.length === 0) {
    return res.status(400).json({ error: "Todos los campos son requeridos" });
  }

  try {
    let total = 0;

    // ── Calcular total detectando tipo POR ITEM ──────────────
    for (const item of items) {
      if (item.menuId != null) {
        // Es un menú predefinido
        const menu = await Menu.findByPk(item.menuId);
        if (!menu) return res.status(404).json({ error: "Menú no encontrado" });
        total += parseFloat(menu.precio) * item.cantidad;
      } else if (item.ingredienteId != null) {
        // Es un ingrediente o bebida
        const ingrediente = await Ingrediente.findByPk(item.ingredienteId);
        if (!ingrediente) return res.status(404).json({ error: "Ingrediente no encontrado" });
        total += parseFloat(ingrediente.precio) * item.cantidad;
      } else {
        return res.status(400).json({ error: "Item inválido: debe tener menuId o ingredienteId" });
      }
    }

    const iva = total - (total / 1.19);
    const subtotal = total - iva;

    // ── Crear pedido ─────────────────────────────────────────
    const pedido = await Pedido.create({
      usuarioId,
      direccionId,
      tipo,
      metodoPago,
      subtotal,
      iva,
      total
    });

    // ── Crear detalles detectando tipo POR ITEM ──────────────
    for (const item of items) {
      if (item.menuId != null) {
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
// TODOS LOS PEDIDOS (admin) — solo Enviados
// ======================
exports.getAll = async (req, res) => {
  try {
    const pedidos = await Pedido.findAll({
      where: {
        estado: ['Enviado']
      },
      include: [
        {
          model: Usuario,
          attributes: ['id', 'nombre', 'email', 'telefono', 'fotoPerfil']
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
// ACTUALIZAR ESTADO (admin) — ya no se usa
// ======================
exports.updateEstado = async (req, res) => {
  const { estado } = req.body;

  try {
    const pedido = await Pedido.findByPk(req.params.id);

    if (!pedido) {
      return res.status(404).json({ error: "Pedido no encontrado" });
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
// CAMBIAR ESTADO COCINA — ahora incluye Enviado
// ======================
exports.updateEstadoCocina = async (req, res) => {
  const { estado } = req.body;
  const estadosValidos = ['Activo', 'Realizado', 'Enviado'];

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

// ======================
// CANCELAR PEDIDO (cliente)
// ======================
exports.cancelarPedido = async (req, res) => {
  const usuarioId = req.user.id;

  try {
    const pedido = await Pedido.findOne({
      where: { id: req.params.id, usuarioId }
    });

    if (!pedido) {
      return res.status(404).json({ error: 'Pedido no encontrado' });
    }

    if (pedido.estado !== 'Pendiente') {
      return res.status(400).json({
        error: 'Solo puedes cancelar pedidos en estado Pendiente'
      });
    }

    await DetallePedido.destroy({ where: { pedidoId: pedido.id } });
    await pedido.destroy();

    res.json({ success: true, message: 'Pedido cancelado correctamente' });
  } catch (error) {
    console.error('ERROR CANCELAR PEDIDO:', error);
    res.status(500).json({ error: 'Error del servidor' });
  }
};

// EDITAR PEDIDO (cliente) — solo si está Pendiente
exports.editarPedido = async (req, res) => {
  const usuarioId = req.user.id;
  const { direccionId, metodoPago, items } = req.body;

  try {
    const pedido = await Pedido.findOne({
      where: { id: req.params.id, usuarioId }
    });

    if (!pedido) {
      return res.status(404).json({ error: 'Pedido no encontrado' });
    }

    if (pedido.estado !== 'Pendiente') {
      return res.status(400).json({
        error: 'Solo puedes editar pedidos en estado Pendiente'
      });
    }

    if (direccionId) pedido.direccionId = direccionId;
    if (metodoPago) pedido.metodoPago = metodoPago;

    if (items && items.length > 0) {
      let total = 0;

      for (const item of items) {
        if (item.menuId != null) {
          const menu = await Menu.findByPk(item.menuId);
          if (!menu) return res.status(404).json({ error: 'Menú no encontrado' });
          total += parseFloat(menu.precio) * item.cantidad;
        } else if (item.ingredienteId != null) {
          const ingrediente = await Ingrediente.findByPk(item.ingredienteId);
          if (!ingrediente) return res.status(404).json({ error: 'Ingrediente no encontrado' });
          total += parseFloat(ingrediente.precio) * item.cantidad;
        } else {
          return res.status(400).json({ error: 'Item inválido' });
        }
      }

      const iva = total - (total / 1.19);
      const subtotal = total - iva;

      pedido.total = total;
      pedido.iva = iva;
      pedido.subtotal = subtotal;

      await DetallePedido.destroy({ where: { pedidoId: pedido.id } });

      for (const item of items) {
        if (item.menuId != null) {
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
    }

    await pedido.save();

    res.json({ success: true, pedido });
  } catch (error) {
    console.error('ERROR EDITAR PEDIDO:', error);
    res.status(500).json({ error: 'Error del servidor' });
  }
};