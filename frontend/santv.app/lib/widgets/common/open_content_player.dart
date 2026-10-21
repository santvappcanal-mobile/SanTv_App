import 'package:flutter/material.dart';
import 'package:santv_app/models/content.dart';
import 'package:santv_app/pages/video_player_screen.dart';
import 'package:santv_app/pages/youtube_player_screen.dart';
import 'package:santv_app/services/auth_service.dart';
import 'package:santv_app/services/watchlist_service.dart';

/// Abre el reproductor de un video (YouTube o normal).
///
/// Registra la vista de inmediato (suma la vista pública solo la primera
/// vez que este usuario lo ve), abre el reproductor y espera a que el
/// registro quede guardado. Quien la llama refresca su lista al volver.
Future<void> openContentPlayer(
  BuildContext context, {
  required ContentItem content,
  required AuthService authService,
  required WatchlistService watchlist,
  required bool initialSaved,
}) async {
  // Se dispara de inmediato, sin bloquear la apertura del reproductor.
  final vistoFuture = watchlist.registrarVisto(content.id);

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => content.isYoutube
          ? YoutubePlayerScreen(
              content: content,
              authService: authService,
              watchlistService: watchlist,
              initialSaved: initialSaved,
            )
          : VideoPlayerScreen(
              content: content,
              authService: authService,
              watchlistService: watchlist,
              initialSaved: initialSaved,
            ),
    ),
  );

  await vistoFuture;
}