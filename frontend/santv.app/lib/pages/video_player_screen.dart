import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/content.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.content});

  final ContentItem content;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.content.videoUrl))
          ..initialize()
              .then((_) {
                if (!mounted) return;
                setState(() {});
                _controller.play();
              })
              .catchError((_) {
                if (!mounted) return;
                setState(() => _error = true);
              });
  }

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
          widget.content.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: _error
            ? const Text(
                'No se pudo reproducir el video.',
                style: TextStyle(color: Colors.white70),
              )
            : _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller),
                    VideoProgressIndicator(_controller, allowScrubbing: true),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: Color(0xFF39FF14)),
      ),
      floatingActionButton: _controller.value.isInitialized
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF39FF14),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.black,
              ),
            )
          : null,
    );
  }
}
