/// Tarjeta que el asistente muestra debajo de su mensaje.
/// [tipo] puede ser: 'video' (más visto), 'referencia' o 'documento'.
class ChatAttachment {
  const ChatAttachment({
    required this.tipo,
    required this.titulo,
    this.descripcion = '',
    this.url = '',
    this.miniatura = '',
    this.contenido,
  });

  final String tipo;
  final String titulo;
  final String descripcion;
  final String url;
  final String miniatura;

  /// Solo para tipo 'video': datos completos del contenido, para abrir el
  /// mismo reproductor que usa el resto de la app.
  final Map<String, dynamic>? contenido;

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    final contenido = json['contenido'];
    return ChatAttachment(
      tipo: (json['tipo'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      miniatura: (json['miniatura'] ?? '').toString(),
      contenido: contenido is Map ? Map<String, dynamic>.from(contenido) : null,
    );
  }
}

/// Respuesta del asistente: texto + tarjetas opcionales.
class ChatReply {
  const ChatReply({required this.texto, this.adjuntos = const []});

  final String texto;
  final List<ChatAttachment> adjuntos;
}