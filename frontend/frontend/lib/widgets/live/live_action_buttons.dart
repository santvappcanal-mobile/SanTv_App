import 'dart:ui';
import 'package:flutter/material.dart';

/// Fila de acciones del live: "Unirse Ahora", "Mi Lista" e info.
class LiveActionButtons extends StatelessWidget {
  const LiveActionButtons({
    super.key,
    required this.onJoin,
    required this.onAddToList,
    required this.onInfo,
  });

  final VoidCallback onJoin;
  final VoidCallback onAddToList;
  final VoidCallback onInfo;

  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _JoinButton(neonGreen: _neonGreen, onTap: onJoin)),
        const SizedBox(width: 10),
        _MyListButton(onTap: onAddToList),
        const SizedBox(width: 10),
        _InfoButton(onTap: onInfo),
      ],
    );
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({required this.neonGreen, required this.onTap});
  final Color neonGreen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [neonGreen.withOpacity(0.85), neonGreen.withOpacity(0.55)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: neonGreen.withOpacity(0.3),
                blurRadius: 16,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, color: Colors.black),
                    SizedBox(width: 6),
                    Text(
                      'Unirse Ahora',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MyListButton extends StatelessWidget {
  const _MyListButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Mi Lista', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.info_outline, color: Colors.white),
          ),
        ),
      ),
    );
  }
}