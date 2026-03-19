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
                    attributes: ['nombre', 'email']
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