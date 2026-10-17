import 'package:flutter/material.dart';
import '../models/ad_order.dart';
import '../services/ad_order_service.dart';
import '../services/auth_service.dart';
import '../widgets/pauta/ad_order_card.dart';
import '../widgets/pauta/order_dialogs.dart';
import '../widgets/pauta/order_filter_chips.dart';
import 'ad_order_payment_screen.dart';
import 'receipt_viewer_page.dart';

/// Historial de pautas. El usuario ve las suyas; el admin ve todas
/// y puede validar o invalidar los pagos.
class AdOrdersScreen extends StatefulWidget {
  const AdOrdersScreen({
    super.key,
    required this.authService,
    required this.esAdmin,
  });

  final AuthService authService;
  final bool esAdmin;

  @override
  State<AdOrdersScreen> createState() => _AdOrdersScreenState();
}

class _AdOrdersScreenState extends State<AdOrdersScreen> {
  static const Color neonGreen = Color(0xFF39FF14);

  late final _service = AdOrderService(authService: widget.authService);
  List<AdOrder> _orders = [];
  bool _cargando = true;
  String? _error;
  String _filtro = 'todos';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  List<AdOrder> get _visibles => _filtro == 'todos'
      ? _orders
      : _orders.where((o) => o.status == _filtro).toList();

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = widget.esAdmin
          ? await _service.todas()
          : await _service.misSolicitudes();
      if (!mounted) return;
      setState(() {
        _orders = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar las solicitudes';
        _cargando = false;
      });
    }
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void _verComprobante(AdOrder o) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptViewerPage(url: o.receiptUrl, titulo: o.planName),
      ),
    );
  }

  Future<void> _subirComprobante(AdOrder o) async {
    final enviado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdOrderPaymentScreen(
          authService: widget.authService,
          order: o,
        ),
      ),
    );
    if (enviado == true) _cargar();
  }

  Future<void> _validar(AdOrder o) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Validar pago',
      message: 'Confirmas que recibiste el pago de ${o.company}? '
          'Se le notificará al cliente.',
      confirmLabel: 'Validar',
    );
    if (!ok || !mounted) return;
    final error = await _service.validar(o.id);
    if (!mounted) return;
    _aviso(error ?? 'Pago validado y cliente notificado');
    if (error == null) _cargar();
  }

  Future<void> _invalidar(AdOrder o) async {
    final motivo = await showInvalidateDialog(context);
    if (motivo == null || !mounted) return;
    final error = await _service.invalidar(o.id, motivo);
    if (!mounted) return;
    _aviso(error ?? 'Pago invalidado, solicitud cancelada');
    if (error == null) _cargar();
  }

  Widget _cuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: neonGreen));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _cargar,
              child: const Text('Reintentar', style: TextStyle(color: neonGreen)),
            ),
          ],
        ),
      );
    }

    final lista = _visibles;
    return RefreshIndicator(
      onRefresh: _cargar,
      color: neonGreen,
      child: lista.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Text(
                    widget.esAdmin
                        ? 'No hay solicitudes en esta vista'
                        : 'Aún no tienes pautas solicitadas',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: lista.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final o = lista[i];
                return AdOrderCard(
                  order: o,
                  esAdmin: widget.esAdmin,
                  onViewReceipt: () => _verComprobante(o),
                  onUploadReceipt: () => _subirComprobante(o),
                  onValidate: () => _validar(o),
                  onInvalidate: () => _invalidar(o),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.esAdmin ? 'Solicitudes de pauta' : 'Mis pautas',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          OrderFilterChips(
            selected: _filtro,
            onSelected: (f) => setState(() => _filtro = f),
          ),
          const SizedBox(height: 4),
          Expanded(child: _cuerpo()),
        ],
      ),
    );
  }
}
