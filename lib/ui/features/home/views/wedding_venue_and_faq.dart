import 'package:flutter/material.dart';
import 'package:wedding_g_and_e/ui/core/garden/garden_card.dart';
import 'package:wedding_g_and_e/ui/core/garden/wildflower.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_motion.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_theme.dart';
import 'package:wedding_g_and_e/ui/features/home/views/components/scroll.dart';

class VenueAndFaqSection extends StatelessWidget {
  const VenueAndFaqSection({super.key, this.dressCodeKey});

  /// Sección del código de vestimenta, para el enlace desde la pregunta.
  final GlobalKey? dressCodeKey;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bodyStyle = textTheme.bodyLarge?.copyWith(fontSize: 17);

    final gratitudeCard = GardenCard(
      withBouquet: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GardenHeading(
            eyebrow: 'Con el corazón',
            title: 'Gracias por estar\n',
            accent: 'con nosotros',
          ),
          const SizedBox(height: 14),
          Text(
            'Lo más bonito de este día será compartirlo con las personas que queremos. Gracias por acompañarnos, por cada abrazo, cada sonrisa y por sumar tanta luz a este comienzo.',
            style: bodyStyle,
          ),
          const SizedBox(height: 14),
          Text(
            'Esperamos que disfruten cada momento, bailen mucho y se lleven un recuerdo tan feliz como el que ustedes nos regalan a nosotros.',
            style: bodyStyle,
          ),
          const SizedBox(height: 16),
          Text(
            'Con cariño, Edgar y Gabriela',
            style: AppTheme.script(fontSize: 34),
          ),
        ],
      ),
    );

    final faq = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GardenHeading(
          eyebrow: 'Lugar y dudas',
          title: 'Preguntas ',
          accent: 'frecuentes',
        ),
        const SizedBox(height: 14),
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(
                text: 'Tribus Privé',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text:
                    ' · Urbanización Mañongo, Valencia, frente al Conjunto Residencial Titanium Suites',
              ),
            ],
          ),
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        const _FaqTile(
          question: '¿Puedo llevar acompañante?',
          answer: [Text('Sí, si está incluido en tu invitación.')],
        ),
        const SizedBox(height: 12),
        const _FaqTile(
          question: '¿El evento es al aire libre?',
          answer: [
            Text('La ceremonia es al aire libre; la recepción es en interior.'),
          ],
        ),
        const SizedBox(height: 12),
        _FaqTile(
          question: '¿Qué debo vestir?',
          answer: [
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Jardín semi-formal',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: ', inspirado en la frescura de la naturaleza.',
                  ),
                ],
              ),
            ),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Ellas: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text:
                        'tonos pastel y telas fluidas. Evitar tacones de aguja por el césped.',
                  ),
                ],
              ),
            ),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Ellos: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(text: 'sastrería veraniega en tonos claros.'),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.lavender.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Te pedimos evitar el negro y los rojos intensos. El blanco está reservado para la novia.',
                style: TextStyle(color: AppTheme.ink),
              ),
            ),
            if (dressCodeKey != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    final target = dressCodeKey!.currentContext;
                    if (target != null) {
                      Scrollable.ensureVisible(
                        target,
                        duration: const Duration(milliseconds: 700),
                        curve: AppMotion.organic,
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.ink,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Ver colores sugeridos',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ),
          ],
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 860) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ScrollReveal(
                  from: RevealFrom.left,
                  child: gratitudeCard,
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: ScrollReveal(
                  from: RevealFrom.right,
                  delayMs: 150,
                  child: faq,
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            ScrollReveal(from: RevealFrom.left, child: gratitudeCard),
            const SizedBox(height: 28),
            ScrollReveal(from: RevealFrom.right, child: faq),
          ],
        );
      },
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
  });

  final String question;
  final List<Widget> answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.reduced(context)
        ? Duration.zero
        : const Duration(milliseconds: 450);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x4093A160)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            expanded: _open,
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                child: Row(
                  children: [
                    AnimatedRotation(
                      turns: _open ? 0.375 : 0,
                      duration: duration,
                      curve: AppMotion.sproutCurve,
                      child: const WildflowerIcon(Wildflower.leaf, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.question,
                        style: AppTheme.display(fontSize: 21),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: duration,
            curve: AppMotion.organic,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(52, 0, 18, 16),
                    child: DefaultTextStyle.merge(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.inkSoft,
                        fontSize: 15.5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final (i, line) in widget.answer.indexed) ...[
                            if (i > 0) const SizedBox(height: 6),
                            line,
                          ],
                        ],
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
