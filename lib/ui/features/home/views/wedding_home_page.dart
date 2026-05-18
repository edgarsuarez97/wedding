import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../../domain/models/rsvp_submission.dart';
import '../../../../domain/models/schedule_item.dart';
import '../../../../domain/models/wedding_content.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/rsvp_cubit.dart';
import '../cubit/wedding_content_cubit.dart';

class WeddingHomePage extends StatelessWidget {
  const WeddingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvitationCubit, bool>(
      builder: (context, isOpen) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: isOpen
              ? BlocBuilder<WeddingContentCubit, WeddingContentState>(
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
                                  'Unable to load wedding details.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: () => context
                                      .read<WeddingContentCubit>()
                                      .load(),
                                  child: const Text('Try again'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _ => const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
                    };
                  },
                )
              : _InvitationGate(
                  key: const ValueKey('invitation-gate'),
                  onOpen: () =>
                      context.read<InvitationCubit>().openInvitation(),
                ),
        );
      },
    );
  }
}

class _InvitationGate extends StatelessWidget {
  const _InvitationGate({required super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppTheme.rose, AppTheme.mint],
          ),
        ),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.blush,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Color(0xFF7E6570),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('You are invited', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Edgar & Gabriela',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Saturday, August 28, 2027',
                      style: textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF5F646A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      key: const ValueKey('open-invitation-button'),
                      onPressed: onOpen,
                      icon: const Icon(Icons.mail_outline),
                      label: const Text('Open Invitation'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
  bool _didPrecache = false;

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
                ),
                _SectionContainer(
                  background: AppTheme.paper,
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _StorySection(story: widget.content.story),
                            ),
                            SizedBox(width: 28),
                            Expanded(
                              child: _ScheduleSection(
                                schedule: widget.content.schedule,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _StorySection(story: widget.content.story),
                            SizedBox(height: 28),
                            _ScheduleSection(schedule: widget.content.schedule),
                          ],
                        ),
                ),
                _SectionContainer(
                  background: const Color(0xFFFFFCFD),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _GallerySection(
                                images: widget.content.galleryImageUrls,
                              ),
                            ),
                            SizedBox(width: 28),
                            Expanded(
                              child: _VideoSection(
                                videoUrl: widget.content.videoUrl,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _GallerySection(
                              images: widget.content.galleryImageUrls,
                            ),
                            SizedBox(height: 28),
                            _VideoSection(videoUrl: widget.content.videoUrl),
                          ],
                        ),
                ),
                const _SectionContainer(
                  background: Colors.white,
                  child: _RsvpSection(),
                ),
                const _SectionContainer(
                  background: Color(0xFFFFFAFE),
                  child: _VenueAndFaqSection(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({required this.background, required this.child});

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: child,
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
  });

  final DateTime weddingDate;
  final String heroImageUrl;
  final String coupleNames;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('EEEE, MMMM d, y').format(weddingDate);
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
                          label: const Text('Add to Google Calendar'),
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
                          label: const Text('View Venue'),
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

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 24,
        vertical: isCompact ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(99),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CountdownMetric(value: '$days', label: 'days', compact: isCompact),
            SizedBox(width: isCompact ? 5 : 8),
            _CountdownMetric(
              value: hours.toString().padLeft(2, '0'),
              label: 'hrs',
              compact: isCompact,
            ),
            SizedBox(width: isCompact ? 5 : 8),
            _CountdownMetric(
              value: minutes.toString().padLeft(2, '0'),
              label: 'min',
              compact: isCompact,
            ),
            SizedBox(width: isCompact ? 5 : 8),
            _CountdownMetric(
              value: seconds.toString().padLeft(2, '0'),
              label: 'sec',
              emphasize: true,
              pulseTick: seconds,
              compact: isCompact,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownMetric extends StatelessWidget {
  const _CountdownMetric({
    required this.value,
    required this.label,
    this.emphasize = false,
    this.pulseTick = 0,
    this.compact = false,
  });

  final String value;
  final String label;
  final bool emphasize;
  final int pulseTick;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnimatedCountdownValue(value: value, compact: compact),
        SizedBox(width: compact ? 4 : 6),
        Text(
          label,
          style: TextStyle(
            fontSize: compact ? 11 : 13,
            fontWeight: FontWeight.w600,
            color: emphasize
                ? const Color(0xFF6A4258)
                : const Color(0xFF5D6973),
          ),
        ),
      ],
    );

    if (!emphasize) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 7 : 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      );
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(pulseTick),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeOut,
      builder: (context, animation, _) {
        final glow = (1 - animation) * 0.26;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 7 : 8,
          ),
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFFFBEFF4),
              const Color(0xFFF7FAFB),
              animation,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE19BB7).withValues(alpha: glow),
                blurRadius: 12 + (8 * (1 - animation)),
                spreadRadius: 1.5,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

class _AnimatedCountdownValue extends StatelessWidget {
  const _AnimatedCountdownValue({required this.value, required this.compact});

  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        height: compact ? 22 : 26,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < value.length; index++)
              _AnimatedCountdownDigit(
                digit: value[index],
                index: index,
                totalLength: value.length,
                compact: compact,
              ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCountdownDigit extends StatelessWidget {
  const _AnimatedCountdownDigit({
    required this.digit,
    required this.index,
    required this.totalLength,
    required this.compact,
  });

  final String digit;
  final int index;
  final int totalLength;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 300 + (index * 90));
    return SizedBox(
      width: compact
          ? (totalLength >= 3 ? 11 : 10)
          : (totalLength >= 3 ? 13 : 12),
      height: compact ? 22 : 26,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: Offset(0, 0.72 + (index * 0.08)),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        child: Text(
          digit,
          key: ValueKey<String>('$index-$digit'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            height: 1,
            fontWeight: FontWeight.w700,
            color: Color(0xFF35414A),
          ),
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
        Text('Our Story', style: textTheme.headlineMedium),
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
                  'Dress code: Garden Formal in soft colors. Reception continues into a moonlight dance party.',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wedding Schedule', style: textTheme.headlineMedium),
        const SizedBox(height: 16),
        ...schedule.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 86,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lime,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      item.timeLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: textTheme.titleLarge?.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          style: textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF5D6369),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GallerySection extends StatelessWidget {
  const _GallerySection({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        final crossAxisCount = isWide ? 2 : 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photo Highlights',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.18,
              ),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
                );
              },
            ),
          ],
        );
      },
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
        Text('A Moment In Motion', style: textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(
          'A short teaser for the celebration vibe. Replace with your own pre-wedding reel anytime.',
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
                            label: const Text('Play video'),
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
  String _attendance = 'Joyfully attending';
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
            Text('RSVP', style: textTheme.displaySmall?.copyWith(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Choose your preferred RSVP path. Native form keeps guests inside your site. Google Forms is perfect for quick external collection.',
              style: textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF5B6167),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('Native Flutter RSVP'),
                  selected: state.mode == RsvpMode.native,
                  onSelected: (_) =>
                      context.read<RsvpCubit>().setMode(RsvpMode.native),
                ),
                ChoiceChip(
                  label: const Text('Google Forms RSVP'),
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
                                          labelText: 'Full name',
                                        ),
                                        validator: (value) =>
                                            (value == null ||
                                                value.trim().isEmpty)
                                            ? 'Please enter your name'
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _emailController,
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                        ),
                                        validator: (value) =>
                                            (value == null ||
                                                !value.contains('@'))
                                            ? 'Enter a valid email'
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
                                      labelText: 'Full name',
                                    ),
                                    validator: (value) =>
                                        (value == null || value.trim().isEmpty)
                                        ? 'Please enter your name'
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                    ),
                                    validator: (value) =>
                                        (value == null || !value.contains('@'))
                                        ? 'Enter a valid email'
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
                                value: 'Joyfully attending',
                                child: Text('Joyfully attending'),
                              ),
                              DropdownMenuItem(
                                value: 'Regretfully declines',
                                child: Text('Regretfully declines'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _attendance = value);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Attendance',
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
                                  '${index + 1} guest${index == 0 ? '' : 's'}',
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _guestCount = value);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Party size',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dietaryController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Dietary notes',
                              hintText:
                                  'Allergies, vegetarian, gluten-free, etc.',
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
                                    ? 'Sending RSVP...'
                                    : 'Submit RSVP',
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
            Text('External RSVP Form', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Use this when you prefer managing responses in Google Forms and Sheets. We can prefill name/email if available.',
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
                  label: const Text('Open Google Form'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      _openExternal('https://docs.google.com/forms/u/0/'),
                  icon: const Icon(Icons.settings),
                  label: const Text('Manage Form'),
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
                Text('Venue', style: textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('Rosewood Garden Estate, California'),
                const SizedBox(height: 8),
                const Text(
                  'Shuttle departs at 2:45 PM from Downtown Grand Hotel.',
                ),
                const SizedBox(height: 14),
                FilledButton.tonalIcon(
                  onPressed: () => _openExternal(
                    'https://maps.google.com/?q=Rosewood+Garden+Estate',
                  ),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Open Map'),
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
                  'FAQ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Text(
                  'Can I bring a plus one? Yes, if included in your invitation.',
                ),
                SizedBox(height: 8),
                Text(
                  'Is the event outdoors? Ceremony is outdoors; reception is indoors.',
                ),
                SizedBox(height: 8),
                Text(
                  'What should I wear? Garden formal, pastel-friendly encouraged.',
                ),
              ],
            ),
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: venueCard),
              const SizedBox(width: 16),
              Expanded(child: faqCard),
            ],
          );
        }

        return Column(
          children: [venueCard, const SizedBox(height: 14), faqCard],
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
      'https://calendar.google.com/calendar/render?action=TEMPLATE&text=${Uri.encodeComponent('Edgar & Gabriela Wedding')}&dates=$start/$end&details=${Uri.encodeComponent('Join us for our wedding celebration!')}&location=${Uri.encodeComponent('Rosewood Garden Estate')}';

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
