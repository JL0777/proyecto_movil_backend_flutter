const express = require('express');
const cors = require('cors');
require('dotenv').config();

const db = require('./models');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const addressRoutes = require('./routes/addressRoutes');

// Rutas de HEAD
const categoriaRoutes = require('./routes/categoriaRoutes');
const menuRoutes = require('./routes/menuRoutes');
const ingredienteRoutes = require('./routes/ingredienteRoutes');
const pedidoRoutes = require('./routes/pedidoRoutes');
const ventasRoutes = require('./routes/ventasRoutes');
const uploadRoutes = require('./routes/uploadRoutes');
const path = require('path');

// Rutas de la otra rama
const passwordResetRoutes = require('./routes/passwordResetRoutes');

const app = express();

app.use(cors());
app.use(express.json());

// Rutas principales
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/addresses', addressRoutes);

// Rutas HEAD
app.use('/api/categorias', categoriaRoutes);
app.use('/api/menus', menuRoutes);
app.use('/api/ingredientes', ingredienteRoutes);
app.use('/api/pedidos', pedidoRoutes);
app.use('/api/ventas', ventasRoutes);

// Archivos estáticos
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Upload
app.use('/api/upload', uploadRoutes);

// Ruta nueva (password reset)
app.use('/api/password-reset', passwordResetRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Backend funcionando correctamente' });
});

const PORT = 3000;

// Puedes elegir si quieres alter:true o no
db.sequelize.sync({ alter: true }).then(() => {
  console.log('Base de datos sincronizada correctamente');

  app.listen(PORT, () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
  });

}).catch((error) => {
  console.error('Error al conectar con la base de datos:', error);
});