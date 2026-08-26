import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final neonColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      // Antes: AppBar propio con Text('SAN TV', ...). Ahora se reutiliza
      // TopBar, que ya muestra el logo en vez del texto.
      appBar: const TopBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(neonColor),
          const Center(child: Text('Explorar Contenido', style: TextStyle(color: Colors.white))),
          const Center(child: Text('Transmisiones en Vivo', style: TextStyle(color: Colors.white))),
          const Center(child: Text('Mi Perfil', style: TextStyle(color: Colors.white))),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.black,
        selectedItemColor: neonColor,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'En Vivo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildHomeTab(Color neonColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de transmisión en vivo principal
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [neonColor.withValues(alpha: 0.3), Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: neonColor.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_fill, size: 60, color: neonColor),
                  const SizedBox(height: 10),
                  const Text(
                    'Canal en vivo',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Videos destacados',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Center(
                    child: Text(
                      'Agregar Video',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}