import 'dart:ui';
import 'package:flutter/material.dart';

/// Contenedor con efecto "glass" (vidrio esmerilado).
///
/// Centraliza el patrón ClipRRect + BackdropFilter + gradiente + borde
/// que antes se repetía manualmente en el banner, las tarjetas de video
/// y la barra de navegación de home.dart. Ahora esas 3 piezas solo
/// configuran los parámetros que cambian entre ellas.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blurSigma = 16,
    this.gradientColors,
    this.color,
    this.border,
    this.boxShadow,
    this.width,
    this.height,
    this.padding,
  });

  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final List<Color>? gradientColors;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            // BoxDecoration no permite color y gradient a la vez: si pasas
            // "color" (fondo sólido), se ignora gradientColors.
            color: color,
            gradient: color == null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors ??
                        [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.03),
                        ],
                  )
                : null,
            border: border ?? Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: boxShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}