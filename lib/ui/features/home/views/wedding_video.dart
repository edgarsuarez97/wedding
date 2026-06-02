import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoSection extends StatefulWidget {
  const VideoSection({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _isInitializing = false;

  Future<void> _initializeIfNeeded() async {
    if (_ready || _isInitializing) {
      return;
    }
    setState(() => _isInitializing = true);
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await controller.setLooping(true);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _ready = true;
        _isInitializing = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isInitializing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onPlayPressed() async {
    await _initializeIfNeeded();
    if (!mounted || !_ready || _controller == null) {
      return;
    }
    final controller = _controller!;
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Un momento en movimiento', style: textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(
          'Un breve adelanto de la celebración. Puedes reemplazarlo por tu propio video preboda cuando quieras.',
          style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF5E646A)),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            color: Colors.black,
            height: 320,
            width: double.infinity,
            child: _ready && _controller != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller!.value.size.width,
                          height: _controller!.value.size.height,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: IconButton.filledTonal(
                            onPressed: _onPlayPressed,
                            icon: Icon(
                              _controller!.value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: _isInitializing
                        ? const CircularProgressIndicator()
                        : FilledButton.icon(
                            onPressed: _onPlayPressed,
                            icon: const Icon(Icons.play_circle_outline),
                            label: const Text('Reproducir video'),
                          ),
                  ),
          ),
        ),
      ],
    );
  }
}

