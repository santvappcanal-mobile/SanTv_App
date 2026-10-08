import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/content.dart';
import '../services/auth_service.dart';
import '../services/watchlist_service.dart';
import '../widgets/common/comments_section.dart';
import '../widgets/common/save_to_list_button.dart';

class YoutubePlayerScreen extends StatefulWidget {
  const YoutubePlayerScreen({
    super.key,
    required this.content,
    required this.authService,
    this.watchlistService,
    this.initialSaved = false,
  });

  final ContentItem content;

  /// Se usa para cargar y publicar los comentarios del video.
  final AuthService authService;

  /// Si se pasa, se muestra el botón de guardar en Mi Lista en la barra superior.
  final WatchlistService? watchlistService;
  final bool initialSaved;

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late final YoutubePlayerController _controller;
  bool _idInvalido = false;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayerController.convertUrlToId(
      widget.content.videoUrl,
    );

    if (videoId == null) {
      _idInvalido = true;
      _controller = YoutubePlayerController();
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // En horizontal solo se ve el video; los comentarios quedan para vertical.
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.content.title,
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (widget.watchlistService != null)
            SaveToListButton(
              contentId: widget.content.id,
              watchlistService: widget.watchlistService!,
              initialSaved: widget.initialSaved,
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0B0B), Color(0xFF10241A), Color(0xFF0B0B0B)],
          ),
        ),
        child: _idInvalido
            ? const Center(
                child: Text(
                  'No se pudo reconocer el video de YouTube.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : landscape
                ? Center(
                    child: YoutubePlayer(
                      controller: _controller,
                      aspectRatio: 16 / 9,
                    ),
                  )
                : SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        YoutubePlayer(
                          controller: _controller,
                          aspectRatio: 16 / 9,
                        ),
                        Expanded(
                          child: CommentsSection(
                            contentId: widget.content.id,
                            authService: widget.authService,
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}