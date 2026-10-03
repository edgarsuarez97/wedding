import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wedding_g_and_e/ui/core/garden/garden_card.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_motion.dart';
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

/// Una polaroid fija sobre dos de fondo; solo la foto cambia con un fundido
/// suave. El avance automático usa un [AnimationController] en vez de un
/// Timer para que se pause solo cuando la galería no está en pantalla.
class _PolaroidCarouselState extends State<_PolaroidCarousel>
    with SingleTickerProviderStateMixin {
  static const _swipeDistanceThreshold = 36.0;
  static const _swipeVelocityThreshold = 260.0;

  late final AnimationController _autoplay = AnimationController(
    vsync: this,
    duration: AppMotion.galleryHold,
  )..addStatusListener(_onAutoplayStatus);
  int _currentIndex = 0;
  double _dragDx = 0;
  double _decodeWidth = 800;

  bool get _hasMultiple => widget.images.length > 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasMultiple && !_autoplay.isAnimating) {
      _autoplay.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant _PolaroidCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images.length != widget.images.length) {
      _currentIndex = 0;
      _restartAutoplay();
    }
  }

  @override
  void dispose() {
    _autoplay.dispose();
    super.dispose();
  }

  void _onAutoplayStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _show(_currentIndex + 1);
    }
  }

  void _restartAutoplay() {
    if (_hasMultiple) {
      _autoplay.forward(from: 0);
    } else {
      _autoplay.stop();
    }
  }

  ImageProvider _provider(int index) => ResizeImage(
    NetworkImage(widget.images[index % widget.images.length]),
    width: _decodeWidth.round(),
    policy: ResizeImagePolicy.fit,
  );

  void _show(int index) {
    if (!_hasMultiple || !mounted) {
      return;
    }
    setState(() {
      _currentIndex = index % widget.images.length;
    });
    // Decodifica la siguiente antes de que le toque, para que el fundido
    // no espere a la red.
    unawaited(precacheImage(_provider(_currentIndex + 1), context));
    _restartAutoplay();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragDx += details.delta.dx;
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > _swipeVelocityThreshold ||
        _dragDx > _swipeDistanceThreshold) {
      _show(_currentIndex - 1 + widget.images.length);
    } else if (velocity < -_swipeVelocityThreshold ||
        _dragDx < -_swipeDistanceThreshold) {
      _show(_currentIndex + 1);
    }
    _dragDx = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }
    final fade = AppMotion.reduced(context)
        ? Duration.zero
        : AppMotion.galleryFade;

    return LayoutBuilder(
      builder: (context, constraints) {
        final frameWidth = constraints.maxWidth.clamp(260.0, 400.0).toDouble();
        final frameHeight = frameWidth * 1.22;
        _decodeWidth = frameWidth * MediaQuery.devicePixelRatioOf(context);

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
                    // Polaroids de fondo: estáticas y sin foto.
                    if (_hasMultiple)
                      const Positioned.fill(
                        child: RepaintBoundary(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: 6,
                                left: 16,
                                right: 8,
                                bottom: 8,
                                child: _BackFrame(angle: -0.055),
                              ),
                              Positioned(
                                top: 2,
                                left: 8,
                                right: 14,
                                bottom: 4,
                                child: _BackFrame(angle: 0.04),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: Transform.rotate(
                        angle: -0.02,
                        child: _PolaroidFrame(
                          caption: 'Edgar y Gabriela',
                          photo: RepaintBoundary(
                            child: AnimatedSwitcher(
                              duration: fade,
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              layoutBuilder: (current, previous) => Stack(
                                fit: StackFit.expand,
                                children: [...previous, ?current],
                              ),
                              child: Image(
                                key: ValueKey<int>(_currentIndex),
                                image: _provider(_currentIndex),
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.medium,
                                gaplessPlayback: true,
                                frameBuilder: (context, child, frame, sync) =>
                                    frame == null && !sync
                                    ? const ColoredBox(color: Color(0xFFF1ECE6))
                                    : child,
                              ),
                            ),
                          ),
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
                  onPressed: () =>
                      _show(_currentIndex - 1 + widget.images.length),
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
                  onPressed: () => _show(_currentIndex + 1),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Polaroid vacía para dar profundidad detrás de la principal.
class _BackFrame extends StatelessWidget {
  const _BackFrame({required this.angle});

  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4EE),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F4A4A4A),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
      ),
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
  const _PolaroidFrame({required this.photo, required this.caption});

  final Widget photo;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final frame = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E4A4A4A),
            blurRadius: 14,
            offset: Offset(0, 8),
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
                child: SizedBox.expand(child: photo),
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
