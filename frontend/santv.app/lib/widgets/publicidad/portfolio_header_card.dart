import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tarjeta de presentación del portafolio empresarial de SAN TV.
/// Tiene un botón que abre un chat de WhatsApp con un mensaje ya escrito.
class PortfolioHeaderCard extends StatelessWidget {
  const PortfolioHeaderCard({
    super.key,
    this.phone = '573103368882',
    this.message =
        'Hola, vi el portafolio de SAN TV en la app y quiero más información.',
  });

  /// Número con indicativo de país, sin "+" ni espacios.
  final String phone;

  /// Mensaje que aparece escrito al abrir el chat.
  final String message;

  static const Color neonGreen = Color(0xFF39FF14);

  static const List<String> _servicios = [
    'Noticieros en vivo',
    'Pantalla verde',
    'Cubrimiento de eventos',
    'Fotografía profesional',
  ];

  Future<void> _abrirWhatsApp(BuildContext context) async {
    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    var abrio = false;
    try {
      abrio = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      abrio = false;
    }

    if (!abrio && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir WhatsApp. Intenta de nuevo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: neonGreen.withValues(alpha: 0.35)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            neonGreen.withValues(alpha: 0.16),
            const Color(0xFF141414),
            const Color(0xFF0F0F0F),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: neonGreen.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: neonGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  color: neonGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Portafolio empresarial',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Conoce lo que hacemos en SAN TV: producción audiovisual, '
            'noticieros y cubrimientos pensados para que tu marca llegue '
            'a más personas.',
            style: TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.4),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _servicios)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    s,
                    style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _abrirWhatsApp(context),
              icon: const Icon(Icons.chat_rounded, size: 20),
              label: const Text(
                'Escríbenos por WhatsApp',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: neonGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}