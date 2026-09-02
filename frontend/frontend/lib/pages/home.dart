import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import 'explore_screen.dart';
// Importa el archivo de tu pestaña en vivo (ajusta la ruta según tu estructura de carpetas)
import 'live_tab_screen.dart';
import 'profile_screen.dart';

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
      extendBody: true,
      // Fondo con gradiente para que el BackdropFilter tenga algo
      // que difuminar; sin esto el efecto de vidrio no se aprecia.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0B0B), Color(0xFF10241A), Color(0xFF0B0B0B)],
          ),
        ),
        child: Column(
          children: [
            const TopBar(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildHomeTab(neonColor),
                  const ExploreScreen(),
                  // Aquí integramos tu LiveTabScreen pasando el callback para cuando toquen un live
                  LiveTabScreen(
                    onOpenLive: (liveId) {
                      // Aquí manejas la navegación al detalle del live (ej: Navigator.push)
                      debugPrint('Abriendo transmisión: $liveId');
                    },
                  ),
                  // Aquí integramos ProfileScreen con los datos del usuario y sus acciones
                  ProfileScreen(
                    userName:
                        'Nombre del usuario', // TODO: trae del authService/backend
                    userEmail:
                        'correo@ejemplo.com', // TODO: trae del authService/backend
                    onEditProfile: () {
                      // TODO: navega a la pantalla de edición de perfil
                    },
                    onMyList: () {
                      // TODO: navega a "Mi Lista"
                    },
                    onSettings: () {
                      // TODO: navega a configuración
                    },
                    onHelp: () {
                      // TODO: navega a ayuda y soporte
                    },
                    onLogout: () {
                      // TODO: llama a tu authService.logout() y navega de vuelta a AuthScreen
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildGlassNavBar(neonColor),
    );
  }

  Widget _buildGlassNavBar(Color neonColor) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: neonColor,
            unselectedItemColor: Colors.white38,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Explorar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.live_tv),
                label: 'En Vivo',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(Color neonColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de transmisión en vivo principal, en vidrio.
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      neonColor.withOpacity(0.20),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                  boxShadow: [
                    BoxShadow(
                      color: neonColor.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_fill, size: 60, color: neonColor),
                      const SizedBox(height: 10),
                      const Text(
                        'Canal en vivo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Videos destacados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.03),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Agregar Video',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
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
