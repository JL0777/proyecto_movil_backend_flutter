const express = require('express');
const cors = require('cors');
require('dotenv').config();

const db = require('./models'); 
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const addressRoutes = require('./routes/addressRoutes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/addresses', addressRoutes);

// Ruta de prueba
app.get('/', (req, res) => {
    res.json({ message: 'Backend funcionando correctamente' });
});

const PORT = 3000;

db.sequelize.sync().then(() => {
    console.log('Base de datos sincronizada correctamente');

    app.listen(PORT, () => {
        console.log(`Servidor corriendo en puerto ${PORT}`);
    });
}).catch((error) => {
    console.error('Error al conectar con la base de datos:', error);
});