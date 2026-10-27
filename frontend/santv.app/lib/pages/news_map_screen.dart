import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/report.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import 'report_create_screen.dart';

class NewsMapScreen extends StatefulWidget {
  const NewsMapScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<NewsMapScreen> createState() => _NewsMapScreenState();
}

class _NewsMapScreenState extends State<NewsMapScreen> {
  static const _neon = Color(0xFF39FF14);
  // Centro de Colombia por si todavía no hay reportes
  static const _fallbackCenter = LatLng(4.5709, -74.2973);

  late final ReportService _service = ReportService(widget.authService);

  List<Report> _reports = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getMap();
      if (!mounted) return;
      setState(() => _reports = data);
    } on ReportException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  MapOptions _mapOptions() {
    if (_reports.length >= 2) {
      final points = _reports.map((r) => LatLng(r.latitude, r.longitude)).toList();
      return MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(60),
          maxZoom: 15,
        ),
      );
    }
    if (_reports.length == 1) {
      return MapOptions(
        initialCenter: LatLng(_reports.first.latitude, _reports.first.longitude),
        initialZoom: 14,
      );
    }
    return const MapOptions(initialCenter: _fallbackCenter, initialZoom: 5.5);
  }

  void _showReport(Report r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: r.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.black26,
                  child: const Icon(Icons.broken_image, color: Colors.white38),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _neon.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(r.category,
                  style: const TextStyle(color: _neon, fontWeight: FontWeight.w600)),
            ).wrapAlignLeft(),
            const SizedBox(height: 10),
            Text(r.title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(r.description, style: const TextStyle(color: Colors.white70, height: 1.4)),
            if (r.address.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.place, size: 16, color: Colors.white54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(r.address, style: const TextStyle(color: Colors.white54)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Text(
              'Reportado por ${r.authorName.isEmpty ? 'un ciudadano' : r.authorName}'
              '${r.authorBadge.isNotEmpty ? ' · ${r.authorBadge}' : ''}',
              style: const TextStyle(color: _neon, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0B),
        foregroundColor: Colors.white,
        title: const Text('Mapa de noticias'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _neon,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.campaign),
        label: const Text('Reportar'),
        onPressed: () async {
          final sent = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => ReportCreateScreen(authService: widget.authService),
            ),
          );
          if (sent == true) _load();
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _neon))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _load, child: const Text('Reintentar')),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      // La key fuerza a reconstruir la cámara cuando cambian los reportes
                      key: ValueKey(_reports.length),
                      options: _mapOptions(),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.santv_app',
                        ),
                        MarkerLayer(
                          markers: _reports
                              .map(
                                (r) => Marker(
                                  point: LatLng(r.latitude, r.longitude),
                                  width: 44,
                                  height: 44,
                                  child: GestureDetector(
                                    onTap: () => _showReport(r),
                                    child: const Icon(Icons.location_on,
                                        color: Color(0xFFE53935), size: 44),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution('© OpenStreetMap contributors'),
                          ],
                        ),
                      ],
                    ),
                    if (_reports.isEmpty)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141414).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Aún no hay noticias de la comunidad en el mapa. ¡Sé el primero en reportar!',
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

extension on Widget {
  Widget wrapAlignLeft() => Align(alignment: Alignment.centerLeft, child: this);
}
