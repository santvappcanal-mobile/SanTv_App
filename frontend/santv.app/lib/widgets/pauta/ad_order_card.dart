import 'package:flutter/material.dart';
import '../../models/ad_order.dart';
import '../../models/ad_plan.dart';
import 'order_status_chip.dart';

/// Tarjeta de una solicitud en el historial (vista usuario y vista admin).
class AdOrderCard extends StatelessWidget {
  const AdOrderCard({
    super.key,
    required this.order,
    required this.esAdmin,
    this.onViewReceipt,
    this.onUploadReceipt,
    this.onValidate,
    this.onInvalidate,
    this.onDelete,
  });

  final AdOrder order;
  final bool esAdmin;
  final VoidCallback? onViewReceipt;
  final VoidCallback? onUploadReceipt;
  final VoidCallback? onValidate;
  final VoidCallback? onInvalidate;

  /// Solo admin: elimina la solicitud del listado.
  final VoidCallback? onDelete;

  static const Color neonGreen = Color(0xFF39FF14);

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _linea(IconData icon, String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white38),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                texto,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      );

  List<Widget> _acciones() {
    final acciones = <Widget>[];

    // Comprobante: el usuario lo ve al validarse; el admin siempre para revisarlo
    if (order.hasReceipt && (order.isValidated || esAdmin)) {
      acciones.add(
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: neonGreen,
            side: const BorderSide(color: neonGreen),
          ),
          onPressed: onViewReceipt,
          icon: const Icon(Icons.receipt_long_outlined, size: 18),
          label: const Text('Ver comprobante'),
        ),
      );
    }

    if (!esAdmin && order.needsReceipt) {
      acciones.add(
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
          onPressed: onUploadReceipt,
          icon: const Icon(Icons.upload, size: 18, color: Colors.black),
          label: const Text(
            'Subir comprobante',
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }

    if (esAdmin && order.isPending) {
      final puedeValidar = !order.isTransfer || order.hasReceipt;
      acciones.addAll([
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: neonGreen),
          onPressed: puedeValidar ? onValidate : null,
          icon: const Icon(Icons.check, size: 18, color: Colors.black),
          label: const Text('Validar', style: TextStyle(color: Colors.black)),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent),
          ),
          onPressed: onInvalidate,
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Invalidar'),
        ),
      ]);
    }
    return acciones;
  }

  @override
  Widget build(BuildContext context) {
    final acciones = _acciones();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.planName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              OrderStatusChip(order: order),
              if (esAdmin && onDelete != null)
                IconButton(
                  tooltip: 'Eliminar solicitud',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatCop(order.amount),
            style: const TextStyle(
              color: neonGreen,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          _linea(Icons.business, order.company),
          if (esAdmin) ...[
            _linea(Icons.person_outline, order.contactName),
            _linea(Icons.phone_outlined, order.contactPhone),
            if (order.userName.isNotEmpty)
              _linea(Icons.account_circle_outlined, 'Cuenta: ${order.userName}'),
          ],
          _linea(
            order.isTransfer ? Icons.qr_code_2 : Icons.payments_outlined,
            order.isTransfer ? 'Transferencia' : 'Efectivo',
          ),
          if (order.createdAt != null)
            _linea(Icons.schedule, _fecha(order.createdAt!)),
          if (!esAdmin && !order.isTransfer && order.isPending)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Acércate a las oficinas del canal para realizar el pago.',
                style: TextStyle(color: Colors.amber, fontSize: 12.5),
              ),
            ),
          if (order.isCancelled && order.cancelReason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Motivo: ${order.cancelReason}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
              ),
            ),
          if (acciones.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: acciones),
          ],
        ],
      ),
    );
  }
}