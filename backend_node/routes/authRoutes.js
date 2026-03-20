const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/register', authController.register);
router.post('/verificar-registro', authController.verificarRegistro);
router.post('/reenviar-codigo-registro', authController.reenviarCodigoRegistro);
router.post('/login', authController.login);

module.exports = router;