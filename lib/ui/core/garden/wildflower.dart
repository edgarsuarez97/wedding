import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Flores silvestres dibujadas para el sitio (assets/illustrations/wildflowers).
enum Wildflower {
  bellflower('bellflower'),
  lily('lily'),
  orchid('orchid'),
  sweetPea('sweet_pea'),
  forgetMeNot('forget_me_not'),
  buttercup('buttercup'),
  delphinium('delphinium'),
  babysBreath('babys_breath'),
  leaf('leaf');

  const Wildflower(this.file);

  final String file;

  String get asset => 'assets/illustrations/wildflowers/$file.svg';
}

class WildflowerIcon extends StatelessWidget {
  const WildflowerIcon(this.flower, {super.key, this.size = 40});

  final Wildflower flower;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      flower.asset,
      width: size,
      height: size,
      excludeFromSemantics: true,
    );
  }
}
