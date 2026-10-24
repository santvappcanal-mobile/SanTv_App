import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/gallery_item.dart';

/// Número de WhatsApp del canal (indicativo de país, sin "+" ni espacios).
const String kPortfolioWhatsAppPhone = '573103368882';

const Color _neon = Color(0xFF39FF14);

/// Abre la tarjeta de detalle de un servicio del portafolio.
/// [onVerImagen] se llama si el usuario quiere ver la foto completa.
Future<void> showPortfolioServiceSheet(
  BuildContext context, {
  required GalleryItem item,
  required VoidCallback onVerImagen,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => PortfolioServiceSheet(
      item: item,
      onVerImagen: () {
        Navigator.pop(sheetContext);
        onVerImagen();
      },
    ),
  );
}

class PortfolioServiceSheet extends StatelessWidget {
  const PortfolioServiceSheet({
    super.key,
    required this.item,
    required this.onVerImagen,
  });

  final GalleryItem item;
  final VoidCallback onVerImagen;

  String get _titulo => item.description.trim().isEmpty
      ? 'Servicio del portafolio'
      : item.description.trim();

  Future<void> _abrirWhatsApp(BuildContext context) async {
    final mensaje =
        'Hola, me interesa el servicio "$_titulo" del portafolio de SAN TV. '
        '¿Me pueden dar más información?';
    final uri = Uri.parse(
      'https://wa.me/$kPortfolioWhatsAppPhone?text=${Uri.encodeComponent(mensaje)}',
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
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: _neon.withValues(alpha: 0.5), width: 1.2),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: item.mediaUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _neon,
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: InkResponse(
                          onTap: onVerImagen,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.zoom_out_map_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Ver foto',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _neon.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PORTAFOLIO SAN TV',
                      style: TextStyle(
                        color: _neon,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '¿Te interesa este servicio para tu marca o tu evento? '
                    'Escríbenos y te contamos cómo podemos ayudarte.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                22,
                20,
                20 + MediaQuery.of(context).padding.bottom,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _abrirWhatsApp(context),
                  icon: const Icon(Icons.chat_rounded, size: 20),
                  label: const Text(
                    'Contactar por WhatsApp',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _neon,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}