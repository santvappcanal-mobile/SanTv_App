import 'dart:ui';
import 'package:flutter/material.dart';

/// Sección clicable de "Publicidad", pensada para insertarse dentro
/// del body de Home y Explorar. Versión animada:
/// - El glow/borde "respira" (pulso suave, en loop).
/// - El ícono flota levemente arriba/abajo.
/// - Un brillo diagonal (shimmer) recorre el fondo de la tarjeta.
/// - El badge "NUEVO" escala levemente para llamar la atención.
///
/// Acepta [imageUrl] opcional para mostrar una imagen en el círculo
/// del ícono en vez del ícono de altavoz por defecto.
class PublicidadSection extends StatefulWidget {
  const PublicidadSection({super.key, required this.onTap, this.imageUrl});

  final VoidCallback onTap;
  final String? imageUrl;

  @override
  State<PublicidadSection> createState() => _PublicidadSectionState();
}

class _PublicidadSectionState extends State<PublicidadSection>
    with TickerProviderStateMixin {
  // Pulso del glow/borde (loop continuo, ida y vuelta)
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  // Flotación del ícono (ida y vuelta)
  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  // Shimmer diagonal (barrido continuo, un solo sentido)
  late final AnimationController _shimmerController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseController,
        _floatController,
        _shimmerController,
      ]),
      builder: (context, _) {
        final pulse = _pulseController.value; // 0..1
        final floatOffset = (_floatController.value - 0.5) * 6; // -3..3 px
        final shimmerX = _shimmerController.value; // 0..1

        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        neonColor.withOpacity(0.45 + pulse * 0.15),
                        neonColor.withOpacity(0.14 + pulse * 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: neonColor.withOpacity(0.4 + pulse * 0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: neonColor.withOpacity(0.25 + pulse * 0.3),
                        blurRadius: 18 + pulse * 14,
                        spreadRadius: -4 + pulse * 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shimmer diagonal de fondo
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: _ShimmerSweep(progress: shimmerX),
                        ),
                      ),
                      // Contenido real
                      Row(
                        children: [
                          Transform.translate(
                            offset: Offset(0, floatOffset),
                            child: _buildIconOrImage(neonColor),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Publicidad',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Transform.scale(
                                      scale: 0.95 + pulse * 0.1,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.35),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'NUEVO',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Gestioná y mirá el contenido publicitario',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Círculo de la izquierda: muestra [imageUrl] si viene informada,
  /// con el ícono de altavoz como placeholder mientras carga y como
  /// respaldo si la imagen no puede descargarse.
  Widget _buildIconOrImage(Color neonColor) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: neonColor.withOpacity(0.6),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: widget.imageUrl == null || widget.imageUrl!.isEmpty
            ? Icon(Icons.campaign_rounded, color: neonColor, size: 26)
            : Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: neonColor,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.campaign_rounded,
                    color: neonColor,
                    size: 26,
                  );
                },
              ),
      ),
    );
  }
}

/// Barrido de brillo diagonal que recorre el fondo de la tarjeta
/// en loop, dando el efecto "shimmer" tipo skeleton-loading pero
/// más sutil y decorativo.
class _ShimmerSweep extends StatelessWidget {
  const _ShimmerSweep({required this.progress});

  /// 0.0 a 1.0, controla la posición del barrido.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ShimmerPainter(progress));
  }
}

class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final bandWidth = size.width * 0.5;
    // Recorre desde bien a la izquierda hasta bien a la derecha
    final dx = -bandWidth + progress * (size.width + bandWidth * 2);

    final rect = Rect.fromLTWH(dx, 0, bandWidth, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.10),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(rect)
      ..blendMode = BlendMode.plus;

    canvas.save();
    canvas.transform(
      (Matrix4.identity()..rotateZ(-0.35)).storage,
    );
    canvas.drawRect(rect.inflate(40), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}