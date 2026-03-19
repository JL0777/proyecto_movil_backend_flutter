const express = require('express');
const router = express.Router();
const menuController = require('../controllers/menuController');
const verifyToken = require('../middleware/authMiddleware');

// Rutas PUBLICAS (sin token)
router.get('/publico/buscar', menuController.buscar);
router.get('/publico/categoria/:categoriaId', menuController.getByCategoria);

// Cliente
router.get('/categoria/:categoriaId', verifyToken, menuController.getByCategoria);
router.get('/buscar', verifyToken, menuController.buscar);
router.get('/:id', verifyToken, menuController.getOne);

// Admin
router.get('/', verifyToken, menuController.getAll);
router.post('/', verifyToken, menuController.create);
router.put('/:id', verifyToken, menuController.update);
router.delete('/:id', verifyToken, menuController.destroy);

module.exports = router;