import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wedding_g_and_e/ui/core/garden/garden_card.dart';
import 'package:wedding_g_and_e/ui/core/garden/wildflower.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_theme.dart';

/// Código de vestimenta: colores sugeridos, indicaciones para ellas y ellos,
/// y colores a evitar.
class DressCodeSection extends StatelessWidget {
  const DressCodeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final wide = MediaQuery.sizeOf(context).width >= 720;

    final guides = [
      const _GuideCard(
        title: 'Ellas',
        text:
            'Tonos pastel y telas fluidas. Evitar tacones de aguja por el césped.',
        figure: _Figure.dress,
      ),
      const _GuideCard(
        title: 'Ellos',
        text: 'Sastrería veraniega en tonos claros.',
        figure: _Figure.suit,
      ),
    ];

    return Column(
      children: [
        const GardenHeading(
          eyebrow: 'Código de vestimenta',
          title: 'Jardín ',
          accent: 'semi-formal',
          center: true,
        ),
        const SizedBox(height: 12),
        Text(
          'Te sugerimos inspirarte en la frescura de la naturaleza.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: AppTheme.inkSoft),
        ),
        const SizedBox(height: 40),
        Text('COLORES SUGERIDOS', style: AppTheme.eyebrow()),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 22,
          children: [
            for (final swatch in AppTheme.palette)
              _Swatch(color: swatch.color, name: swatch.name, size: 96),
          ],
        ),
        const SizedBox(height: 40),
        if (wide)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: guides[0]),
                const SizedBox(width: 20),
                Expanded(child: guides[1]),
              ],
            ),
          )
        else
          Column(children: [guides[0], const SizedBox(height: 16), guides[1]]),
        const SizedBox(height: 40),
        Text('POR FAVOR, EVITAR', style: AppTheme.eyebrow()),
        const SizedBox(height: 20),
        const Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 22,
          children: [
            _Swatch(
              color: Color(0xFF1F1F1F),
              name: 'Negro',
              size: 72,
              crossed: true,
            ),
            _Swatch(
              color: Color(0xFFC21A2C),
              name: 'Rojos intensos',
              size: 72,
              crossed: true,
            ),
            _Swatch(
              color: Colors.white,
              name: 'Blanco',
              note: 'Reservado para la novia',
              size: 72,
              crossed: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.name,
    required this.size,
    this.note,
    this.crossed = false,
  });

  final Color color;
  final String name;
  final String? note;
  final double size;
  final bool crossed;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final diameter = compact ? size * 0.8 : size;
    return SizedBox(
      width: compact ? 108 : 150,
      child: Column(
        children: [
          SizedBox(
            width: diameter,
            height: diameter,
            child: CustomPaint(painter: _SwatchPainter(color, crossed)),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: AppTheme.display(fontSize: compact ? 17 : 19),
          ),
          if (note != null)
            Text(
              note!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.inkSoft),
            ),
        ],
      ),
    );
  }
}

class _SwatchPainter extends CustomPainter {
  _SwatchPainter(this.color, this.crossed);

  final Color color;
  final bool crossed;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    canvas
      ..drawCircle(
        center.translate(0, 4),
        r * 0.94,
        Paint()
          ..color = const Color(0x2234392F)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      ..drawCircle(center, r, Paint()..color = color)
      ..drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0x14000000),
      );
    if (crossed) {
      final d = Offset(math.cos(math.pi / 4), -math.sin(math.pi / 4)) * (r + 6);
      canvas.drawLine(
        center - d,
        center + d,
        Paint()
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = AppTheme.roseInk,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SwatchPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.crossed != crossed;
}

enum _Figure { dress, suit }

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.title,
    required this.text,
    required this.figure,
  });

  final String title;
  final String text;
  final _Figure figure;

  @override
  Widget build(BuildContext context) {
    return GardenCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _FigurePainter(figure)),
                ),
                Positioned(
                  left: figure == _Figure.dress ? 24 : 40,
                  top: figure == _Figure.dress ? 14 : 12,
                  child: WildflowerIcon(
                    figure == _Figure.dress
                        ? Wildflower.forgetMeNot
                        : Wildflower.buttercup,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.display(fontSize: 26)),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppTheme.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FigurePainter extends CustomPainter {
  _FigurePainter(this.figure);

  final _Figure figure;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 64);
    final path = Path();
    if (figure == _Figure.dress) {
      path
        ..moveTo(25, 6)
        ..lineTo(22, 2)
        ..moveTo(39, 6)
        ..lineTo(42, 2)
        ..moveTo(24, 6)
        ..cubicTo(28, 10, 36, 10, 40, 6)
        ..lineTo(38, 22)
        ..cubicTo(44, 32, 50, 46, 54, 60)
        ..cubicTo(40, 63, 24, 63, 10, 60)
        ..cubicTo(14, 46, 20, 32, 26, 22)
        ..close()
        ..moveTo(26, 22)
        ..cubicTo(30, 24, 34, 24, 38, 22);
    } else {
      path
        ..moveTo(22, 4)
        ..lineTo(32, 18)
        ..lineTo(42, 4)
        ..moveTo(22, 4)
        ..lineTo(12, 10)
        ..lineTo(10, 60)
        ..lineTo(28, 60)
        ..lineTo(32, 18)
        ..lineTo(36, 60)
        ..lineTo(54, 60)
        ..lineTo(52, 10)
        ..lineTo(42, 4)
        ..moveTo(18, 30)
        ..lineTo(26, 30)
        ..moveTo(28, 60)
        ..lineTo(32, 50)
        ..lineTo(36, 60);
    }
    canvas
      ..drawPath(path, Paint()..color = const Color(0x59C9C1E3))
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..color = AppTheme.ink,
      );
  }

  @override
  bool shouldRepaint(covariant _FigurePainter oldDelegate) =>
      oldDelegate.figure != figure;
}
