const express = require('express');
const router = express.Router();
const ventasController = require('../controllers/ventasController');
const verifyToken = require('../middleware/authMiddleware');

router.get('/reporte', verifyToken, ventasController.getReporte);

module.exports = router;