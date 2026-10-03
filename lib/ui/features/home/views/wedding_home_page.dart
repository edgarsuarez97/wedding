import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedding_g_and_e/ui/features/home/views/components/scroll.dart';
import 'package:wedding_g_and_e/ui/features/home/views/components/section_container.dart';
import 'package:wedding_g_and_e/ui/core/garden/garden_divider.dart';
import 'package:wedding_g_and_e/ui/core/garden/garden_ornaments.dart';
import 'package:wedding_g_and_e/ui/features/home/views/wedding_counter.dart';
import 'package:wedding_g_and_e/ui/features/home/views/wedding_dress_code.dart';
import 'package:wedding_g_and_e/ui/features/home/views/wedding_gallery.dart';
import 'package:wedding_g_and_e/ui/features/home/views/wedding_itinerary.dart';
import 'package:wedding_g_and_e/ui/features/home/views/wedding_rsvp.dart';
import 'package:wedding_g_and_e/ui/features/home/views/wedding_venue_and_faq.dart';
import 'package:wedding_g_and_e/ui/features/home/views/wedding_video.dart';

import '../../../../domain/models/wedding_content.dart';
import '../../../core/theme/app_theme.dart';

import '../cubit/wedding_content_cubit.dart';

class WeddingHomePage extends StatelessWidget {
  const WeddingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeddingContentCubit, WeddingContentState>(
      key: const ValueKey('wedding-experience-state'),
      builder: (context, state) {
        return switch (state.status) {
          WeddingContentStatus.success => WeddingExperience(
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

class WeddingExperience extends StatefulWidget {
  const WeddingExperience({super.key, required this.content});

  final WeddingContent content;

  @override
  State<WeddingExperience> createState() => _WeddingExperienceState();
}

class _WeddingExperienceState extends State<WeddingExperience> {
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

  final _dressCodeKey = GlobalKey();

  Widget _pair(bool isDesktop, Widget first, Widget second) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ScrollReveal(from: RevealFrom.left, child: first),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: ScrollReveal(
              from: RevealFrom.right,
              delayMs: 150,
              child: second,
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        ScrollReveal(from: RevealFrom.left, child: first),
        const SizedBox(height: 28),
        ScrollReveal(from: RevealFrom.right, child: second),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 920;

              return SingleChildScrollView(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppTheme.paper,
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/illustrations/paper_texture.jpg',
                      ),
                      fit: BoxFit.none,
                      repeat: ImageRepeat.repeat,
                      opacity: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      HeroSection(
                        weddingDate: widget.content.weddingDate,
                        heroImageUrl: widget.content.heroImageUrl,
                        coupleNames: widget.content.coupleNames,
                        isMusicPlaying: _isHeroMusicPlaying,
                        isMusicBusy: _isPreparingAudio,
                        onToggleMusic: _toggleHeroMusic,
                      ),
                      HeroEventDetailsSection(
                        weddingDate: widget.content.weddingDate,
                      ),
                      const GardenDivider(),

                      // Historia e itinerario
                      SectionContainer(
                        background: Colors.transparent,
                        child: _pair(
                          isDesktop,
                          StorySection(story: widget.content.story),
                          ScheduleSection(schedule: widget.content.schedule),
                        ),
                      ),
                      const GardenDivider(),

                      // Código de vestimenta
                      SectionContainer(
                        key: _dressCodeKey,
                        background: Colors.transparent,
                        child: const ScrollReveal(child: DressCodeSection()),
                      ),
                      const GardenDivider(),

                      // Fotos y video
                      SectionContainer(
                        background: Colors.transparent,
                        child: _pair(
                          isDesktop,
                          GallerySection(
                            images: widget.content.galleryImageUrls,
                          ),
                          VideoSection(videoUrl: widget.content.videoUrl),
                        ),
                      ),
                      const GardenDivider(),

                      // Confirmación de asistencia
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: SectionContainer(
                          background: Colors.transparent,
                          child: ScrollReveal(child: RsvpSection()),
                        ),
                      ),
                      const GardenDivider(),

                      // Agradecimiento, lugar y preguntas
                      SectionContainer(
                        background: Colors.transparent,
                        child: VenueAndFaqSection(dressCodeKey: _dressCodeKey),
                      ),
                      const _Footer(),
                    ],
                  ),
                ),
              );
            },
          ),
          const Positioned.fill(child: GardenButterfly()),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.lavenderInk),
            ),
            child: Text(
              'G&E',
              style: AppTheme.display(
                fontSize: 24,
                color: AppTheme.lavenderInk,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '28 · 08 · 2027 · VALENCIA',
            style: AppTheme.eyebrow(color: AppTheme.inkSoft),
          ),
        ],
      ),
    );
  }
}

Future<void> launchGoogleCalendar(DateTime weddingDate) async {
  final start = DateFormat("yyyyMMdd'T'HHmmss").format(weddingDate.toUtc());
  final end = DateFormat(
    "yyyyMMdd'T'HHmmss",
  ).format(weddingDate.add(const Duration(hours: 6)).toUtc());

  final url =
      'https://calendar.google.com/calendar/render?action=TEMPLATE&text=${Uri.encodeComponent('Boda de Edgar y Gabriela')}&dates=$start/$end&details=${Uri.encodeComponent('Acompañanos en nuestra celebración de boda')}&location=${Uri.encodeComponent('Tribus Privé Urbanización Mañongo Valencia, frente al Conjunto Residencial Titanium Suites')}';

  await openExternal(url);
}

Future<void> openExternal(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
