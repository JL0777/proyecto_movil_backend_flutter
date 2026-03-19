const express = require('express');
const router = express.Router();
const passwordResetController = require('../controllers/passwordResetController');

router.post('/solicitar-codigo', passwordResetController.solicitarCodigo);
router.post('/verificar-codigo', passwordResetController.verificarCodigo);
router.post('/cambiar-password', passwordResetController.cambiarPassword);

module.exports = router;