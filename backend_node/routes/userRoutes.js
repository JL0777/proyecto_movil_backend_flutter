const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const verifyToken = require('../middleware/authMiddleware');

// Cliente
router.put('/name', verifyToken, userController.updateName);
router.put('/email', verifyToken, userController.updateEmail);
router.put('/phone', verifyToken, userController.updatePhone);
router.put('/password', verifyToken, userController.updatePassword);

// Admin
router.get('/', verifyToken, userController.getAllUsers);
router.get('/:id', verifyToken, userController.getUserById);
router.put('/:id', verifyToken, userController.adminUpdateUser);
router.put('/:id/password', verifyToken, userController.adminUpdatePassword);
router.delete('/:id', verifyToken, userController.deleteUser);

module.exports = router;