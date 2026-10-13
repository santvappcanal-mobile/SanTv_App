import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/gallery_item.dart';

/// Cuadrícula de 2 columnas con las imágenes del portafolio.
/// Al tocar una se abre la vista ampliada ([GalleryViewerPage]).
/// Si [onDelete] no es null (admin), muestra el ícono de eliminar.
class GalleryGrid extends StatelessWidget {
  const GalleryGrid({super.key, required this.items, this.onDelete});

  final List<GalleryItem> items;
  final void Function(GalleryItem item)? onDelete;

  static const Color neonGreen = Color(0xFF39FF14);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Material(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      GalleryViewerPage(items: items, initialIndex: index),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: item.mediaUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: neonGreen,
                    ),
                  ),
                  errorWidget: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
                if (onDelete != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkResponse(
                      onTap: () => onDelete!(item),
                      radius: 20,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Vista ampliada: deslizas para pasar de una imagen a otra y
/// con dos dedos haces zoom.
class GalleryViewerPage extends StatefulWidget {
  const GalleryViewerPage({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  final List<GalleryItem> items;
  final int initialIndex;

  @override
  State<GalleryViewerPage> createState() => _GalleryViewerPageState();
}

class _GalleryViewerPageState extends State<GalleryViewerPage> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _current = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_current + 1} / ${widget.items.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.items.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.items[index].mediaUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF39FF14)),
                ),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image, color: Colors.grey, size: 48),
              ),
            ),
          );
        },
      ),
    );
  }
}