const express = require('express');
const cors = require('cors');
const http = require('http');           
const { Server } = require('socket.io');
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
const passwordResetRoutes = require('./routes/passwordResetRoutes');
const iaRoutes = require('./routes/iaRoutes');
const path = require('path');

const app = express();

// ── Crear servidor HTTP y Socket.io ──────────────────────────
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

// Exportar io para usarlo en los controladores
global.io = io;

io.on('connection', (socket) => {
  console.log('🔌 Cliente conectado:', socket.id);

  socket.on('disconnect', () => {
    console.log('Cliente desconectado:', socket.id);
  });
});
// ────────────────────────────────────────────────────────────

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/addresses', addressRoutes);
app.use('/api/categorias', categoriaRoutes);
app.use('/api/menus', menuRoutes);
app.use('/api/ingredientes', ingredienteRoutes);
app.use('/api/pedidos', pedidoRoutes);
app.use('/api/ventas', ventasRoutes);
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use('/api/upload', uploadRoutes);
app.use('/api/password-reset', passwordResetRoutes);
app.use('/api/ia', iaRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Backend funcionando correctamente' });
});

const PORT = process.env.PORT || 3000;

db.sequelize.sync({ force: false }).then(() => {
  console.log('Base de datos sincronizada correctamente');

  server.listen(PORT, () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
    console.log(`Socket.io activo en puerto ${PORT}`);
  });
}).catch((error) => {
  console.error('Error al conectar con la base de datos:', error);
});