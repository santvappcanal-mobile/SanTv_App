import 'package:flutter/material.dart';
import 'package:santv_app/widgets/admin_dashboard/error_retry_view.dart';

const _neon = Color(0xFF39FF14);

/// Esqueleto común de las pestañas de Publicidad: spinner mientras
/// carga, mensaje con "Reintentar" si falla, y si hay datos un
/// RefreshIndicator con el botón de admin (opcional) arriba.
class PublicidadTab extends StatelessWidget {
  const PublicidadTab({
    super.key,
    required this.cargando,
    required this.error,
    required this.onReload,
    required this.isEmpty,
    required this.emptyText,
    required this.child,
    this.adminButton,
  });

  final bool cargando;
  final String? error;
  final Future<void> Function() onReload;
  final bool isEmpty;
  final String emptyText;

  /// Contenido cuando hay datos.
  final Widget child;

  /// Botón de subir/agregar (solo se pasa si el usuario es admin).
  final Widget? adminButton;

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator(color: _neon));
    }

    if (error != null) {
      return ErrorRetryView(message: error!, onRetry: onReload);
    }

    return RefreshIndicator(
      onRefresh: onReload,
      color: _neon,
      child: Column(
        children: [
          if (adminButton != null) adminButton!,
          Expanded(
            child: isEmpty
                ? ListView(
                    // ListView para que el RefreshIndicator funcione aun vacío
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Text(
                          emptyText,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  )
                : child,
          ),
        ],
      ),
    );
  }
}