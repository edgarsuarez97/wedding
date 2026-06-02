import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../../domain/models/rsvp_submission.dart';
import '../../../../domain/models/schedule_item.dart';
import '../../../../domain/models/wedding_content.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/rsvp_cubit.dart';
import '../cubit/wedding_content_cubit.dart';

class WeddingHomePage extends StatelessWidget {
  const WeddingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeddingContentCubit, WeddingContentState>(
      key: const ValueKey('wedding-experience-state'),
      builder: (context, state) {
        return switch (state.status) {
          WeddingContentStatus.success => _WeddingExperience(
            content: state.content!,
          ),
          WeddingContentStatus.failure => Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No fue posible cargar los detalles de la boda.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          context.read<WeddingContentCubit>().load(),
                      child: const Text('Intentar de nuevo'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
        };
      },
    );
  }
}

class _WeddingExperience extends StatefulWidget {
  const _WeddingExperience({required this.content});

  final WeddingContent content;

  @override
  State<_WeddingExperience> createState() => _WeddingExperienceState();
}

class _WeddingExperienceState extends State<_WeddingExperience> {
  static const _heroSongAsset = 'assets/audio/wedding_song.mp3';
  static const _heroAudioLoadTimeout = Duration(seconds: 8);

  bool _didPrecache = false;
  late final AudioPlayer _heroAudioPlayer;
  StreamSubscription<PlayerState>? _heroAudioSubscription;
  bool _isHeroMusicPlaying = false;
  bool _isPreparingAudio = false;
  bool _isTogglingAudio = false;
  bool _isHeroAudioLoaded = false;

  @override
  void initState() {
    super.initState();
    _heroAudioPlayer = AudioPlayer();
    unawaited(_heroAudioPlayer.setLoopMode(LoopMode.one));
    _heroAudioSubscription = _heroAudioPlayer.playerStateStream.listen((state) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isHeroMusicPlaying = state.playing;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecache) {
      return;
    }
    _didPrecache = true;
    final previewImages = [
      widget.content.heroImageUrl,
      ...widget.content.galleryImageUrls.take(2),
    ];
    for (final imageUrl in previewImages) {
      unawaited(precacheImage(NetworkImage(imageUrl), context));
    }
  }

  @override
  void dispose() {
    _heroAudioSubscription?.cancel();
    unawaited(_heroAudioPlayer.dispose());
    super.dispose();
  }

  Future<void> _toggleHeroMusic() async {
    if (_isPreparingAudio || _isTogglingAudio) {
      return;
    }

    try {
      setState(() => _isTogglingAudio = true);

      if (!_isHeroAudioLoaded) {
        setState(() => _isPreparingAudio = true);
        await _heroAudioPlayer
            .setAsset(_heroSongAsset)
            .timeout(_heroAudioLoadTimeout);
        _isHeroAudioLoaded = true;
        if (mounted) {
          setState(() => _isPreparingAudio = false);
        }
      }

      final shouldPause = _isHeroMusicPlaying;

      if (shouldPause) {
        await _heroAudioPlayer.pause().timeout(const Duration(seconds: 2));
        if (mounted) {
          setState(() => _isHeroMusicPlaying = false);
        }
      } else {
        unawaited(_heroAudioPlayer.play());
        if (mounted) {
          setState(() => _isHeroMusicPlaying = true);
        }
      }
    } on TimeoutException {
      if (!mounted) {
        return;
      }
      const errorMessage =
          'La cancion tardo demasiado en cargar. Intentalo de nuevo.';
      setState(() {
        _isHeroAudioLoaded = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(errorMessage)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      const errorMessage =
          'No se encontro el audio adjunto. Guarda la cancion en assets/audio/wedding_song.mp3';
      setState(() {
        _isHeroAudioLoaded = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(errorMessage)));
    } finally {
      if (mounted) {
        setState(() {
          _isPreparingAudio = false;
          _isTogglingAudio = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 920;

          return SingleChildScrollView(
            child: Column(
              children: [
                _HeroSection(
                  weddingDate: widget.content.weddingDate,
                  heroImageUrl: widget.content.heroImageUrl,
                  coupleNames: widget.content.coupleNames,
                  isMusicPlaying: _isHeroMusicPlaying,
                  isMusicBusy: _isPreparingAudio,
                  onToggleMusic: _toggleHeroMusic,
                ),
                _SectionContainer(
                  background: AppTheme.paper,
                  decorationMode: _SectionDecorationMode.vineGarden,
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _ScrollReveal(
                                from: _RevealFrom.left,
                                child: _StorySection(
                                  story: widget.content.story,
                                ),
                              ),
                            ),
                            SizedBox(width: 28),
                            Expanded(
                              child: _ScrollReveal(
                                from: _RevealFrom.right,
                                child: _ScheduleSection(
                                  schedule: widget.content.schedule,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _ScrollReveal(
                              from: _RevealFrom.left,
                              child: _StorySection(story: widget.content.story),
                            ),
                            SizedBox(height: 28),
                            _ScrollReveal(
                              from: _RevealFrom.right,
                              child: _ScheduleSection(
                                schedule: widget.content.schedule,
                              ),
                            ),
                          ],
                        ),
                ),
                _SectionContainer(
                  background: const Color(0xFFFFFCFD),
                  decorationMode: _SectionDecorationMode.softFloralCorners,
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _ScrollReveal(
                                from: _RevealFrom.left,
                                child: _GallerySection(
                                  images: widget.content.galleryImageUrls,
                                ),
                              ),
                            ),
                            SizedBox(width: 28),
                            Expanded(
                              child: _ScrollReveal(
                                from: _RevealFrom.right,
                                child: _VideoSection(
                                  videoUrl: widget.content.videoUrl,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _ScrollReveal(
                              from: _RevealFrom.left,
                              child: _GallerySection(
                                images: widget.content.galleryImageUrls,
                              ),
                            ),
                            SizedBox(height: 28),
                            _ScrollReveal(
                              from: _RevealFrom.right,
                              child: _VideoSection(
                                videoUrl: widget.content.videoUrl,
                              ),
                            ),
                          ],
                        ),
                ),
                _SectionContainer(
                  background: Colors.white,
                  decorationMode: _SectionDecorationMode.roseFrame,
                  child: _ScrollReveal(
                    from: _RevealFrom.left,
                    delayMs: 90,
                    child: const _RsvpSection(),
                  ),
                ),
                _SectionContainer(
                  background: Color(0xFFFFFAFE),
                  decorationMode: _SectionDecorationMode.vineGarden,
                  child: _ScrollReveal(
                    from: _RevealFrom.right,
                    child: const _VenueAndFaqSection(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum _RevealFrom { left, right }

class _ScrollReveal extends StatefulWidget {
  const _ScrollReveal({
    required this.child,
    this.from = _RevealFrom.left,
    this.delayMs = 0,
  });

  final Widget child;
  final _RevealFrom from;
  final int delayMs;

  @override
  State<_ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<_ScrollReveal> {
  ScrollPosition? _position;
  bool _revealed = false;
  bool _revealScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion && !_revealed) {
      _revealed = true;
      return;
    }

    final nextPosition = Scrollable.maybeOf(context)?.position;
    if (_position == nextPosition) {
      return;
    }

    _position?.removeListener(_checkVisibility);
    _position = nextPosition;
    _position?.addListener(_checkVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    _position?.removeListener(_checkVisibility);
    super.dispose();
  }

  void _checkVisibility() {
    if (_revealed || _revealScheduled || !mounted) {
      return;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) {
      return;
    }

    final viewportHeight = MediaQuery.sizeOf(context).height;
    final top = renderObject.localToGlobal(Offset.zero).dy;
    final bottom = top + renderObject.size.height;

    final visibleTop = top.clamp(0.0, viewportHeight).toDouble();
    final visibleBottom = bottom.clamp(0.0, viewportHeight).toDouble();
    final visibleHeight = visibleBottom - visibleTop;
    final shouldReveal =
        visibleHeight >= (renderObject.size.height * 0.18) ||
        top <= viewportHeight * 0.84;

    if (!shouldReveal) {
      return;
    }

    if (widget.delayMs == 0) {
      setState(() => _revealed = true);
      return;
    }

    _revealScheduled = true;
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) {
        return;
      }
      setState(() => _revealed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hiddenOffset = widget.from == _RevealFrom.left
        ? const Offset(-0.12, 0)
        : const Offset(0.12, 0);

    return AnimatedOpacity(
      opacity: _revealed ? 1 : 0,
      duration: const Duration(milliseconds: 720),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _revealed ? Offset.zero : hiddenOffset,
        duration: const Duration(milliseconds: 720),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({
    required this.background,
    required this.child,
    this.decorationMode = _SectionDecorationMode.none,
  });

  final Color background;
  final Widget child;
  final _SectionDecorationMode decorationMode;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(decoration: BoxDecoration(color: background)),
        ),
        ..._buildSectionOrnaments(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSectionOrnaments() {
    return switch (decorationMode) {
      _SectionDecorationMode.none => const [],
      _SectionDecorationMode.softFloralCorners => [
        const Positioned(
          top: -6,
          left: -6,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/floral_corner_watercolor.svg',
            size: 132,
            opacity: 0.58,
          ),
        ),
        const Positioned(
          top: -6,
          right: -6,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/floral_corner_watercolor.svg',
            size: 132,
            opacity: 0.58,
            quarterTurns: 1,
          ),
        ),
        const Positioned(
          bottom: -8,
          left: -6,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/floral_corner_watercolor.svg',
            size: 132,
            opacity: 0.58,
            quarterTurns: 3,
          ),
        ),
        const Positioned(
          bottom: -8,
          right: -6,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/floral_corner_watercolor.svg',
            size: 132,
            opacity: 0.58,
            quarterTurns: 2,
          ),
        ),
      ],
      _SectionDecorationMode.vineGarden => [
        const Positioned(
          top: 10,
          bottom: 10,
          left: 0,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/vine_vertical_watercolor.svg',
            width: 120,
            opacity: 0.62,
          ),
        ),
        const Positioned(
          top: 10,
          bottom: 10,
          right: 0,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/vine_vertical_watercolor.svg',
            width: 120,
            opacity: 0.62,
            flipX: true,
          ),
        ),
      ],
      _SectionDecorationMode.roseFrame => [
        const Positioned(
          top: -8,
          left: -8,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/floral_corner_watercolor.svg',
            size: 148,
            opacity: 0.66,
          ),
        ),
        const Positioned(
          top: -8,
          right: -8,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/floral_corner_watercolor.svg',
            size: 148,
            opacity: 0.66,
            quarterTurns: 1,
          ),
        ),
        const Positioned(
          bottom: -18,
          left: 18,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/vine_vertical_watercolor.svg',
            width: 96,
            opacity: 0.55,
            quarterTurns: 1,
          ),
        ),
        const Positioned(
          bottom: -18,
          right: 18,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/vine_vertical_watercolor.svg',
            width: 96,
            opacity: 0.55,
            quarterTurns: 3,
          ),
        ),
      ],
    };
  }
}

enum _SectionDecorationMode { none, softFloralCorners, vineGarden, roseFrame }

class _SectionOrnament extends StatelessWidget {
  const _SectionOrnament({
    required this.assetPath,
    this.size,
    this.width,
    this.opacity = 0.6,
    this.quarterTurns = 0,
    this.flipX = false,
  });

  final String assetPath;
  final double? size;
  final double? width;
  final double opacity;
  final int quarterTurns;
  final bool flipX;

  @override
  Widget build(BuildContext context) {
    final ornament = SizedBox(
      width: width ?? size,
      height: size,
      child: SvgPicture.asset(assetPath, fit: BoxFit.contain),
    );

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: RotatedBox(
          quarterTurns: quarterTurns,
          child: flipX
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(-1, 1, 1),
                  child: ornament,
                )
              : ornament,
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.weddingDate,
    required this.heroImageUrl,
    required this.coupleNames,
    required this.isMusicPlaying,
    required this.isMusicBusy,
    required this.onToggleMusic,
  });

  final DateTime weddingDate;
  final String heroImageUrl;
  final String coupleNames;
  final bool isMusicPlaying;
  final bool isMusicBusy;
  final VoidCallback onToggleMusic;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat(
      "EEEE d 'de' MMMM 'de' y",
      'es_ES',
    ).format(weddingDate);
    return Stack(
      children: [
        SizedBox(
          height: 680,
          width: double.infinity,
          child: Image.network(
            heroImageUrl,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
        Container(
          height: 680,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.58),
                Colors.black.withValues(alpha: 0.18),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 18, right: 18),
            child: _BouncingMusicButton(
              isPlaying: isMusicPlaying,
              isBusy: isMusicBusy,
              onPressed: onToggleMusic,
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.86),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text('Save The Date'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      coupleNames,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 68,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      dateText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 22),
                    _CountdownPill(targetDate: weddingDate),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _launchGoogleCalendar(weddingDate),
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Agregar a Google Calendar'),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70),
                          ),
                          onPressed: () => _openExternal(
                            'https://maps.google.com/?q=Rosewood+Garden+Estate',
                          ),
                          icon: const Icon(Icons.location_on_outlined),
                          label: const Text('Ver lugar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BouncingMusicButton extends StatefulWidget {
  const _BouncingMusicButton({
    required this.isPlaying,
    required this.isBusy,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isBusy;
  final VoidCallback onPressed;

  @override
  State<_BouncingMusicButton> createState() => _BouncingMusicButtonState();
}

class _BouncingMusicButtonState extends State<_BouncingMusicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 920),
    )..repeat(reverse: true);
    _offset = Tween<double>(
      begin: 0,
      end: -6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offset.value),
          child: child,
        );
      },
      child: Material(
        color: Colors.white.withValues(alpha: 0.90),
        shape: const CircleBorder(),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.24),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.isBusy ? null : widget.onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: widget.isBusy
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : Icon(
                    widget.isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    size: 32,
                    color: const Color(0xFF4C5B4F),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CountdownPill extends StatefulWidget {
  const _CountdownPill({required this.targetDate});

  final DateTime targetDate;

  @override
  State<_CountdownPill> createState() => _CountdownPillState();
}

class _CountdownPillState extends State<_CountdownPill> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.targetDate.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _remaining = widget.targetDate.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays.clamp(0, 9999);
    final hours = (_remaining.inHours % 24).clamp(0, 23);
    final minutes = (_remaining.inMinutes % 60).clamp(0, 59);
    final seconds = (_remaining.inSeconds % 60).clamp(0, 59);
    final isCompact = MediaQuery.sizeOf(context).width < 430;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CountdownMetric(
            value: '$days',
            label: 'dias',
            compact: isCompact,
            boxWidth: isCompact ? 78 : 110,
          ),
          SizedBox(width: isCompact ? 8 : 12),
          _CountdownMetric(
            value: hours.toString().padLeft(2, '0'),
            label: 'horas',
            compact: isCompact,
            boxWidth: isCompact ? 64 : 86,
          ),
          SizedBox(width: isCompact ? 8 : 12),
          _CountdownMetric(
            value: minutes.toString().padLeft(2, '0'),
            label: 'minutos',
            compact: isCompact,
            boxWidth: isCompact ? 64 : 86,
          ),
          SizedBox(width: isCompact ? 8 : 12),
          _CountdownMetric(
            value: seconds.toString().padLeft(2, '0'),
            label: 'segundos',
            compact: isCompact,
            boxWidth: isCompact ? 64 : 86,
          ),
        ],
      ),
    );
  }
}

class _CountdownMetric extends StatelessWidget {
  const _CountdownMetric({
    required this.value,
    required this.label,
    this.compact = false,
    required this.boxWidth,
  });

  final String value;
  final String label;
  final bool compact;
  final double boxWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: boxWidth,
          height: compact ? 64 : 84,
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.54)),
          ),
          child: Center(
            child: _AnimatedCountdownNumber(value: value, compact: compact),
          ),
        ),
        SizedBox(height: compact ? 6 : 8),
        Text(
          label,
          style: GoogleFonts.lora(
            fontSize: compact ? 12 : 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.1,
            color: Colors.white.withValues(alpha: 0.94),
          ),
        ),
      ],
    );
  }
}

class _AnimatedCountdownNumber extends StatelessWidget {
  const _AnimatedCountdownNumber({required this.value, required this.compact});

  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: child),
        );
      },
      child: Text(
        value,
        key: ValueKey<String>(value),
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: GoogleFonts.lora(
          fontSize: compact ? 30 : 44,
          height: 1,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StorySection extends StatelessWidget {
  const _StorySection({required this.story});

  final String story;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nuestra historia', style: textTheme.headlineMedium),
        const SizedBox(height: 14),
        Text(
          story,
          style: textTheme.titleMedium?.copyWith(
            height: 1.5,
            color: const Color(0xFF5E646B),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              colors: [AppTheme.rose, AppTheme.lavender, Colors.white],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF866574)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Código de vestimenta: formal de jardín en colores suaves. La recepción continúa con una fiesta bajo la luna.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF4C5258),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({required this.schedule});

  final List<ScheduleItem> schedule;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;
        final lineLeft = isCompact ? 26.0 : (constraints.maxWidth / 2) - 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Itinerario de la boda', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                isCompact ? 8 : 18,
                24,
                isCompact ? 8 : 18,
                24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFEFC),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFF0E5D6)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB79872).withValues(alpha: 0.16),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -10,
                    left: -10,
                    child: _FloralCorner(size: isCompact ? 84 : 110),
                  ),
                  Positioned(
                    top: -10,
                    right: -10,
                    child: _FloralCorner(
                      size: isCompact ? 84 : 110,
                      quarterTurns: 1,
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    left: -10,
                    child: _FloralCorner(
                      size: isCompact ? 84 : 110,
                      quarterTurns: 3,
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    right: -10,
                    child: _FloralCorner(
                      size: isCompact ? 84 : 110,
                      quarterTurns: 2,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    bottom: 6,
                    left: lineLeft,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF3F3A35),
                            Color(0xFF6F665C),
                            Color(0xFF3F3A35),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      ...schedule.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: entry.key == schedule.length - 1 ? 0 : 14,
                          ),
                          child: _TimelineEventRow(
                            item: entry.value,
                            icon: _scheduleIcon(entry.value.title, entry.key),
                            isLeft: entry.key.isEven,
                            isCompact: isCompact,
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TimelineEventRow extends StatelessWidget {
  const _TimelineEventRow({
    required this.item,
    required this.icon,
    required this.isLeft,
    required this.isCompact,
  });

  final ScheduleItem item;
  final IconData icon;
  final bool isLeft;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          _TimelineMarker(icon: icon),
          const SizedBox(width: 12),
          Expanded(child: _TimelineEventCard(item: item, alignRight: false)),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: isLeft
              ? _TimelineEventCard(item: item, alignRight: true)
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 20),
        _TimelineMarker(icon: icon),
        const SizedBox(width: 20),
        Expanded(
          child: !isLeft
              ? _TimelineEventCard(item: item, alignRight: false)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _TimelineMarker extends StatelessWidget {
  const _TimelineMarker({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFB),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF3A3530), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E5140).withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 15, color: const Color(0xFF2F2B27)),
    );
  }
}

class _FloralCorner extends StatelessWidget {
  const _FloralCorner({required this.size, this.quarterTurns = 0});

  final double size;
  final int quarterTurns;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.82,
      child: RotatedBox(
        quarterTurns: quarterTurns,
        child: SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(
            'assets/illustrations/floral_corner.svg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _TimelineEventCard extends StatelessWidget {
  const _TimelineEventCard({required this.item, required this.alignRight});

  final ScheduleItem item;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEADBC9)),
        ),
        child: Column(
          crossAxisAlignment: alignRight
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              item.timeLabel,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: const Color(0xFF4F443A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.title,
              textAlign: alignRight ? TextAlign.right : TextAlign.left,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF312A24),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              textAlign: alignRight ? TextAlign.right : TextAlign.left,
              style: textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: const Color(0xFF665C53),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _scheduleIcon(String title, int index) {
  final normalized = title.toLowerCase();

  if (normalized.contains('ceremon')) {
    return Icons.favorite_border;
  }
  if (normalized.contains('coctel') || normalized.contains('cóctel')) {
    return Icons.local_bar_outlined;
  }
  if (normalized.contains('recepci') || normalized.contains('cena')) {
    return Icons.restaurant_menu_outlined;
  }
  if (normalized.contains('baile')) {
    return Icons.music_note_outlined;
  }
  if (normalized.contains('llegada') || normalized.contains('bienvenida')) {
    return Icons.celebration;
  }

  return switch (index % 4) {
    0 => Icons.auto_awesome_outlined,
    1 => Icons.local_bar_outlined,
    2 => Icons.restaurant_menu_outlined,
    _ => Icons.nightlife_outlined,
  };
}

class _GallerySection extends StatelessWidget {
  const _GallerySection({required this.images});

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

class _VideoSection extends StatefulWidget {
  const _VideoSection({required this.videoUrl});

  final String videoUrl;

  @override
  State<_VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<_VideoSection> {
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

class _RsvpSection extends StatefulWidget {
  const _RsvpSection();

  @override
  State<_RsvpSection> createState() => _RsvpSectionState();
}

class _RsvpSectionState extends State<_RsvpSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dietaryController = TextEditingController();
  String _attendance = 'Asistiré con gusto';
  int _guestCount = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dietaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocConsumer<RsvpCubit, RsvpState>(
      listener: (context, state) {
        if (state.message case final message?) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == RsvpSubmissionStatus.submitting;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirmación de asistencia',
              style: textTheme.displaySmall?.copyWith(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              'Elige la forma de confirmar asistencia. El formulario nativo mantiene a tus invitados en el sitio. Google Forms es ideal para una recolección rápida externa.',
              style: textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF5B6167),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('RSVP nativo en Flutter'),
                  selected: state.mode == RsvpMode.native,
                  onSelected: (_) =>
                      context.read<RsvpCubit>().setMode(RsvpMode.native),
                ),
                ChoiceChip(
                  label: const Text('RSVP con Google Forms'),
                  selected: state.mode == RsvpMode.google,
                  onSelected: (_) =>
                      context.read<RsvpCubit>().setMode(RsvpMode.google),
                ),
              ],
            ),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: state.mode == RsvpMode.native
                  ? Form(
                      key: _formKey,
                      child: Column(
                        key: const ValueKey('native-rsvp-form'),
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 760;
                              if (isWide) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _nameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Nombre completo',
                                        ),
                                        validator: (value) =>
                                            (value == null ||
                                                value.trim().isEmpty)
                                            ? 'Por favor ingresa tu nombre'
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _emailController,
                                        decoration: const InputDecoration(
                                          labelText: 'Correo electrónico',
                                        ),
                                        validator: (value) =>
                                            (value == null ||
                                                !value.contains('@'))
                                            ? 'Ingresa un correo válido'
                                            : null,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Column(
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre completo',
                                    ),
                                    validator: (value) =>
                                        (value == null || value.trim().isEmpty)
                                        ? 'Por favor ingresa tu nombre'
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Correo electrónico',
                                    ),
                                    validator: (value) =>
                                        (value == null || !value.contains('@'))
                                        ? 'Ingresa un correo válido'
                                        : null,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _attendance,
                            items: const [
                              DropdownMenuItem(
                                value: 'Asistiré con gusto',
                                child: Text('Asistiré con gusto'),
                              ),
                              DropdownMenuItem(
                                value: 'Con cariño, no podré asistir',
                                child: Text('Con cariño, no podré asistir'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _attendance = value);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Asistencia',
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: _guestCount,
                            items: List.generate(
                              4,
                              (index) => DropdownMenuItem(
                                value: index + 1,
                                child: Text(
                                  '${index + 1} invitado${index == 0 ? '' : 's'}',
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _guestCount = value);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Número de asistentes',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dietaryController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Notas alimentarias',
                              hintText:
                                  'Alergias, vegetariano, sin gluten, etc.',
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () {
                                      if (!(_formKey.currentState?.validate() ??
                                          false)) {
                                        return;
                                      }

                                      context.read<RsvpCubit>().submit(
                                        RsvpSubmission(
                                          name: _nameController.text.trim(),
                                          email: _emailController.text.trim(),
                                          attendance: _attendance,
                                          guestCount: _guestCount,
                                          dietaryNotes: _dietaryController.text
                                              .trim(),
                                        ),
                                      );
                                    },
                              child: Text(
                                isSubmitting
                                    ? 'Enviando confirmación...'
                                    : 'Enviar confirmación',
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _GoogleFormsCard(
                      key: const ValueKey('google-rsvp-card'),
                      fallbackName: _nameController.text.trim(),
                      fallbackEmail: _emailController.text.trim(),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _GoogleFormsCard extends StatelessWidget {
  const _GoogleFormsCard({
    required super.key,
    required this.fallbackName,
    required this.fallbackEmail,
  });

  final String fallbackName;
  final String fallbackEmail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final prefilled = _googleFormLink(name: fallbackName, email: fallbackEmail);

    return Card(
      color: AppTheme.rose.withValues(alpha: 0.44),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Formulario externo de confirmación',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Úsalo si prefieres gestionar respuestas en Google Forms y Sheets. Podemos rellenar nombre y correo si están disponibles.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () => _openExternal(prefilled),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Abrir Google Form'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      _openExternal('https://docs.google.com/forms/u/0/'),
                  icon: const Icon(Icons.settings),
                  label: const Text('Administrar formulario'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VenueAndFaqSection extends StatelessWidget {
  const _VenueAndFaqSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 860;

        final venueCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lugar', style: textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('Rosewood Garden Estate, California'),
                const SizedBox(height: 8),
                const Text(
                  'El transporte sale a las 2:45 p. m. desde Downtown Grand Hotel.',
                ),
                const SizedBox(height: 14),
                FilledButton.tonalIcon(
                  onPressed: () => _openExternal(
                    'https://maps.google.com/?q=Rosewood+Garden+Estate',
                  ),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Abrir mapa'),
                ),
              ],
            ),
          ),
        );

        final faqCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Preguntas frecuentes',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Text(
                  '¿Puedo llevar acompañante? Sí, si está incluido en tu invitación.',
                ),
                SizedBox(height: 8),
                Text(
                  '¿El evento es al aire libre? La ceremonia es al aire libre; la recepción es en interior.',
                ),
                SizedBox(height: 8),
                Text(
                  '¿Qué debo vestir? Formal de jardín; se recomiendan tonos pastel.',
                ),
              ],
            ),
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ScrollReveal(from: _RevealFrom.left, child: venueCard),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ScrollReveal(from: _RevealFrom.right, child: faqCard),
              ),
            ],
          );
        }

        return Column(
          children: [
            _ScrollReveal(from: _RevealFrom.left, child: venueCard),
            const SizedBox(height: 14),
            _ScrollReveal(from: _RevealFrom.right, child: faqCard),
          ],
        );
      },
    );
  }
}

Future<void> _launchGoogleCalendar(DateTime weddingDate) async {
  final start = DateFormat("yyyyMMdd'T'HHmmss").format(weddingDate.toUtc());
  final end = DateFormat(
    "yyyyMMdd'T'HHmmss",
  ).format(weddingDate.add(const Duration(hours: 6)).toUtc());

  final url =
      'https://calendar.google.com/calendar/render?action=TEMPLATE&text=${Uri.encodeComponent('Boda de Edgar y Gabriela')}&dates=$start/$end&details=${Uri.encodeComponent('Acompañanos en nuestra celebración de boda')}&location=${Uri.encodeComponent('Rosewood Garden Estate')}';

  await _openExternal(url);
}

String _googleFormLink({required String name, required String email}) {
  final base = 'https://docs.google.com/forms/d/e/your-form-id/viewform';
  final prefilledName = Uri.encodeQueryComponent(name);
  final prefilledEmail = Uri.encodeQueryComponent(email);
  return '$base?usp=pp_url&entry.1111111111=$prefilledName&entry.2222222222=$prefilledEmail';
}

Future<void> _openExternal(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
