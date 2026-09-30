require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const connectDB = require('./config/db');
const { notFound, errorHandler } = require('./middleware/errorHandler');
const { initLiveSocket } = require('./sockets/liveSocket');

const app = express();

// Conectar a MongoDB
connectDB();

// Middlewares
app.use(cors());
app.use(express.json());

// Rutas de la API
app.use('/api/users', require('./routes/users'));
app.use('/api/content', require('./routes/contentRoutes'));
app.use('/api/live-events', require('./routes/liveEventRoutes'));
app.use('/api/ads', require('./routes/adRoutes'));
app.use('/api/notifications', require('./routes/notificationRoutes'));
app.use('/api/watchlist', require('./routes/watchlistRoutes'));
app.use('/api/uploads', require('./routes/upload.routes'));
app.use('/api/admin', require('./routes/adminRoutes'));
app.use('/api/chat', require('./routes/chatRoutes'));

// Manejo de errores
app.use(notFound);
app.use(errorHandler);

// Servidor HTTP + Socket.IO (necesario para el contador de EN VIVO)
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*' }, // ajusta esto a tu dominio real en producción
});
initLiveSocket(io);

// Puerto de ejecución
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 Servidor ejecutándose en el puerto ${PORT}`);
  console.log(`🔴 Socket.IO listo para EN VIVO`);
});