import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';

/// Muestra el QR de la cuenta que recibe pagos y permite guardarlo en la galería.
/// El QR se toma de [assetPath]: reemplaza ese archivo por el QR real.
class QrPaymentCard extends StatefulWidget {
  const QrPaymentCard({super.key, this.assetPath = 'assets/img/qr_pago.png'});

  final String assetPath;

  @override
  State<QrPaymentCard> createState() => _QrPaymentCardState();
}

class _QrPaymentCardState extends State<QrPaymentCard> {
  static const Color neonGreen = Color(0xFF39FF14);
  bool _guardando = false;

  void _aviso(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _descargar() async {
    setState(() => _guardando = true);
    try {
      final data = await rootBundle.load(widget.assetPath);
      await Gal.putImageBytes(data.buffer.asUint8List());
      _aviso('QR guardado en tu galería');
    } catch (_) {
      _aviso('No se pudo guardar el QR. Revisa los permisos de la galería');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Fondo blanco para que el QR se pueda escanear sin problema
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              widget.assetPath,
              width: 220,
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 220,
                height: 220,
                child: Center(
                  child: Text(
                    'QR no disponible',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: neonGreen,
              side: const BorderSide(color: neonGreen),
            ),
            onPressed: _guardando ? null : _descargar,
            icon: _guardando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: neonGreen,
                    ),
                  )
                : const Icon(Icons.download_rounded),
            label: const Text('Descargar QR'),
          ),
        ],
      ),
    );
  }
}
