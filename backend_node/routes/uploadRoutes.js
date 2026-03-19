const express = require('express');
const router = express.Router();
const { upload, uploadImagen, eliminarImagen } = require('../controllers/uploadController');
const verifyToken = require('../middleware/authMiddleware');

router.post('/', verifyToken, upload.single('imagen'), uploadImagen);
router.delete('/:filename', verifyToken, eliminarImagen);

module.exports = router;