const express = require('express');
const router = express.Router();
const categoriaController = require('../controllers/categoriaController');
const verifyToken = require('../middleware/authMiddleware');

// Rutas PÚBLICAS (sin token)
router.get('/publico', categoriaController.getAll);
router.get('/publico/tipo/:tipo', categoriaController.getByTipo);

router.get('/tipo/:tipo', verifyToken, categoriaController.getByTipo);
router.get('/', verifyToken, categoriaController.getAll);
router.post('/', verifyToken, categoriaController.create);
router.put('/:id', verifyToken, categoriaController.update);
router.delete('/:id', verifyToken, categoriaController.destroy);

module.exports = router;