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
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late final ChatService _chatService;

  final List<Map<String, String>> _mensajes = [
    {
      'role': 'bot',
      'text':
          '¡Hola! 👋 Soy el asistente virtual de SAN TV. Pregúntame sobre noticias, deportes, videos, publicidad o los servicios del canal.',
    }
  ];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(authService: widget.authService);
    _personalizarSaludo();
  }

  Future<void> _personalizarSaludo() async {
    final user = await widget.authService.getProfile();
    if (!mounted || user == null || user.name.isEmpty) return;
    setState(() {
      _mensajes[0] = {
        'role': 'bot',
        'text':
            '¡Hola, ${user.name}! 👋 Soy el asistente virtual de SAN TV. Pregúntame sobre noticias, deportes, videos, publicidad o los servicios del canal.',
      };
    });
  }

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
      height: MediaQuery.of(context).size.height * 0.75,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                    color: neonGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
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
          const Divider(color: Colors.white10, height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final item = _mensajes[index];
                final esUsuario = item['role'] == 'user';

                return Align(
                  alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: esUsuario ? neonGreen : const Color(0xFF1B1B1B),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(esUsuario ? 16 : 4),
                        bottomRight: Radius.circular(esUsuario ? 4 : 16),
                      ),
                    ),
                    child: Text(
                      item['text']!,
                      style: TextStyle(
                        color: esUsuario ? Colors.black : Colors.white,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: neonGreen),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'El asistente está respondiendo...',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
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
    );
  }
}