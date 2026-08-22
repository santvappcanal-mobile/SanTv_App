import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/live_badge.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  String _categoriaSeleccionada = 'Todos';

  final List<String> _categorias = [
    'Todos',
    'Noticias',
    'Deportes',
    'Política',
    'Entretenimiento',
  ];

  final List<Map<String, String?>> _canales = [
    {
      'nombre': 'Newars',
      'thumbnail': null,
      'categoria': 'Noticias',
    },
    {
      'nombre': 'Sports',
      'thumbnail': null,
      'categoria': 'Deportes',
    },
    {
      'nombre': 'Concerts',
      'thumbnail': null,
      'categoria': 'Música',
    },
    {
      'nombre': 'Politicas',
      'thumbnail': null,
      'categoria': 'Política',
    },
    {
      'nombre': 'Studio',
      'thumbnail': null,
      'categoria': 'Entretenimiento',
    },
  ];

  List<Map<String, String?>> get _canalesFiltrados {
    if (_categoriaSeleccionada == 'Todos') {
      return _canales;
    }

    return _canales
        .where(
          (canal) =>
              canal['categoria'] == _categoriaSeleccionada,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // HEADER
            // ============================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                4,
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'En Vivo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Todos los canales transmitiendo ahora',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ============================================================
            // CATEGORÍAS
            // ============================================================
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                itemCount: _categorias.length,
                itemBuilder: (context, index) {
                  final categoria = _categorias[index];

                  final seleccionada =
                      categoria == _categoriaSeleccionada;

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(categoria),
                      selected: seleccionada,
                      onSelected: (_) {
                        setState(() {
                          _categoriaSeleccionada = categoria;
                        });
                      },
                      backgroundColor: AppColors.cardDark,
                      selectedColor: AppColors.green,
                      labelStyle: TextStyle(
                        color: seleccionada
                            ? Colors.black
                            : Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ============================================================
            // LISTA DE CANALES
            // ============================================================
            Expanded(
              child: _canalesFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay canales en esta categoría',
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: _canalesFiltrados.length,
                      itemBuilder: (context, index) {
                        final canal =
                            _canalesFiltrados[index];

                        return _LiveScreenCard(
                          nombre: canal['nombre']!,
                          thumbnail: canal['thumbnail'],
                          destacado: false,
                          onTap: () {
                            // Aquí después podemos abrir el reproductor
                          },
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TARJETA DE CANAL
// ============================================================================

class _LiveScreenCard extends StatelessWidget {
  final String nombre;
  final String? thumbnail;
  final bool destacado;
  final VoidCallback onTap;

  const _LiveScreenCard({
    required this.nombre,
    required this.thumbnail,
    required this.destacado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: destacado
              ? Border.all(
                  color: AppColors.green,
                  width: 1.5,
                )
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // IMAGEN
            // ============================================================
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: thumbnail != null &&
                            thumbnail!.isNotEmpty
                        ? Image.network(
                            thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) {
                              return _placeholder();
                            },
                          )
                        : _placeholder(),
                  ),

                  // EN VIVO
                  const Positioned(
                    top: 10,
                    left: 10,
                    child: LiveBadge(),
                  ),
                ],
              ),
            ),

            // ============================================================
            // NOMBRE DEL CANAL
            // ============================================================
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade900,
      child: const Center(
        child: Icon(
          Icons.tv,
          color: Colors.white38,
          size: 45,
        ),
      ),
    );
  }
}