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
              final progress = AppMotion.reduced(context) ? 1.0 : rawProgress;
              return Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 56,
                    child: CustomPaint(painter: _StemPainter(progress)),
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
                              open: progress >= (i + 0.15) / schedule.length,
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
    required this.open,
  });

  final ScheduleItem item;
  final IconData icon;
  final Wildflower flower;
  final bool open;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -58,
          top: 8,
          child: AnimatedScale(
            scale: open ? 1 : 0.25,
            duration: AppMotion.bloom,
            curve: AppMotion.sproutCurve,
            child: AnimatedRotation(
              turns: open ? 0 : -0.15,
              duration: AppMotion.bloom,
              curve: AppMotion.organic,
              child: WildflowerIcon(flower, size: 44),
            ),
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

class _StemPainter extends CustomPainter {
  _StemPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
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
      oldDelegate.progress != progress;
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
