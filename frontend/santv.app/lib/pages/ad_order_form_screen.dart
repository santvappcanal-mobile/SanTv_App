import 'package:flutter/material.dart';
import '../models/ad_plan.dart';
import '../services/ad_order_service.dart';
import '../services/auth_service.dart';
import '../widgets/pauta/order_dialogs.dart';
import '../widgets/pauta/pauta_text_field.dart';
import '../widgets/pauta/payment_method_selector.dart';
import '../widgets/pauta/plan_selector.dart';
import 'ad_order_payment_screen.dart';

/// Formulario para pautar: datos del cliente, plan y método de pago.
class AdOrderFormScreen extends StatefulWidget {
  const AdOrderFormScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<AdOrderFormScreen> createState() => _AdOrderFormScreenState();
}

class _AdOrderFormScreenState extends State<AdOrderFormScreen> {
  static const Color neonGreen = Color(0xFF39FF14);

  final _formKey = GlobalKey<FormState>();
  final _companyCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late final _service = AdOrderService(authService: widget.authService);

  AdPlan _plan = adPlans.first;
  String _method = 'transferencia';
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _companyCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String? _requerido(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;

  String? _telefono(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length < 7 ? 'Ingresa un teléfono válido' : null;
  }

  Future<void> _continuar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _guardando = true;
      _error = null;
    });

    final result = await _service.crear(
      company: _companyCtrl.text.trim(),
      contactName: _contactCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      planName: _plan.name,
      amount: _plan.price,
      paymentMethod: _method,
      notes: _notesCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _guardando = false);

    final order = result.order;
    if (order == null) {
      setState(() => _error = result.error ?? 'No se pudo crear la solicitud');
      return;
    }

    if (order.isTransfer) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdOrderPaymentScreen(
            authService: widget.authService,
            order: order,
          ),
        ),
      );
    } else {
      await showCashInfoDialog(context);
      if (mounted) Navigator.pop(context);
    }
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 6),
        child: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Quiero pautar',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _titulo('Elige tu plan'),
            PlanSelector(
              plans: adPlans,
              selected: _plan,
              onChanged: (p) => setState(() => _plan = p),
            ),
            const SizedBox(height: 10),
            _titulo('Datos de contacto'),
            PautaTextField(
              controller: _companyCtrl,
              label: 'Empresa o marca',
              validator: _requerido,
            ),
            PautaTextField(
              controller: _contactCtrl,
              label: 'Nombre de contacto',
              validator: _requerido,
            ),
            PautaTextField(
              controller: _phoneCtrl,
              label: 'Teléfono',
              keyboardType: TextInputType.phone,
              validator: _telefono,
            ),
            PautaTextField(
              controller: _notesCtrl,
              label: 'Notas (opcional)',
              maxLines: 3,
              maxLength: 500,
            ),
            _titulo('Método de pago'),
            PaymentMethodSelector(
              value: _method,
              onChanged: (m) => setState(() => _method = m),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _guardando ? null : _continuar,
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        _method == 'transferencia'
                            ? 'Continuar con el pago'
                            : 'Enviar solicitud',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
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
