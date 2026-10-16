import 'package:flutter/material.dart';
import 'ad_admin_card.dart';

class AdminAdsList extends StatelessWidget {
  const AdminAdsList({
    super.key,
    required this.loading,
    required this.error,
    required this.ads,
    required this.onRefresh,
    required this.onToggle,
    required this.onDelete,
    this.accentColor = const Color(0xFF39FF14),
  });

  final bool loading;
  final String? error;
  final List<Map<String, dynamic>> ads;
  final Future<void> Function() onRefresh;
  final void Function(Map<String, dynamic> ad, bool active) onToggle;
  final ValueChanged<Map<String, dynamic>> onDelete;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }
    if (error != null) return _message(error!, Colors.white70);
    if (ads.isEmpty) {
      return _message(
        'Aún no hay anuncios.\nToca "Subir imagen" para crear uno.',
        Colors.white54,
      );
    }
    return RefreshIndicator(
      color: accentColor,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        itemCount: ads.length,
        itemBuilder: (_, i) => AdAdminCard(
          ad: ads[i],
          accentColor: accentColor,
          onToggle: (v) => onToggle(ads[i], v),
          onDelete: () => onDelete(ads[i]),
        ),
      ),
    );
  }

  Widget _message(String text, Color color) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: color),
      ),
    );
  }
}