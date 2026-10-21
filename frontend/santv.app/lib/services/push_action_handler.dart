import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/content.dart';
import '../pages/ad_orders_screen.dart';
import '../pages/video_player_screen.dart';
import '../pages/youtube_player_screen.dart';
import 'auth_service.dart';
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
      default:
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