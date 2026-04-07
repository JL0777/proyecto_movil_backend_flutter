const { Pedido, DetallePedido, Menu, Ingrediente, Usuario } = require('../models');
const { Op, fn, col, literal } = require('sequelize');

// ======================
// REPORTE GENERAL
// ======================
exports.getReporte = async (req, res) => {
    try {

        // Total de pedidos
        const totalPedidos = await Pedido.count();

        // Pedidos por estado
        const porEstado = await Pedido.findAll({
            attributes: [
                'estado',
                [fn('COUNT', col('id')), 'total']
            ],
            group: ['estado']
        });


        // Ingresos totales
        const ingresos = await Pedido.findAll({
            attributes: [
                [fn('SUM', col('total')), 'totalIngresos'],
                [fn('SUM', col('subtotal')), 'totalSubtotal'],
                [fn('SUM', col('iva')), 'totalIva'],
            ]
        });

        // Pedidos por tipo
        const porTipo = await Pedido.findAll({
            attributes: [
                'tipo',
                [fn('COUNT', col('id')), 'total']
            ],
            group: ['tipo']
        });

        // Pedidos por método de pago
        const porMetodoPago = await Pedido.findAll({
            attributes: [
                'metodoPago',
                [fn('COUNT', col('id')), 'total']
            ],
            group: ['metodoPago']
        });

        // Últimos 7 pedidos
        const ultimosPedidos = await Pedido.findAll({
            include: [
                {
                    model: Usuario,
                    attributes: ['nombre', 'email', 'fotoPerfil']
                }
            ],
            order: [['createdAt', 'DESC']],
            limit: 7
        });

        // Total clientes
        const totalClientes = await Usuario.count({
            where: { rol: 'cliente' }
        });

        res.json({
            totalPedidos,
            totalClientes,
            porEstado,
            porTipo,
            porMetodoPago,
            ingresos: ingresos[0],
            ultimosPedidos
        });

    } catch (error) {
        console.error("ERROR GET REPORTE:", error);
        res.status(500).json({ error: "Error del servidor" });
    }
};

// ======================
// HISTORIAL DE PEDIDOS CON FILTROS
// ======================
exports.getHistorial = async (req, res) => {
  try {
    const { fechaInicio, fechaFin, estado, tipo, metodoPago } = req.query;

    const where = {};

    // Filtro por fecha
    if (fechaInicio && fechaFin) {
      where.createdAt = {
        [Op.between]: [
          new Date(`${fechaInicio}T00:00:00.000Z`),
          new Date(`${fechaFin}T23:59:59.999Z`)
        ]
      };
    } else if (fechaInicio) {
      where.createdAt = {
        [Op.gte]: new Date(`${fechaInicio}T00:00:00.000Z`)
      };
    } else if (fechaFin) {
      where.createdAt = {
        [Op.lte]: new Date(`${fechaFin}T23:59:59.999Z`)
      };
    }

    // Filtros opcionales
    if (estado) where.estado = estado;
    if (tipo) where.tipo = tipo;
    if (metodoPago) where.metodoPago = metodoPago;

    const pedidos = await Pedido.findAll({
      where,
      include: [
        {
          model: Usuario,
          attributes: ['id', 'nombre', 'email', 'telefono', 'fotoPerfil']
        },
        {
          model: DetallePedido,
          include: [
            {
              model: Menu,
              attributes: ['nombre', 'imagenUrl'],
              required: false
            },
            {
              model: Ingrediente,
              attributes: ['nombre'],
              required: false
            }
          ]
        }
      ],
      order: [['createdAt', 'DESC']]
    });

    // Resumen del período
    const totalPedidos = pedidos.length;
    const totalIngresos = pedidos.reduce(
      (sum, p) => sum + parseFloat(p.total), 0
    );
    const totalIva = pedidos.reduce(
      (sum, p) => sum + parseFloat(p.iva), 0
    );

    res.json({
      pedidos,
      resumen: {
        totalPedidos,
        totalIngresos,
        totalIva
      }
    });

  } catch (error) {
    console.error('ERROR GET HISTORIAL:', error);
    res.status(500).json({ error: 'Error del servidor' });
  }
};