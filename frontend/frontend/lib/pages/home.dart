// Archivo: lib/pages/home.dart
import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../services/live_viewer_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final LiveViewerService _viewerService = LiveViewerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: const TopBar(),
      body: Stack(
        children: [
          // Imagen de fondo con gradiente para oscurecer
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.black, Colors.black],
                  stops: [0.0, 0.6, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.darken,
              child: Image.asset(
                'assets/img/IMG-20260730-WA0007.jpg', // Asegúrate de tener esta imagen
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade900),
              ),
            ),
          ),
          
          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Etiqueta de Transmisión en Vivo (Tiempo Real)
                  StreamBuilder<int>(
                    stream: _viewerService.liveViewerStream,
                    builder: (context, snapshot) {
                      final viewers = snapshot.data ?? 15234;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF39FF14).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.circle, color: Colors.black, size: 12),
                            const SizedBox(width: 8),
                            Text(
                              'TRANSMISIÓN EN VIVO - ${viewers.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} espectadores',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 16),
                  
                  // Título
                  const Text(
                    'Transmisión EN\nVIVO: Noticias\nSan TV',
                    style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.1),
                  ),
                  const SizedBox(height: 12),
                  
                  // Fila de información
                  StreamBuilder<int>(
                    stream: _viewerService.liveViewerStream,
                    builder: (context, snapshot) {
                      final viewers = snapshot.data ?? 15234;
                      return Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          const Text('9.1  2026  ', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                          Text('${viewers.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} viendo  ', style: const TextStyle(color: Colors.white70)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.greenAccent),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('HD', style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                          )
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 16),
                  
                  // Descripción
                  const Text(
                    'Cobertura en directo de las noticias más importantes del día. Conectamos con reporteros en todo el país.',
                    style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF39FF14),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Unirse\nAhora', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text('Mi\nLista', textAlign: TextAlign.center),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade800,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.info_outline, color: Colors.white),
                          onPressed: () {},
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Sección En Vivo Ahora
                  Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      const Text('EN VIVO AHORA', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Lista horizontal de videos
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 220,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: AssetImage('assets/img/IMG-20260730-WA0007.jpg'), // Usa tu imagen aquí
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF39FF14),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.circle, color: Colors.black, size: 8),
                                      SizedBox(width: 4),
                                      Text('EN VIVO', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20), // Espacio extra al fondo
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.movie_creation_outlined), label: 'Videos'),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'En Vivo'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Mi Lista'),
        ],
      ),
    );
  }
}