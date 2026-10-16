<div align="center">

# 📺 SanTv_App

**Tu canal de televisión, en vivo y en tu bolsillo.**

[![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Backend-Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![Express.js](https://img.shields.io/badge/Framework-Express.js-000000?style=for-the-badge&logo=express&logoColor=white)](https://expressjs.com/)
[![MongoDB](https://img.shields.io/badge/Database-MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![Socket.IO](https://img.shields.io/badge/Realtime-Socket.IO-010101?style=for-the-badge&logo=socketdotio&logoColor=white)](https://socket.io/)

</div>

---

# 📖 Tabla de Contenidos
- [Descripción](#-descripción)
- [Funcionalidades](#-funcionalidades)
- [Stack Tecnológico](#-stack-tecnológico)
- [Arquitectura](#-arquitectura)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Instalación y Configuración](#-instalación-y-configuración)
- [API del Backend](#-api-del-backend)
- [Tiempo real (Socket.IO)](#-tiempo-real-socketio)
- [Roles de usuario](#-roles-de-usuario)
- [Funcionalidades planeadas](#-funcionalidades-planeadas)
- [Cronograma](#-cronograma)
- [Autores](#-autores)
- [Estado del Proyecto](#-estado-del-proyecto)
- [Licencia](#-licencia)

---

# 📖 Descripción

**SAN TV** lleva el canal de televisión al bolsillo de cada persona. Con la app puedes ver la transmisión en vivo del canal las 24 horas, ponerte al día con las noticias y los deportes locales, y descubrir videos de contenido local y educativo, sin necesidad de tener el servicio de Asonet Colombia.

Más que un reproductor, SAN TV es una experiencia compartida alrededor del canal: mientras ves el en vivo puedes **comentar en tiempo real** con otros televidentes, ver cuántas personas te acompañan, guardar tus videos favoritos en **Mi Lista** y recibir un aviso apenas el canal sale al aire. Un **asistente con inteligencia artificial** te ayuda a encontrar lo que quieres ver y resuelve tus dudas sobre el canal y sus servicios.

Para el canal, la app también es una herramienta de trabajo: un **panel de administración** para publicar videos (incluso desde un link de YouTube), ver qué contenido es el más visto y gestionarlo, y un **módulo de publicidad** donde las empresas conocen los planes, el portafolio y los documentos para pautar en SAN TV.

Está construida con **Flutter** en el frontend y **Node.js, Express y MongoDB** en el backend, con comunicación en tiempo real mediante **Socket.IO**.

---

# ✨ Funcionalidades

### 🔐 Cuenta y acceso
- Pantalla de bienvenida con splash nativo y revisión automática de sesión.
- Login y registro en una misma pantalla con pestañas (la lógica de cada uno está separada).
- Inicio de sesión con **Google** (OAuth) además de usuarios propios con registro local.
- Verificación de la cuenta con **código enviado al correo** y recuperación de contraseña.
- Validaciones: el nombre acepta solo letras; la contraseña exige mínimo 6 caracteres con letras, números y al menos un carácter especial.
- Sesión guardada de forma segura en el dispositivo (`flutter_secure_storage`).

### 🏠 Inicio
- Canal en vivo con reproducción automática, sincronizado con la pestaña En vivo (al tocarlo lleva a En vivo).
- Videos destacados (más vistos) y sección de publicidad.
- Anuncio emergente aleatorio al entrar a la app.
- Aviso y notificación cuando el canal pasa a **EN VIVO**.

### 🔍 Explorar
- Contenido organizado por categorías: **Todo, Deportes, Noticias y Educación** (chips).
- Búsqueda por título.
- Guardar videos en **Mi Lista** desde la tarjeta.
- Reproductor de YouTube y reproductor de video propio según el origen del contenido.

### 🔴 En vivo
- Canal en vivo permanente (24/7) con reproducción automática.
- **Pantalla completa propia**: el video no se deforma, gira con el teléfono (vertical/horizontal).
- **Comentarios en vivo** estilo Facebook Live: encima del video en horizontal y debajo en vertical. Se borran automáticamente a las **4 horas** (índice TTL en MongoDB).
- **Contador de espectadores en tiempo real** y lista de quiénes están viendo.
- Debajo del canal aparecen los videos que el admin marque con **"Mostrar en la pestaña En vivo"**.

### 👤 Perfil
- Datos del usuario, editar perfil (foto desde galería, cámara o avatar; nombre y correo).
- Contadores reales de **Favoritos** (Mi Lista) y **Vistos**.
- Mi Lista, Publicidad, Configuración y cierre de sesión.
- Las vistas de un video cuentan **una sola vez por usuario**.

### 📢 Publicidad
- Pestañas **Referencias, Documentos y Portafolio**.
- Documentos y contratos en PDF (subida con Cloudinary; solo el admin sube y elimina, los usuarios los ven y descargan).
- Portafolio de videos e imágenes publicitarias.
- Vistas distintas para usuarios normales y para el equipo comercial/admin.

### 🤖 Asistente de chat con IA
- Basado en **Groq** (modelo `openai/gpt-oss-20b`).
- Ayuda a encontrar contenido (noticias, deportes, videos), responde sobre publicidad y costos, indica el video más visto de la semana e informa sobre los servicios del canal.

### 🛠️ Panel de administración
- Dashboard con estadísticas: usuarios, contenido, vistas totales, anuncios y eventos en vivo.
- **Top 5 de contenido más visto**, con opciones de editar título/descripción y eliminar.
- Agregar videos por **link de YouTube** (con vista previa) o subir contenido desde el computador (Cloudinary).
- Interruptor para mostrar un video también en la pestaña En vivo.

---

# 🚀 Stack Tecnológico

| Área | Tecnologías / Herramientas |
| :--- | :--- |
| **Frontend** | Flutter (Dart), `http`, `socket_io_client`, `flutter_secure_storage`, `webview_flutter`, `youtube_player_iframe`, `video_player`, `google_sign_in`, `file_picker`, `image_picker`, `cached_network_image`, `url_launcher`, `flutter_native_splash` |
| **Backend** | Node.js (CommonJS), Express.js, Mongoose, Socket.IO, JWT, bcrypt, Multer, Nodemon |
| **Base de Datos** | MongoDB Atlas (base `SanTv`) |
| **Servicios externos** | Cloudinary (videos, imágenes y PDF), Groq (IA), Google Sign-In (OAuth), servicio de streaming propio del canal |
| **Herramientas** | Git, GitHub, Visual Studio Code, Android Studio, Postman |

---

# 🧩 Arquitectura

```text
┌────────────────────┐      HTTP (REST)       ┌─────────────────────────┐
│   App Flutter      │ ─────────────────────► │  Backend Node/Express   │
│  (Android / iOS)   │ ◄───────────────────── │   /api/...              │
│                    │      Socket.IO         │   Socket.IO (en vivo)   │
└─────────┬──────────┘ ◄────────────────────► └───────┬─────────┬───────┘
          │                                            │         │
          │ WebView (autoplay)                         │         │
          ▼                                            ▼         ▼
 Streaming del canal                              MongoDB     Cloudinary
 (servicio propio)                                 Atlas      Groq / Google
```

---

# 📁 Estructura del Proyecto

```text
SanTv_App/
│
├── backend/
│   ├── src/
│   │   ├── config/            # db.js, cloudinary.js
│   │   ├── controllers/       # lógica de cada módulo (users, content, ads, chat, admin...)
│   │   ├── middleware/        # auth.js, errorHandler.js, upload.js
│   │   ├── models/            # User, Content, Ad, LiveEvent, Notification, Watchlist, LiveComment...
│   │   ├── routes/            # una ruta por módulo (ver sección API)
│   │   ├── sockets/           # liveSocket.js (espectadores), liveCommentsSocket.js (comentarios)
│   │   ├── utils/             # generateToken.js, mailer.js, youtube.js
│   │   └── index.js           # punto de entrada (Express + Socket.IO)
│   ├── .env
│   └── package.json
│
├── frontend/                  # proyecto Flutter (paquete santv_app)
│   ├── lib/
│   │   ├── models/            # app_user, content, live_viewer, live_comment...
│   │   ├── pages/             # pantallas (home, explore, live_tab, profile, publicidad, admin...)
│   │   ├── services/          # auth, content, ads, chat, notifications, live viewer/comments...
│   │   ├── widgets/           # widgets reutilizables organizados por módulo
│   │   │   ├── admin/  ads/  auth/  common/  explore/
│   │   │   ├── home/   live/  live_tab/  notifications/  profile/ ...
│   │   └── main.dart
│   ├── assets/img/            # logo.png, original.png
│   └── pubspec.yaml
│
└── README.md
```

---

# ⚙️ Instalación y Configuración

## Requisitos
- [Node.js](https://nodejs.org/) y npm
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.12.2`) y Android Studio (o un teléfono físico)
- Cuenta de MongoDB Atlas, Cloudinary, Groq y un proyecto de Google Cloud con OAuth configurado

## 1️⃣ Clonar el repositorio

```bash
git clone https://github.com/santvappcanal-mobile/SanTv_App.git
cd SanTv_App
```

## 2️⃣ Backend

```bash
cd backend
npm install
```

Crea un archivo `.env` dentro de `backend/` (los nombres son de ejemplo, usa los que tenga tu proyecto):

```env
PORT=3000
MONGO_URI=tu_cadena_de_conexion_de_mongodb_atlas
JWT_SECRET=una_clave_secreta_larga
GOOGLE_CLIENT_ID=tu_client_id_de_google
GROQ_API_KEY=tu_api_key_de_groq
CLOUDINARY_CLOUD_NAME=tu_cloud_name
CLOUDINARY_API_KEY=tu_api_key
CLOUDINARY_API_SECRET=tu_api_secret
# Credenciales del correo que envía los códigos de verificación
```

Inicia el servidor en modo desarrollo:

```bash
npm run dev
```

El servidor queda disponible en `http://localhost:3000` y muestra en consola que Socket.IO está listo.

## 3️⃣ Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

- La app resuelve sola la dirección del backend probando `localhost`, `10.0.2.2` (emulador de Android) y la IP de la red local de la PC, así funciona en emulador y en teléfono físico sin cambiar código.
- Con un teléfono físico, el celular y el computador deben estar en la misma red.
- Si cambias los logos, regenera el splash nativo con `dart run flutter_native_splash:create`.

---

# 🔌 API del Backend

Todas las rutas cuelgan de `/api`. Las respuestas siguen el formato `{ success, data, message }`. Las rutas privadas usan el token en `Authorization: Bearer <token>`.

| Prefijo | Descripción |
| :--- | :--- |
| `/api/users` | Registro, login, login con Google (`/login-google`), verificación por código, recuperación de contraseña, perfil y gestión de usuarios (admin) |
| `/api/content` | Catálogo de videos: listar, detalle, crear, editar, eliminar, vistas (`/:id/view`), publicar/ocultar (`/:id/publish`), vista previa y creación desde YouTube (`/youtube-preview`, `/from-youtube`), listado para admin (`/admin`) |
| `/api/live-events` | Eventos en vivo puntuales |
| `/api/live-channel` | Estado del canal en vivo |
| `/api/ads` | Anuncios y portafolio publicitario (galería, imágenes, anuncios por contenido) |
| `/api/ad-documents` | Documentos y contratos de publicidad (PDF) |
| `/api/ad-references` | Referencias de publicidad |
| `/api/notifications` | Notificaciones del usuario |
| `/api/watchlist` | Mi Lista (guardados) y videos vistos |
| `/api/uploads` | Subida de imágenes, videos y documentos a Cloudinary y eliminación por `publicId` |
| `/api/admin` | Estadísticas del panel de administración (`/stats`) |
| `/api/chat` | Asistente de IA (`POST` con `{ mensaje }`, responde `{ success, respuesta }`) |
| `/api/youtube` | Utilidades de YouTube |

> 📝 La documentación detallada de cada endpoint (métodos, parámetros y ejemplos en JSON) se está preparando aparte.

### Filtros útiles de `GET /api/content`

| Parámetro | Ejemplo | Efecto |
| :--- | :--- | :--- |
| `sort` | `sort=views` | Ordena por más vistos |
| `limit`, `page` | `limit=20&page=1` | Paginación |
| `type` | `type=documentary` | `movie`, `series` o `documentary` |
| `genre` | `genre=Noticias` | Filtra por categoría |
| `search` | `search=liga` | Búsqueda por título |
| `showInLive` | `showInLive=true` | Solo videos marcados para la pestaña En vivo |

---

# 📡 Tiempo real (Socket.IO)

**Espectadores del en vivo** (namespace por defecto)

| Dirección | Evento | Datos |
| :--- | :--- | :--- |
| Cliente → servidor | `join_live` | `{ liveId, user }` |
| Cliente → servidor | `leave_live` | `{ liveId }` |
| Servidor → cliente | `viewer_count` | número de espectadores |
| Servidor → cliente | `viewers_update` | lista de espectadores (id, nombre, avatar) |

**Comentarios en vivo** (namespace `/comments`, autenticado con el token en `handshake.auth.token`)

| Dirección | Evento | Datos |
| :--- | :--- | :--- |
| Cliente → servidor | `comments_join` | `{ roomId }` |
| Cliente → servidor | `comment_send` | `{ roomId, text }` |
| Servidor → cliente | `comments_history` | últimos comentarios (máx. 4 h) |
| Servidor → cliente | `comment_new` | comentario nuevo |
| Servidor → cliente | `comment_error` | mensaje de error |

---

# 👥 Roles de usuario

| Rol | Permisos |
| :--- | :--- |
| `user` | Ver contenido, comentar en vivo, guardar en Mi Lista, usar el asistente y ver los documentos de publicidad |
| `editor` | Gestionar contenido (agregar, editar y ocultar videos) |
| `admin` | Todo lo anterior, panel de administración, subir y eliminar documentos de publicidad y gestionar usuarios |

Los usuarios también tienen un plan de suscripción (`free`, `premium`, `pro`) que permite marcar contenido como premium.

---

# 🗺️ Funcionalidades planeadas

Estas funciones hacen parte del alcance original del proyecto y pueden ampliarse:

- 💳 Pagos por tiempo de uso mediante recargas, con métodos simples como códigos QR.
- 🤖 Recomendación de contenido según los gustos del usuario y resumen automático de noticias.
- 💬 Subtítulos en vivo para que todos puedan entender el contenido.
- ♿ Mejoras de accesibilidad para personas con discapacidad.
- 🔐 Cuidado y protección de datos personales cumpliendo con la ley.

---

# 🗓️ Cronograma

| Etapa | Fecha |
| :--- | :--- |
| Inicio del proyecto | 10 de agosto |
| Entrega del backend | 11 de septiembre |
| Desarrollo del frontend | septiembre – octubre |
| **Entrega final** (presentación, repositorio y video demo funcional) | **16 de octubre** |

---

# 👥 Autores

Aprendices SENA:

- Carlos Stiven Leon Huelgos
- Juan David Angarita Rojas
- Jhohan Stiven Gomez Criollo

# 🎓 Formación

Servicio Nacional de Aprendizaje — SENA

Proyecto desarrollado como parte del proceso de formación de los aprendices.

# 📌 Estado del Proyecto

🚧 **En desarrollo**, en la recta final antes de la entrega del 16 de octubre.

# 📄 Licencia

Este proyecto fue desarrollado con fines educativos como parte del proceso de formación del SENA.
