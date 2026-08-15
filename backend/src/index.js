require('dotenv').config(); // <-- Debe ir al inicio del archivo
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

const app = express();

// Conectar a MongoDB
connectDB();

// Middlewares
app.use(cors());
app.use(express.json());

// Puerto
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Servidor ejecutándose en el puerto ${PORT}`);
});