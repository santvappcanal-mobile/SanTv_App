import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/content.dart';
import '../pages/ad_orders_screen.dart';
import '../pages/admin_reports_screen.dart';
import '../pages/report_detail_screen.dart';
import '../pages/video_player_screen.dart';
import '../pages/youtube_player_screen.dart';
import 'auth_service.dart';
import 'report_service.dart';
import 'watchlist_service.dart';

/// Decide a qué pantalla llevar al usuario cuando toca una notificación push.
/// Devuelve la ruta a abrir, o null si no hay nada que abrir.
/// (El caso "en vivo" lo resuelve Home cambiando de pestaña.)
class PushActionHandler {
  PushActionHandler({required this.authService});

  final AuthService authService;

  late final WatchlistService _watchlistService = WatchlistService(
    authService: authService,
  );

  late final ReportService _reportService = ReportService(authService);

  Future<Route<dynamic>?> routeFor(Map<String, dynamic> data) async {
    switch (data['type']?.toString()) {
      case 'new_content':
        return _contentRoute(data['contentId']?.toString());
      case 'billing':
        // Si el aviso es para el admin (nueva solicitud) se abre la lista
        // completa; si no, es sobre la pauta del propio usuario.
        // Con orderId, esa solicitud queda arriba y resaltada.
        final paraAdmin = data['forAdmin']?.toString() == 'true';
        final orderId = data['orderId']?.toString();
        return MaterialPageRoute(
          builder: (_) => AdOrdersScreen(
            authService: authService,
            esAdmin: paraAdmin,
            initialOrderId: (orderId == null || orderId.isEmpty) ? null : orderId,
          ),
        );
      case 'report_pending':
        // A los admins: un reporte nuevo espera revisión.
        return MaterialPageRoute(
          builder: (_) => AdminReportsScreen(authService: authService),
        );
      case 'report_approved':
        // Al autor: su reporte fue aceptado; lo abre con opción de editar/eliminar.
        return _reportRoute(data['reportId']?.toString(), canManage: true);
      case 'community_report':
        // A todos: nuevo reporte publicado en la comunidad.
        return _reportRoute(data['reportId']?.toString());
      default:
        return null;
    }
  }

  Future<Route<dynamic>?> _reportRoute(String? id, {bool canManage = false}) async {
    if (id == null || id.isEmpty) return null;

    try {
      final report = await _reportService.getById(id);
      return MaterialPageRoute(
        builder: (_) => ReportDetailScreen(
          report: report,
          authService: authService,
          canManage: canManage,
        ),
      );
    } catch (_) {
      // Reporte eliminado o sin permiso: no hay nada que abrir.
      return null;
    }
  }

  Future<Route<dynamic>?> _contentRoute(String? id) async {
    if (id == null || id.isEmpty) return null;

    try {
      final response = await http
          .get(Uri.parse('${authService.baseUrl}/api/content/$id'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final content = ContentItem.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );

      // Igual que al abrir un video desde Explorar: cuenta la vista del usuario.
      _watchlistService.registrarVisto(content.id);

      return MaterialPageRoute(
        builder: (_) => content.isYoutube
            ? YoutubePlayerScreen(
                content: content,
                authService: authService,
                watchlistService: _watchlistService,
              )
            : VideoPlayerScreen(
                content: content,
                authService: authService,
                watchlistService: _watchlistService,
              ),
      );
    } catch (_) {
      return null;
    }
  }
}