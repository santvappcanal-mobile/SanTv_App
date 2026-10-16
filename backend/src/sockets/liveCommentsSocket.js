const jwt = require('jsonwebtoken');
const User = require('../models/User');
const LiveComment = require('../models/LiveComment');

const HISTORY_LIMIT = 100;
const MAX_TEXT = 300;
const MIN_INTERVAL_MS = 1000; // anti-spam: 1 comentario por segundo por conexión

const roomName = (roomId) => `comments:${roomId}`;

const toClient = (c) => ({
  id: c._id.toString(),
  userId: c.user.toString(),
  userName: c.userName,
  avatarUrl: c.userAvatar || '',
  text: c.text,
  createdAt: c.createdAt,
});

/**
 * Comentarios en vivo por Socket.IO en el namespace /comments
 * (separado del socket del contador de espectadores, no lo afecta).
 *
 * Cliente -> servidor:
 *   comments_join { roomId }        entra a la sala y recibe el historial
 *   comment_send  { roomId, text }  publica un comentario
 * Servidor -> cliente:
 *   comments_history [ ... ]        últimos comentarios (máx. 4 h de antigüedad)
 *   comment_new { ... }             comentario nuevo en tiempo real
 *   comment_error "mensaje"
 */
function initLiveComments(io) {
  const nsp = io.of('/comments');

  // Autenticación con el mismo JWT de la app (handshake.auth.token)
  nsp.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth && socket.handshake.auth.token;
      if (!token) return next(new Error('No autorizado'));

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const userId = decoded.id || decoded._id || decoded.userId;

      const user = await User.findById(userId).select('name avatar isActive');
      if (!user || user.isActive === false) {
        return next(new Error('No autorizado'));
      }

      socket.data.user = user;
      next();
    } catch (err) {
      next(new Error('No autorizado'));
    }
  });

  nsp.on('connection', (socket) => {
    let lastSentAt = 0;

    socket.on('comments_join', async ({ roomId } = {}) => {
      if (!roomId || typeof roomId !== 'string') return;
      socket.join(roomName(roomId));

      try {
        const items = await LiveComment.find({ roomId })
          .sort({ createdAt: -1 })
          .limit(HISTORY_LIMIT)
          .lean();
        socket.emit('comments_history', items.reverse().map(toClient));
      } catch (err) {
        console.error('Error cargando comentarios:', err.message);
      }
    });

    socket.on('comment_send', async ({ roomId, text } = {}) => {
      try {
        if (!roomId || typeof roomId !== 'string') return;

        const clean = String(text || '').trim().slice(0, MAX_TEXT);
        if (!clean) return;

        const now = Date.now();
        if (now - lastSentAt < MIN_INTERVAL_MS) {
          socket.emit('comment_error', 'Vas muy rápido, espera un segundo');
          return;
        }
        lastSentAt = now;

        const user = socket.data.user;
        const comment = await LiveComment.create({
          roomId,
          user: user._id,
          userName: user.name,
          userAvatar: user.avatar || '',
          text: clean,
        });

        nsp.to(roomName(roomId)).emit('comment_new', toClient(comment));
      } catch (err) {
        console.error('Error guardando comentario:', err.message);
        socket.emit('comment_error', 'No se pudo enviar el comentario');
      }
    });
  });
}

module.exports = { initLiveComments };