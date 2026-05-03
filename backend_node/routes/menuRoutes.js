const express = require('express');
const router = express.Router();
const menuController = require('../controllers/menuController');
const verifyToken = require('../middleware/authMiddleware');

// Rutas PÚBLICAS (sin token)
router.get('/publico/buscar', menuController.buscar);
router.get('/publico/categoria/:categoriaId', menuController.getByCategoria);
router.get('/publico/balanceados', menuController.getMenusBalanceados);

// Cliente
router.get('/balanceados', verifyToken, menuController.getMenusBalanceados);
router.get('/categoria/:categoriaId', verifyToken, menuController.getByCategoria);
router.get('/buscar', verifyToken, menuController.buscar);
router.get('/:id', verifyToken, menuController.getOne);

// Admin
router.get('/', verifyToken, menuController.getAll);
router.post('/', verifyToken, menuController.create);
router.put('/nutricional/:id', verifyToken, menuController.updateNutricional); 
router.put('/:id', verifyToken, menuController.update);
router.delete('/:id', verifyToken, menuController.destroy);
router.patch('/:id/toggle', verifyToken, menuController.toggleDisponible);

module.exports = router;