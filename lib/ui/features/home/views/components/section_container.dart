import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum SectionDecorationMode { none, softFloralCorners, vineGarden, roseFrame }



class SectionContainer extends StatelessWidget {
  const SectionContainer({super.key, 
    required this.background,
    required this.child,
    this.decorationMode = SectionDecorationMode.none,
  });

  final Color background;
  final Widget child;
  final SectionDecorationMode decorationMode;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(decoration: BoxDecoration(color: background)),
        ),
        ..._buildSectionOrnaments(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSectionOrnaments() {
    return switch (decorationMode) {
      SectionDecorationMode.none => const [],
      SectionDecorationMode.softFloralCorners => [
        const Positioned(
          top: -6,
          left: -6,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/floral_corner_watercolor.svg',
            size: 132,
            opacity: 0.58,
          ),
        ),
        const Positioned(
          top: -6,
          right: -6,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/floral_corner_watercolor.svg',
            size: 132,
            opacity: 0.58,
            quarterTurns: 1,
          ),
        ),
        const Positioned(
          bottom: -8,
          left: -6,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/floral_corner_watercolor.svg',
            size: 132,
            opacity: 0.58,
            quarterTurns: 3,
          ),
        ),
        const Positioned(
          bottom: -8,
          right: -6,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/floral_corner_watercolor.svg',
            size: 132,
            opacity: 0.58,
            quarterTurns: 2,
          ),
        ),
      ],
      SectionDecorationMode.vineGarden => [
        const Positioned(
          top: 10,
          bottom: 10,
          left: 0,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/vine_vertical_watercolor.svg',
            width: 120,
            opacity: 0.62,
          ),
        ),
        const Positioned(
          top: 10,
          bottom: 10,
          right: 0,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/vine_vertical_watercolor.svg',
            width: 120,
            opacity: 0.62,
            flipX: true,
          ),
        ),
      ],
      SectionDecorationMode.roseFrame => [
        const Positioned(
          top: -8,
          left: -8,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/floral_corner_watercolor.svg',
            size: 148,
            opacity: 0.66,
          ),
        ),
        const Positioned(
          top: -8,
          right: -8,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/floral_corner_watercolor.svg',
            size: 148,
            opacity: 0.66,
            quarterTurns: 1,
          ),
        ),
        const Positioned(
          bottom: -18,
          left: 18,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/vine_vertical_watercolor.svg',
            width: 96,
            opacity: 0.55,
            quarterTurns: 1,
          ),
        ),
        const Positioned(
          bottom: -18,
          right: 18,
          child: _SectionOrnament(
            assetPath: 'assets/illustrations/vine_vertical_watercolor.svg',
            width: 96,
            opacity: 0.55,
            quarterTurns: 3,
          ),
        ),
      ],
    };
  }
}



class _SectionOrnament extends StatelessWidget {
  const _SectionOrnament({
    required this.assetPath,
    this.size,
    this.width,
    this.opacity = 0.6,
    this.quarterTurns = 0,
    this.flipX = false,
  });

  final String assetPath;
  final double? size;
  final double? width;
  final double opacity;
  final int quarterTurns;
  final bool flipX;

  @override
  Widget build(BuildContext context) {
    final ornament = SizedBox(
      width: width ?? size,
      height: size,
      child: SvgPicture.asset(assetPath, fit: BoxFit.contain),
    );

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: RotatedBox(
          quarterTurns: quarterTurns,
          child: flipX
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(-1, 1, 1),
                  child: ornament,
                )
              : ornament,
        ),
      ),
    );
  }
}

