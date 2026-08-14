Plaintext
# SanTv_App


## 📖 Descripción

**SAN.tv** es una app pensada para que cualquier persona pueda ver en vivo el canal de televisión, sin necesidad de tener el servicio de Asonet Colombia. Desde noticias, farándula, deportes hasta contenido local y nacional, todo estará disponible en el celular.

Los usuarios podrán pagar por tiempo de uso mediante recargas, usando métodos simples como códigos QR. Además, las empresas podrán ver tarifas y pautar fácilmente dentro de la app.

La aplicación usará inteligencia artificial para hacerla más útil: recomendará contenido según tus gustos, resumirá noticias, tendrá control por voz y mostrará subtítulos en vivo para que todos puedan entender el contenido.

Será fácil de usar, rápida, segura, accesible para personas con discapacidad, compatible con varios dispositivos y siempre disponible. También cuidará tus datos personales, cumpliendo con la ley.

---

## 🚀 Stack tecnológico

Para el desarrollo de **SAN.tv** trabajaremos con las siguientes tecnologías:

### Frontend

* HTML5
* CSS3
* JavaScript
* Flutter

### Backend

* Node.js
* Express.js
* Nodemon

### Base de datos

* MongoDB

### Herramientas

* Git
* GitHub
* Visual Studio Code
* npm

---

## ✨ Características del proyecto

Entre las principales funcionalidades de **SAN.tv** se encuentran:

* 🔴 Transmisión en vivo del canal de televisión sin necesidad de tener el servicio de Asonet Colombia.
* 📺 Contenido variado disponible en el celular: noticias, farándula, deportes y contenido local y nacional.
* 💳 Pagos por tiempo de uso mediante recargas, usando métodos simples como códigos QR.
* 📢 Módulo para que las empresas puedan ver tarifas y pautar fácilmente dentro de la app.
* 🤖 **Funciones de Inteligencia Artificial:**
  * Recomendación de contenido según tus gustos.
  * Resumen automático de noticias.
  * Control por voz.
  * Subtítulos en vivo para que todos puedan entender el contenido.
* ♿ Aplicación fácil de usar, rápida, segura y accesible para personas con discapacidad.
* 📱 Diseño compatible con varios dispositivos y siempre disponible.
* 🔐 Cuidado y protección de datos personales cumpliendo con la ley.

> Las funcionalidades pueden ampliarse durante el desarrollo del proyecto.

---

## ⚙️ Instalación y configuración

### 1. Clonar el repositorio

Primero, clona el repositorio desde GitHub:

bash
git clone [https://github.com/santv/santv-app.git](https://github.com/santv/santv-app.git)
Luego ingresa a la carpeta del proyecto:

'''Bash
cd santv-app
'''
###2. Instalar Node.js y npm
Descarga e instala Node.js, que incluye npm.

Puedes verificar que la instalación sea correcta ejecutando:

Bash
node -v
npm -v
3. Instalar las dependencias
Desde la carpeta del backend ejecuta:

'''Bash
npm install
4. Dependencias principales
El backend utiliza:
'''

'''Bash
npm install express
npm install mongodb
npm install dotenv
'''
Para instalar Nodemon como dependencia de desarrollo:

'''Bash
npm install --save-dev nodemon
'''
###5. Configurar MongoDB

Para ejecutar el proyecto es necesario contar con una base de datos en MongoDB.

Crear un archivo .env dentro de la carpeta backend:

'''env
PORT=3000
MONGODB_URI=mongodb+srv://santv:tu_password@santv.ibteu0d.mongodb.net/?appName=SanTV
'''
>No subir el archivo .env a GitHub. Se recomienda agregarlo al archivo .gitignore.

---

###▶️ Ejecutar el servidor
Para iniciar el servidor en modo desarrollo:

'''Bash
npm run dev
'''
Si todo está correctamente configurado, el servidor estará disponible en:

'''text
http://localhost:3000
'''

##📁 Estructura del proyecto
La estructura general del proyecto será:


'''test
santv-app/
│
├── backend/
│   ├── src/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── config/
│   │   └── app.js
│   │
│   ├── .env
│   ├── .gitignore
│   ├── package.json
│   └── server.js
│
├── frontend/
│   ├── css/
│   ├── js/
│   ├── img/
│   └── index.html
│
└── README.md
'''

---
👥 Autores
Aprendices SENA
Carlos stiven  Leon Huelgos
Juan David Angarita Rojas
Hanna Jeylin Vargas Fierro
Jhohan Stiven Gomez Criollo



##🎓 Formación

**Servicio Nacional de Aprendizaje — SENA**

Proyecto desarrollado como parte del proceso de formación de los aprendices.

---

##📌 Estado del proyecto
🚧 *En desarrollo*

El proyecto se encuentra actualmente en proceso de desarrollo. Se irán agregando nuevas funcionalidades y mejoras durante las diferentes etapas del proyecto.

---

##📄 Licencia
Este proyecto fue desarrollado con fines educativos como parte del proceso de formación del SENA.


