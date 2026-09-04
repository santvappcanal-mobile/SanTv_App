import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';

class AssistantChatSheet extends StatefulWidget {
  const AssistantChatSheet({super.key, required this.authService});

  final AuthService authService;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  State<AssistantChatSheet> createState() => _AssistantChatSheetState();
}

class _AssistantChatSheetState extends State<AssistantChatSheet> {
  late final ChatService _chatService =
      ChatService(authService: widget.authService);

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _mensajes = [
    {
      'role': 'bot',
      'text':
          '¡Hola! 👋 Soy el asistente virtual de SAN TV. Pregúntame sobre noticias, deportes, videos, publicidad o los servicios del canal.',
    }
  ];
  bool _cargando = false;

  void _enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _cargando) return;

    _controller.clear();
    setState(() {
      _mensajes.add({'role': 'user', 'text': texto});
      _cargando = true;
    });

    _scrollHaciaAbajo();

    final respuesta = await _chatService.enviarMensaje(texto);

    if (mounted) {
      setState(() {
        _mensajes.add({'role': 'bot', 'text': respuesta});
        _cargando = false;
      });
      _scrollHaciaAbajo();
    }
  }

  void _scrollHaciaAbajo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    const neonGreen = AssistantChatSheet.neonGreen;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      margin: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0B0B0B), Color(0xFF10241A), Color(0xFF0B0B0B)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: neonGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: neonGreen.withOpacity(0.4)),
                        ),
                        child: const Icon(Icons.smart_toy_outlined, color: neonGreen),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Asistente SAN TV',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'En línea • Respuestas al instante',
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _mensajes.length,
                    itemBuilder: (context, index) {
                      final item = _mensajes[index];
                      final esUsuario = item['role'] == 'user';
                      return _buildBubble(item['text']!, esUsuario, neonGreen);
                    },
                  ),
                ),
                if (_cargando)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: neonGreen),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'El asistente está respondiendo...',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.08),
                                    Colors.white.withOpacity(0.03),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.15)),
                              ),
                              child: TextField(
                                controller: _controller,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Pregunta por contenido, publicidad...',
                                  hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                ),
                                onSubmitted: (_) => _enviarMensaje(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _enviarMensaje,
                        style: IconButton.styleFrom(
                          backgroundColor: neonGreen,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                        ),
                        icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(String texto, bool esUsuario, Color neonGreen) {
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esUsuario ? 16 : 4),
            bottomRight: Radius.circular(esUsuario ? 4 : 16),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: esUsuario
                    ? LinearGradient(
                        colors: [neonGreen.withOpacity(0.85), neonGreen.withOpacity(0.65)],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.03),
                        ],
                      ),
                border: Border.all(
                  color: esUsuario
                      ? neonGreen.withOpacity(0.5)
                      : Colors.white.withOpacity(0.15),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(esUsuario ? 16 : 4),
                  bottomRight: Radius.circular(esUsuario ? 4 : 16),
                ),
              ),
              child: Text(
                texto,
                style: TextStyle(
                  color: esUsuario ? Colors.black : Colors.white,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}