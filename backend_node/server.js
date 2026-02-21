const express = require('express');
const cors = require('cors');
require('dotenv').config();

const db = require('./models'); // 👈 IMPORTANTE: db, no sequelize directo
const authRoutes = require('./routes/authRoutes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);

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