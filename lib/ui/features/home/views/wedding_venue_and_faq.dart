import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wedding_g_and_e/ui/features/home/views/components/scroll.dart';

class VenueAndFaqSection extends StatelessWidget {
  const VenueAndFaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 860;

        final gratitudeCard = _BlendedCard(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gracias por estar con nosotros',
                  style: textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF211C18),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Lo más bonito de este día será compartirlo con las personas que queremos. Gracias por acompañarnos, por cada abrazo, cada sonrisa y por sumar tanta luz a este comienzo.',
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: const Color(0xFF2F2823),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Esperamos que disfruten cada momento, bailen mucho y se lleven un recuerdo tan feliz como el que ustedes nos regalan a nosotros.',
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: const Color(0xFF3E3630),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Con cariño, Edgar y Gabriela',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF211C18),
                  ),
                ),
              ],
            ),
          ),
        );

        final faqCard = _BlendedCard(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preguntas frecuentes',
                  style: textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF211C18),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '¿Puedo llevar acompañante? Sí, si está incluido en tu invitación.',
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: const Color(0xFF2F2823),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '¿El evento es al aire libre? La ceremonia es al aire libre; la recepción es en interior.',
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: const Color(0xFF2F2823),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '¿Qué debo vestir? Formal de jardín; se recomiendan tonos pastel.',
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: const Color(0xFF2F2823),
                  ),
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
                child: ScrollReveal(
                  from: RevealFrom.left,
                  child: gratitudeCard,
                ),
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
            ScrollReveal(from: RevealFrom.left, child: gratitudeCard),
            const SizedBox(height: 14),
            ScrollReveal(from: RevealFrom.right, child: faqCard),
          ],
        );
      },
    );
  }
}

class _BlendedCard extends StatelessWidget {
  const _BlendedCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withValues(alpha: 0.34),
            border: Border.all(color: Colors.white.withValues(alpha: 0.52)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5E5140).withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
