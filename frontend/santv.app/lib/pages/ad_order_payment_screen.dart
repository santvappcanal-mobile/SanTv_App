import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/ad_order.dart';
import '../models/ad_plan.dart';
import '../services/ad_order_service.dart';
import '../services/auth_service.dart';
import '../widgets/pauta/qr_payment_card.dart';
import '../widgets/pauta/receipt_picker.dart';

/// Pago por transferencia: QR descargable + subida de la captura del pago.
class AdOrderPaymentScreen extends StatefulWidget {
  const AdOrderPaymentScreen({
    super.key,
    required this.authService,
    required this.order,
  });

  final AuthService authService;
  final AdOrder order;

  @override
  State<AdOrderPaymentScreen> createState() => _AdOrderPaymentScreenState();
}

class _AdOrderPaymentScreenState extends State<AdOrderPaymentScreen> {
  static const Color neonGreen = Color(0xFF39FF14);

  late final _service = AdOrderService(authService: widget.authService);
  File? _comprobante;
  bool _enviando = false;
  String? _error;

  Future<void> _elegirImagen() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _comprobante = File(picked.path);
      _error = null;
    });
  }

  Future<void> _enviar() async {
    if (_comprobante == null) {
      setState(() => _error = 'Selecciona la captura de tu pago');
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    final error = await _service.subirComprobante(
      widget.order.id,
      _comprobante!,
    );
    if (!mounted) return;
    setState(() => _enviando = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Comprobante enviado. Te avisaremos cuando sea validado.',
          ),
        ),
      );
      Navigator.pop(context, true);
    } else {
      setState(() => _error = error);
    }
  }

  Widget _paso(String numero, String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: neonGreen,
              child: Text(
                numero,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                texto,
                style: const TextStyle(color: Colors.white70, height: 1.3),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Pago por transferencia',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    order.planName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  formatCop(order.amount),
                  style: const TextStyle(
                    color: neonGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const QrPaymentCard(),
          const SizedBox(height: 16),
          _paso('1', 'Descarga el QR y escanéalo desde tu app bancaria.'),
          _paso('2', 'Realiza el pago por el valor del plan.'),
          _paso('3', 'Toma una captura de pantalla del pago y súbela aquí.'),
          const SizedBox(height: 12),
          ReceiptPicker(file: _comprobante, onPick: _elegirImagen),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: neonGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _enviando ? null : _enviar,
              child: _enviando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'Enviar comprobante',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          TextButton(
            onPressed: _enviando ? null : () => Navigator.pop(context),
            child: const Text(
              'Subirlo más tarde',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }
}
