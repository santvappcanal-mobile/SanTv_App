// 1. Importar Express
const express = require('express');

// 2. Inicializar la aplicación
const app = express();

// 3. Definir el puerto donde correrá el servidor
const PORT = process.env.PORT || 3000;

// 4. Crear una ruta de prueba para verificar que funciona
app.get('/', (req, res) => {
    res.send('¡Servidor del backend funcionando correctamente!');
});

// 5. Encender el servidor y escuchar peticiones
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});