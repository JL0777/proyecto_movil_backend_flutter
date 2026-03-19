const express = require('express');
const cors = require('cors');
require('dotenv').config();

const db = require('./models'); 
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const addressRoutes = require('./routes/addressRoutes');
const categoriaRoutes = require('./routes/categoriaRoutes');
const menuRoutes = require('./routes/menuRoutes');
const ingredienteRoutes = require('./routes/ingredienteRoutes');
const pedidoRoutes = require('./routes/pedidoRoutes');
const ventasRoutes = require('./routes/ventasRoutes');
const uploadRoutes = require('./routes/uploadRoutes');
const path = require('path');


const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/addresses', addressRoutes);
app.use('/api/categorias', categoriaRoutes);
app.use('/api/menus', menuRoutes);
app.use('/api/ingredientes', ingredienteRoutes);
app.use('/api/pedidos', pedidoRoutes);
app.use('/api/ventas', ventasRoutes);

// Servir archivos estáticos
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Ruta upload
app.use('/api/upload', uploadRoutes);

// Ruta de prueba
app.get('/', (req, res) => {
    res.json({ message: 'Backend funcionando correctamente' });
});

const PORT = 3000;

db.sequelize.sync({ alter: true }).then(() => {
    console.log('Base de datos sincronizada correctamente');

    app.listen(PORT, () => {
        console.log(`Servidor corriendo en puerto ${PORT}`);
    });
}).catch((error) => {
    console.error('Error al conectar con la base de datos:', error);
});