import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _loaderFade;

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  // Colorimetría verde del Home
  static const Color _bg1 = Color(0xFF0B0B0B);
  static const Color _bg2 = Color(0xFF10241A);
  static const Color _bg3 = Color(0xFF0B0B0B);
  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _loaderFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
    _redirect();
  }

  Future<void> _redirect() async {
    final results = await Future.wait([
      _storage.read(key: _tokenKey),
      Future.delayed(const Duration(milliseconds: 2400)),
    ]);

    final token = results[0] as String?;
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo base
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_bg1, _bg2, _bg3],
              ),
            ),
          ),

          // Resplandores decorativos (degradado radial, sin blur real)
          const Positioned(
            top: -100,
            left: -80,
            child: _GlowOrb(size: 320, opacity: 0.22),
          ),
          const Positioned(
            bottom: -120,
            right: -90,
            child: _GlowOrb(size: 360, opacity: 0.16),
          ),

          // Contenido
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: const _LogoImage(),
                    ),
                  ),
                  const SizedBox(height: 64),
                  FadeTransition(
                    opacity: _loaderFade,
                    child: const _GlassLoader(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Resplandor de fondo, hecho con un degradado radial (sin blur real,
/// mucho más liviano que ImageFilter.blur en dispositivos modestos).
class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF39FF14).withValues(alpha: opacity),
            const Color(0xFF39FF14).withValues(alpha: 0),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

/// Solo el logo, con un leve resplandor verde detrás para que no se
/// vea plano sobre el fondo oscuro.
class _LogoImage extends StatelessWidget {
  const _LogoImage();

  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _neonGreen.withValues(alpha: 0.18),
            blurRadius: 36,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Image.asset(
          'assets/img/original.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.live_tv_rounded, color: _neonGreen, size: 80),
        ),
      ),
    );
  }
}

/// Indicador de carga dentro de una cápsula translúcida (sin blur real).
class _GlassLoader extends StatelessWidget {
  const _GlassLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: const _PulsingBar(),
    );
  }
}

/// Barra que se desliza de un lado a otro, estilo "loading" moderno.
class _PulsingBar extends StatefulWidget {
  const _PulsingBar();

  @override
  State<_PulsingBar> createState() => _PulsingBarState();
}

class _PulsingBarState extends State<_PulsingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const Color _neonGreen = Color(0xFF39FF14);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Align(
          alignment: Alignment(-1 + 2 * t, 0),
          child: FractionallySizedBox(
            widthFactor: 0.35,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Colors.transparent, _neonGreen, Colors.transparent],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
