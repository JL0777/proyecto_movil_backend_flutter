const express = require('express');
const router = express.Router();
const pedidoController = require('../controllers/pedidoController');
const verifyToken = require('../middleware/authMiddleware');

// Cliente
router.post('/', verifyToken, pedidoController.create);
router.get('/mis-pedidos', verifyToken, pedidoController.getMisPedidos);

// Admin
router.get('/', verifyToken, pedidoController.getAll);
router.put('/:id/estado', verifyToken, pedidoController.updateEstado);

// Cocina
router.get('/cocina', verifyToken, pedidoController.getPedidosCocina);
router.put('/:id/estado-cocina', verifyToken, pedidoController.updateEstadoCocina);

module.exports = router;