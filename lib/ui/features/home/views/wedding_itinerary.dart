import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wedding_g_and_e/domain/models/schedule_item.dart';
import 'package:wedding_g_and_e/ui/core/garden/garden_card.dart';
import 'package:wedding_g_and_e/ui/core/garden/viewport.dart';
import 'package:wedding_g_and_e/ui/core/garden/wildflower.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_motion.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_theme.dart';

class StorySection extends StatelessWidget {
  const StorySection({super.key, required this.story});

  final String story;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GardenCard(
      withBouquet: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GardenHeading(
            eyebrow: 'Nuestra historia',
            title: 'Una cafetería,\n',
            accent: 'una promesa',
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              story,
              style: textTheme.bodyLarge?.copyWith(fontSize: 18),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Gabita & Edgar',
            style: AppTheme.script(fontSize: 34, color: AppTheme.roseInk),
          ),
        ],
      ),
    );
  }
}

class ScheduleSection extends StatelessWidget {
  const ScheduleSection({super.key, required this.schedule});

  final List<ScheduleItem> schedule;

  static const _flowers = [
    Wildflower.forgetMeNot,
    Wildflower.orchid,
    Wildflower.buttercup,
    Wildflower.lily,
    Wildflower.bellflower,
  ];

  @override
  Widget build(BuildContext context) {
    return GardenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GardenHeading(
            eyebrow: 'Itinerario de la boda',
            title: 'El día, ',
            accent: 'hora a hora',
          ),
          const SizedBox(height: 22),
          // El tallo crece con el scroll y se recoge al volver a subir.
          ViewportProgressBuilder(
            builder: (context, rawProgress, _) {
              final reduced = AppMotion.reduced(context);
              final ValueListenable<double> progress = reduced
                  ? const _Full()
                  : rawProgress;
              return Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 56,
                    child: RepaintBoundary(
                      child: CustomPaint(painter: _StemPainter(progress)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 64),
                    child: Column(
                      children: [
                        for (final (i, item) in schedule.indexed)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i == schedule.length - 1 ? 0 : 20,
                            ),
                            child: _TimelineItem(
                              item: item,
                              icon: _scheduleIcon(item.title, i),
                              flower: _flowers[i % _flowers.length],
                              progress: progress,
                              threshold: (i + 0.15) / schedule.length,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.item,
    required this.icon,
    required this.flower,
    required this.progress,
    required this.threshold,
  });

  final ScheduleItem item;
  final IconData icon;
  final Wildflower flower;
  final ValueListenable<double> progress;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -58,
          top: 8,
          child: _Bloom(
            progress: progress,
            threshold: threshold,
            child: WildflowerIcon(flower, size: 44),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x2E93A160)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.timeLabel,
                      style: AppTheme.eyebrow().copyWith(letterSpacing: 1.8),
                    ),
                    const SizedBox(height: 4),
                    Text(item.title, style: AppTheme.display(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppTheme.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.mint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 21, color: AppTheme.ink),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Abre la flor cuando el tallo llega a [threshold] y la cierra al volver.
/// Solo se reconstruye cuando cruza el umbral, no en cada pixel de scroll.
class _Bloom extends StatefulWidget {
  const _Bloom({
    required this.progress,
    required this.threshold,
    required this.child,
  });

  final ValueListenable<double> progress;
  final double threshold;
  final Widget child;

  @override
  State<_Bloom> createState() => _BloomState();
}

class _BloomState extends State<_Bloom> {
  late bool _open = widget.progress.value >= widget.threshold;

  @override
  void initState() {
    super.initState();
    widget.progress.addListener(_onProgress);
  }

  @override
  void didUpdateWidget(covariant _Bloom oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      oldWidget.progress.removeListener(_onProgress);
      widget.progress.addListener(_onProgress);
      _onProgress();
    }
  }

  @override
  void dispose() {
    widget.progress.removeListener(_onProgress);
    super.dispose();
  }

  void _onProgress() {
    final open = widget.progress.value >= widget.threshold;
    if (open != _open) {
      setState(() => _open = open);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedScale(
        scale: _open ? 1 : 0.25,
        duration: AppMotion.bloom,
        curve: AppMotion.sproutCurve,
        child: AnimatedRotation(
          turns: _open ? 0 : -0.15,
          duration: AppMotion.bloom,
          curve: AppMotion.organic,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Progreso fijo en 1 para cuando se pide reducir el movimiento.
class _Full implements ValueListenable<double> {
  const _Full();

  @override
  double get value => 1;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

class _StemPainter extends CustomPainter {
  _StemPainter(this.listenable) : super(repaint: listenable);

  final ValueListenable<double> listenable;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = listenable.value;
    if (progress <= 0) {
      return;
    }
    final path = Path()..moveTo(28, 0);
    const segments = 6;
    final step = size.height / segments;
    for (var k = 1; k <= segments; k++) {
      final sway = k.isOdd ? 18.0 : 38.0;
      path.quadraticBezierTo(sway, step * k - step / 2, 28, step * k);
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.stem;
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StemPainter oldDelegate) =>
      oldDelegate.listenable != listenable;
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
    return Icons.local_drink_outlined;
  }

  return switch (index % 4) {
    0 => Icons.auto_awesome_outlined,
    1 => Icons.local_bar_outlined,
    2 => Icons.restaurant_menu_outlined,
    _ => Icons.nightlife_outlined,
  };
}
