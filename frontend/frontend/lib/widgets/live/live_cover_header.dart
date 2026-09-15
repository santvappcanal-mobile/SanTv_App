import 'dart:ui';
import 'package:flutter/material.dart';

/// Encabezado del live: imagen de portada, degradado, badge
/// "TRANSMISIÓN EN VIVO" y botón de silencio, todo en vidrio.
class LiveCoverHeader extends StatelessWidget {
  const LiveCoverHeader({
    super.key,
    required this.coverImageUrl,
    required this.muted,
    required this.onToggleMute,
  });

  final String coverImageUrl;
  final bool muted;
  final VoidCallback onToggleMute;

  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          child: Image.network(
            coverImageUrl,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          height: 220,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black87],
            ),
          ),
        ),
        const Positioned(top: 12, left: 12, child: _LiveBadge(neonGreen: _neonGreen)),
        Positioned(
          right: 12,
          bottom: 12,
          child: _MuteButton(muted: muted, onTap: onToggleMute),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.neonGreen});
  final Color neonGreen;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: neonGreen.withOpacity(0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, color: Colors.red, size: 10),
              const SizedBox(width: 6),
              Text(
                'TRANSMISIÓN EN VIVO',
                style: TextStyle(
                  color: neonGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MuteButton extends StatelessWidget {
  const _MuteButton({required this.muted, required this.onTap});
  final bool muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: Icon(
              muted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}