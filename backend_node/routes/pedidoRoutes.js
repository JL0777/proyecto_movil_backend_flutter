const express = require('express');
const router = express.Router();
const pedidoController = require('../controllers/pedidoController');
const verifyToken = require('../middleware/authMiddleware');

// Rutas específicas
router.get('/mis-pedidos', verifyToken, pedidoController.getMisPedidos);
router.get('/cocina', verifyToken, pedidoController.getPedidosCocina);
router.get('/', verifyToken, pedidoController.getAll);

// Crear
router.post('/', verifyToken, pedidoController.create);

// Rutas con parámetro /:id al final
router.put('/:id/editar', verifyToken, pedidoController.editarPedido);
router.put('/:id/estado', verifyToken, pedidoController.updateEstado);
router.put('/:id/estado-cocina', verifyToken, pedidoController.updateEstadoCocina);
router.delete('/:id', verifyToken, pedidoController.cancelarPedido);

module.exports = router;