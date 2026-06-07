import 'package:flutter/material.dart';

enum SectionDecorationMode { none, softFloralCorners, vineGarden, roseFrame }

class SectionContainer extends StatelessWidget {
  const SectionContainer({
    super.key,
    required this.background,
    required this.child,
    this.decorationMode = SectionDecorationMode.none,
  });

  final Color background;
  final Widget child;
  final SectionDecorationMode decorationMode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: background),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: child,
          ),
        ),
      ),
    );
  }
}
