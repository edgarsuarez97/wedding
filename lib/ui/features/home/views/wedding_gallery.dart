import 'dart:async';

import 'package:flutter/material.dart';

class GallerySection extends StatelessWidget {
  const GallerySection({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Momentos en fotos',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
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
        final frameWidth = constraints.maxWidth.clamp(280.0, 540.0).toDouble();
        final frameHeight = frameWidth * 1.22;

        return GestureDetector(
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
      },
    );
  }
}

class _PolaroidFrame extends StatelessWidget {
  const _PolaroidFrame({required this.imageUrl, required this.caption});

  final String imageUrl;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(
              caption,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5E5A54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
