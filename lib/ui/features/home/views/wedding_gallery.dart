import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wedding_g_and_e/ui/core/garden/garden_card.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_theme.dart';

class GallerySection extends StatelessWidget {
  const GallerySection({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GardenHeading(
          eyebrow: 'Galería',
          title: 'Momentos ',
          accent: 'en fotos',
        ),
        const SizedBox(height: 22),
        _PolaroidCarousel(images: images),
      ],
    );
  }
}

class _PolaroidCarousel extends StatefulWidget {
  const _PolaroidCarousel({required this.images});

  final List<String> images;

  @override
  State<_PolaroidCarousel> createState() => _PolaroidCarouselState();
}

class _PolaroidCarouselState extends State<_PolaroidCarousel> {
  static const _cycleDuration = Duration(seconds: 4);
  static const _swipeDistanceThreshold = 36.0;
  static const _swipeVelocityThreshold = 260.0;

  Timer? _timer;
  int _currentIndex = 0;
  int _direction = 1;
  double _dragDx = 0;

  bool get _hasMultiple => widget.images.length > 1;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _PolaroidCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images.length == widget.images.length) {
      return;
    }

    _currentIndex = 0;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!_hasMultiple) {
      return;
    }

    _timer = Timer.periodic(_cycleDuration, (_) {
      if (!mounted || widget.images.isEmpty) {
        return;
      }

      _goNext();
    });
  }

  void _goNext() {
    if (!_hasMultiple || !mounted) {
      return;
    }
    setState(() {
      _direction = 1;
      _currentIndex = (_currentIndex + 1) % widget.images.length;
    });
  }

  void _goPrevious() {
    if (!_hasMultiple || !mounted) {
      return;
    }
    setState(() {
      _direction = -1;
      _currentIndex =
          (_currentIndex - 1 + widget.images.length) % widget.images.length;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragDx += details.delta.dx;
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_hasMultiple) {
      _dragDx = 0;
      return;
    }

    final velocity = details.primaryVelocity ?? 0;
    final shouldGoPrevious =
        velocity > _swipeVelocityThreshold || _dragDx > _swipeDistanceThreshold;
    final shouldGoNext =
        velocity < -_swipeVelocityThreshold ||
        _dragDx < -_swipeDistanceThreshold;

    if (shouldGoPrevious) {
      _goPrevious();
      _startTimer();
    } else if (shouldGoNext) {
      _goNext();
      _startTimer();
    }

    _dragDx = 0;
  }

  int _nextIndex(int offset) {
    if (widget.images.isEmpty) {
      return 0;
    }
    return (_currentIndex + offset) % widget.images.length;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final frameWidth = constraints.maxWidth.clamp(260.0, 400.0).toDouble();
        final frameHeight = frameWidth * 1.22;

        final carousel = GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: double.infinity,
            height: frameHeight + 14,
            child: Center(
              child: SizedBox(
                width: frameWidth,
                height: frameHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (widget.images.length > 2)
                      Positioned(
                        top: 6,
                        left: 16,
                        right: 8,
                        bottom: 8,
                        child: Transform.rotate(
                          angle: -0.055,
                          child: Opacity(
                            opacity: 0.42,
                            child: _PolaroidFrame(
                              imageUrl: widget.images[_nextIndex(2)],
                              caption: 'Recuerdo',
                            ),
                          ),
                        ),
                      ),
                    if (widget.images.length > 1)
                      Positioned(
                        top: 2,
                        left: 8,
                        right: 14,
                        bottom: 4,
                        child: Transform.rotate(
                          angle: 0.04,
                          child: Opacity(
                            opacity: 0.64,
                            child: _PolaroidFrame(
                              imageUrl: widget.images[_nextIndex(1)],
                              caption: 'Nuestra historia',
                            ),
                          ),
                        ),
                      ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 850),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: Offset(0.18 * _direction, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        final scale = Tween<double>(
                          begin: 0.965,
                          end: 1,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: slide,
                            child: ScaleTransition(scale: scale, child: child),
                          ),
                        );
                      },
                      child: Transform.rotate(
                        key: ValueKey<int>(_currentIndex),
                        angle: _currentIndex.isEven ? -0.02 : 0.02,
                        child: _PolaroidFrame(
                          imageUrl: widget.images[_currentIndex],
                          caption: 'Edgar y Gabriela',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        if (!_hasMultiple) {
          return carousel;
        }
        return Column(
          children: [
            carousel,
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ArrowButton(
                  icon: Icons.chevron_left,
                  tooltip: 'Foto anterior',
                  onPressed: () {
                    _goPrevious();
                    _startTimer();
                  },
                ),
                const SizedBox(width: 16),
                for (var i = 0; i < widget.images.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentIndex ? 12 : 9,
                    height: i == _currentIndex ? 12 : 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentIndex
                          ? AppTheme.bubblegum
                          : AppTheme.mint,
                    ),
                  ),
                const SizedBox(width: 16),
                _ArrowButton(
                  icon: Icons.chevron_right,
                  tooltip: 'Foto siguiente',
                  onPressed: () {
                    _goNext();
                    _startTimer();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: AppTheme.ink),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.6),
        side: const BorderSide(color: AppTheme.stem),
        fixedSize: const Size(44, 44),
      ),
    );
  }
}

class _PolaroidFrame extends StatelessWidget {
  const _PolaroidFrame({required this.imageUrl, required this.caption});

  final String imageUrl;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final frame = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A4A4A).withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox.expand(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return const ColoredBox(
                        color: Color(0xFFF1ECE6),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(child: Text(caption, style: AppTheme.script(fontSize: 26))),
          ],
        ),
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: frame),
        Positioned(
          top: -9,
          left: 0,
          right: 0,
          child: Center(
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                width: 74,
                height: 22,
                color: AppTheme.lavender.withValues(alpha: 0.75),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
