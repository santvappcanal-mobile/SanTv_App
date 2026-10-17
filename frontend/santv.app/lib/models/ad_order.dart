/// Solicitud de pauta publicitaria con su pago.
class AdOrder {
  AdOrder({
    required this.id,
    required this.company,
    required this.contactName,
    required this.contactPhone,
    required this.planName,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.receiptUrl,
    required this.cancelReason,
    required this.userName,
    required this.createdAt,
  });

  final String id;
  final String company;
  final String contactName;
  final String contactPhone;
  final String planName;
  final double amount;
  final String paymentMethod; // transferencia | efectivo
  final String status; // pendiente | validado | cancelado
  final String receiptUrl;
  final String cancelReason;
  final String userName; // solo viene en la lista del admin
  final DateTime? createdAt;

  factory AdOrder.fromJson(Map<String, dynamic> j) {
    final user = j['user'];
    return AdOrder(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      company: (j['company'] ?? '').toString(),
      contactName: (j['contactName'] ?? '').toString(),
      contactPhone: (j['contactPhone'] ?? '').toString(),
      planName: (j['planName'] ?? '').toString(),
      amount: (j['amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: (j['paymentMethod'] ?? 'transferencia').toString(),
      status: (j['status'] ?? 'pendiente').toString(),
      receiptUrl: (j['receiptUrl'] ?? '').toString(),
      cancelReason: (j['cancelReason'] ?? '').toString(),
      userName: user is Map ? (user['name'] ?? '').toString() : '',
      createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString())?.toLocal(),
    );
  }

  bool get isTransfer => paymentMethod == 'transferencia';
  bool get isPending => status == 'pendiente';
  bool get isValidated => status == 'validado';
  bool get isCancelled => status == 'cancelado';
  bool get hasReceipt => receiptUrl.isNotEmpty;

  /// Transferencia pendiente a la que todavía le falta la captura.
  bool get needsReceipt => isTransfer && isPending && !hasReceipt;

  String get statusLabel {
    if (isValidated) return 'Pago validado';
    if (isCancelled) return 'Cancelada';
    if (!isTransfer) return 'Efectivo pendiente';
    return hasReceipt ? 'En revisión' : 'Falta comprobante';
  }
}
