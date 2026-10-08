import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/content.dart';
import '../services/watchlist_service.dart';
import '../widgets/common/save_to_list_button.dart';

class YoutubePlayerScreen extends StatefulWidget {
  const YoutubePlayerScreen({
    super.key,
    required this.content,
    this.watchlistService,
    this.initialSaved = false,
  });

  final ContentItem content;

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
      body: _idInvalido
          ? const Center(
              child: Text(
                'No se pudo reconocer el video de YouTube.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : Center(
              child: YoutubePlayer(
                controller: _controller,
                aspectRatio: 16 / 9,
              ),
            ),
    );
  }
}