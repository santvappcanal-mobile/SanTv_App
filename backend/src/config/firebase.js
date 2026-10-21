const fs = require('fs');
const path = require('path');
// API modular de firebase-admin (funciona en todas las versiones recientes)
const { initializeApp, cert, getApps } = require('firebase-admin/app');
const { getMessaging: getFirebaseMessaging } = require('firebase-admin/messaging');

let initialized = false;
let enabled = false;

// Lee las credenciales de la cuenta de servicio de Firebase.
// Opciones (en este orden de prioridad), todas en el .env:
//   FIREBASE_SERVICE_ACCOUNT_PATH   -> ruta al JSON descargado (ideal en local)
//   FIREBASE_SERVICE_ACCOUNT_BASE64 -> el JSON codificado en base64 (ideal en hosting)
//   FIREBASE_SERVICE_ACCOUNT_JSON   -> el JSON en una sola línea
function loadCredentials() {
  const {
    FIREBASE_SERVICE_ACCOUNT_PATH,
    FIREBASE_SERVICE_ACCOUNT_BASE64,
    FIREBASE_SERVICE_ACCOUNT_JSON,
  } = process.env;

  let raw = null;

  if (FIREBASE_SERVICE_ACCOUNT_PATH) {
    const file = path.resolve(FIREBASE_SERVICE_ACCOUNT_PATH);
    if (!fs.existsSync(file)) {
      throw new Error(`No existe el archivo ${file}`);
    }
    raw = fs.readFileSync(file, 'utf8');
  } else if (FIREBASE_SERVICE_ACCOUNT_BASE64) {
    raw = Buffer.from(FIREBASE_SERVICE_ACCOUNT_BASE64, 'base64').toString('utf8');
  } else if (FIREBASE_SERVICE_ACCOUNT_JSON) {
    raw = FIREBASE_SERVICE_ACCOUNT_JSON;
  }

  if (!raw) return null;

  const credentials = JSON.parse(raw);
  // Algunos hosts convierten los saltos de línea de la llave en "\\n" literales.
  if (credentials.private_key) {
    credentials.private_key = credentials.private_key.replace(/\\n/g, '\n');
  }
  return credentials;
}

// Inicializa Firebase Admin una sola vez. Si no hay credenciales NO rompe el
// servidor: simplemente las notificaciones push quedan desactivadas.
function initFirebase() {
  if (initialized) return enabled;
  initialized = true;

  try {
    const credentials = loadCredentials();
    if (!credentials) {
      console.warn('⚠️  Firebase sin configurar: las notificaciones push están desactivadas.');
      return false;
    }

    if (getApps().length === 0) {
      initializeApp({ credential: cert(credentials) });
    }
    enabled = true;
    console.log(`🔔 Firebase listo (proyecto: ${credentials.project_id})`);
  } catch (error) {
    enabled = false;
    console.error('❌ No se pudo iniciar Firebase:', error.message);
  }
  return enabled;
}

// Devuelve el servicio de mensajería, o null si Firebase no está disponible.
function getMessaging() {
  if (!initialized) initFirebase();
  return enabled ? getFirebaseMessaging() : null;
}

module.exports = { initFirebase, getMessaging };