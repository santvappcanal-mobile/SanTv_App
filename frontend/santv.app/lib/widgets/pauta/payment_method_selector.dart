import 'package:flutter/material.dart';

/// Selector de método de pago: transferencia o efectivo.
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value; // 'transferencia' | 'efectivo'
  final ValueChanged<String> onChanged;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _option('transferencia', 'Transferencia', Icons.qr_code_2),
        const SizedBox(width: 10),
        _option('efectivo', 'Efectivo', Icons.payments_outlined),
      ],
    );
  }

  Widget _option(String id, String label, IconData icon) {
    final selected = value == id;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? neonGreen : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? neonGreen : Colors.white54),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
