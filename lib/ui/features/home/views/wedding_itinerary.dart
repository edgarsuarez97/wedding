import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wedding_g_and_e/domain/models/schedule_item.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_theme.dart';

class StorySection extends StatelessWidget {
  const StorySection({super.key, required this.story});

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

class ScheduleSection extends StatelessWidget {
  const ScheduleSection({super.key, required this.schedule});

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
                isCompact ? 28 : 34,
                isCompact ? 8 : 18,
                isCompact ? 28 : 34,
              ),
              child: _GlassPanel(
                borderRadius: 26,
                padding: EdgeInsets.fromLTRB(
                  isCompact ? 8 : 18,
                  isCompact ? 28 : 34,
                  isCompact ? 8 : 18,
                  isCompact ? 28 : 34,
                ),
                child: Stack(
                  children: [
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

class _TimelineEventCard extends StatelessWidget {
  const _TimelineEventCard({required this.item, required this.alignRight});

  final ScheduleItem item;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: _GlassPanel(
        borderRadius: 16,
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    required this.borderRadius,
    this.padding,
    this.constraints,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          constraints: constraints,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white.withValues(alpha: 0.30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A5943).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
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
