const express = require('express');
const router = express.Router();
const ingredienteController = require('../controllers/ingredienteController');
const verifyToken = require('../middleware/authMiddleware');

// Ruta pública
router.get('/publico/tipo/:tipo', ingredienteController.getByTipoPublico);

// Cliente
router.get('/tipo/:tipo', verifyToken, ingredienteController.getByTipo);

// Admin
router.get('/', verifyToken, ingredienteController.getAll);
router.post('/', verifyToken, ingredienteController.create);
router.put('/:id', verifyToken, ingredienteController.update);
router.delete('/:id', verifyToken, ingredienteController.destroy);
router.patch('/:id/toggle', verifyToken, ingredienteController.toggleDisponible);

module.exports = router;