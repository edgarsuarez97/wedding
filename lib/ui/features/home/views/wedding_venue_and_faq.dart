
import 'package:flutter/material.dart';
import 'package:wedding_g_and_e/ui/features/home/views/components/scroll.dart';
import 'package:wedding_g_and_e/ui/features/home/views/wedding_home_page.dart';

class VenueAndFaqSection extends StatelessWidget {
  const VenueAndFaqSection({super.key});

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
                  onPressed: () => openExternal(
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
                child: ScrollReveal(from: RevealFrom.left, child: venueCard),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ScrollReveal(from: RevealFrom.right, child: faqCard),
              ),
            ],
          );
        }

        return Column(
          children: [
            ScrollReveal(from: RevealFrom.left, child: venueCard),
            const SizedBox(height: 14),
            ScrollReveal(from: RevealFrom.right, child: faqCard),
          ],
        );
      },
    );
  }
}
