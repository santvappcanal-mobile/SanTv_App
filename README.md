<div align="center">

# 📺 SanTv_App

**Plataforma de streaming accesible, inteligente y en vivo.**

[![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Backend-Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![Express.js](https://img.shields.io/badge/Framework-Express.js-000000?style=for-the-badge&logo=express&logoColor=white)](https://expressjs.org/)
[![MongoDB](https://img.shields.io/badge/Database-MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)


</div>

---

## 📖 Tabla de Contenidos
- [Descripción](#-descripción)
- [Stack Tecnológico](#-stack-tecnológico)
- [Características del Proyecto](#-características-del-proyecto)
- [Instalación y Configuración](#-instalación-y-configuración)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Autores](#-autores)
- [Formación](#-formación)
- [Estado del Proyecto](#-estado-del-proyecto)
- [Licencia](#-licencia)

---

## 📖 Descripción

**SAN.tv** es una app pensada para que cualquier persona pueda ver el contenido del canal de televisión, sin necesidad de tener el servicio de Asonet Colombia. Desde noticias, farándula, deportes hasta contenido local y nacional, todo estará disponible en el celular.

La aplicación usará inteligencia artificial para hacerla más útil: recomendará contenido según tus gustos, resumirá noticias y mostrará subtítulos en vivo para que todos puedan entender el contenido.

Será fácil de usar, rápida, segura, accesible para personas con discapacidad, compatible con varios dispositivos y siempre disponible. También cuidará tus datos personales, cumpliendo con la ley.

---

## 🚀 Stack Tecnológico

Para el desarrollo de **SAN.tv** trabajaremos con las siguientes tecnologías:

| Área | Tecnologías / Herramientas |
| :--- | :--- |
| **Frontend** | HTML5, CSS3, JavaScript, Flutter |
| **Backend** | Node.js, Express.js, Nodemon |
| **Base de Datos** | MongoDB |
| **Herramientas** | Git, GitHub, Visual Studio Code|

---

## ✨ Características del Proyecto

Entre las principales funcionalidades de **SAN.tv** se encuentran:

* 🔴 Transmisión en vivo del canal de televisión sin necesidad de tener el servicio de Asonet Colombia.
* 📺 Contenido variado disponible en el celular: noticias, farándula, deportes y contenido local y nacional.
* 💳 Pagos por tiempo de uso mediante recargas, usando métodos simples como códigos QR.
* 📢 Módulo para que las empresas puedan ver tarifas y pautar fácilmente dentro de la app.
* 🤖 **Funciones de Inteligencia Artificial:**
  * Recomendación de contenido según tus gustos.
  * Resumen automático de noticias.
  * Subtítulos en vivo para que todos puedan entender el contenido.
* ♿ Aplicación fácil de usar, rápida, segura y accesible para personas con discapacidad.
* 📱 Diseño compatible con varios dispositivos y siempre disponible.
* 🔐 Cuidado y protección de datos personales cumpliendo con la ley.

> 💡 *Las funcionalidades pueden ampliarse durante el desarrollo del proyecto.*

---

## ⚙️ Instalación y Configuración

### 1️⃣ Clonar el repositorio

Primero, clona el repositorio desde GitHub:

bash
```
git clone [https://github.com/santv/santv-app.git](https://github.com/santv/santv-app.git)
```
Luego ingresa a la carpeta del proyecto:


Bash
```
cd santv-app
```
##2️⃣ Instalar Node.js y npm
Descarga e instala Node.js, que incluye npm. Puedes verificar que la instalación sea correcta ejecutando:


Bash
```
node -v
npm -v
```
##3️⃣ Instalar las dependencias
Desde la carpeta del backend ejecuta:

Bash
```
npm install
```
##4️⃣ Dependencias principales
El backend utiliza:


Bash
```
npm install express
npm install mongodb
npm install dotenv
```
Para instalar Nodemon como dependencia de desarrollo:


Bash
```
npm install --save-dev nodemon
```
##5️⃣ Configurar MongoDB
Para ejecutar el proyecto es necesario contar con una base de datos en MongoDB.

Crear un archivo .env dentro de la carpeta backend:


##▶️ Ejecutar el servidor
Para iniciar el servidor en modo desarrollo:


Bash
```
npm run dev
```
Si todo está correctamente configurado, el servidor estará disponible en:


```text
http://localhost:3000
```
###📁 Estructura del Proyecto
La estructura general del proyecto será:


```text
santv-app/
│
├── backend/
│   ├── src/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── config/
│   │   └── server.js
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
│   └── server.html
│
└── README.md

```

##👥 Autores

Aprendices SENA:
Carlos Stiven Leon Huelgos
Juan David Angarita Rojas
Hanna Jeylin Vargas Fierro
Jhohan Stiven Gomez Criollo

##🎓 Formación
Servicio Nacional de Aprendizaje — SENA

Proyecto desarrollado como parte del proceso de formación de los aprendices.

##📌 Estado del Proyecto
##🚧 En desarrollo

El proyecto se encuentra actualmente en proceso de desarrollo. Se irán agregando nuevas funcionalidades y mejoras durante las diferentes etapas del proyecto.

##📄 Licencia
Este proyecto fue desarrollado con fines educativos como parte del proceso de formación del SENA.
