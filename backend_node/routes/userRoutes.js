const express = require('express');
const router = express.Router();

const userController = require('../controllers/userController');
const verifyToken = require('../middleware/authMiddleware');


router.put('/name', verifyToken, userController.updateName);
router.put('/email', verifyToken, userController.updateEmail);
router.put('/phone', verifyToken, userController.updatePhone);
router.put('/password', verifyToken, userController.updatePassword);


module.exports = router;