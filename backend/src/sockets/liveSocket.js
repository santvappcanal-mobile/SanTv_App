/**
 * Maneja el conteo de espectadores en tiempo real por transmisión
 * (liveId), estilo Facebook Live. Todo se guarda en memoria (Map),
 * no en MongoDB, porque es estado efímero de la conexión.
 *
 * Contrato de eventos (debe coincidir con LiveViewerService en Flutter):
 *   Cliente -> Servidor: 'join_live' { liveId, user }
 *   Cliente -> Servidor: 'leave_live' { liveId }
 *   Servidor -> Cliente: 'viewer_count' (int)
 *   Servidor -> Cliente: 'viewers_update' (array de viewers)
 */

// liveId -> Map<socketId, { id, name, avatarUrl, joinedAt }>
const liveRooms = new Map();

function getViewersArray(liveId) {
  const room = liveRooms.get(liveId);
  if (!room) return [];
  return Array.from(room.values());
}

function broadcastRoomState(io, liveId) {
  const viewers = getViewersArray(liveId);
  io.to(liveId).emit('viewer_count', viewers.length);
  io.to(liveId).emit('viewers_update', viewers);
}

function removeSocketFromAllRooms(io, socket) {
  for (const [liveId, room] of liveRooms.entries()) {
    if (room.has(socket.id)) {
      room.delete(socket.id);
      socket.leave(liveId);
      broadcastRoomState(io, liveId);
      if (room.size === 0) liveRooms.delete(liveId);
    }
  }
}

function initLiveSocket(io) {
  io.on('connection', (socket) => {
    socket.on('join_live', ({ liveId, user }) => {
      if (!liveId) return;

      socket.join(liveId);

      if (!liveRooms.has(liveId)) liveRooms.set(liveId, new Map());
      liveRooms.get(liveId).set(socket.id, {
        id: user?.id || socket.id,
        name: user?.name || 'Usuario',
        avatarUrl: user?.avatarUrl || null,
        joinedAt: new Date().toISOString(),
      });

      broadcastRoomState(io, liveId);
    });

    socket.on('leave_live', ({ liveId }) => {
      const room = liveRooms.get(liveId);
      if (room?.has(socket.id)) {
        room.delete(socket.id);
        socket.leave(liveId);
        broadcastRoomState(io, liveId);
        if (room.size === 0) liveRooms.delete(liveId);
      }
    });

    socket.on('disconnect', () => {
      removeSocketFromAllRooms(io, socket);
    });
  });
}

module.exports = { initLiveSocket };