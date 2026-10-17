import 'package:flutter/material.dart';
import '../../models/ad_order.dart';

/// Etiqueta de color con el estado de la solicitud.
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.order});

  final AdOrder order;

  Color get _color {
    if (order.isValidated) return const Color(0xFF39FF14);
    if (order.isCancelled) return Colors.redAccent;
    return Colors.amber;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.6)),
      ),
      child: Text(
        order.statusLabel,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
