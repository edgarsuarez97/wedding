import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import 'viewport.dart';
import 'wildflower.dart';

/// Separador entre secciones: una guirnalda de flores silvestres en acuarela
/// que se despliega desde el centro hacia los lados al entrar en pantalla.
class GardenDivider extends StatefulWidget {
  const GardenDivider({super.key});

  @override
  State<GardenDivider> createState() => _GardenDividerState();
}

class _GardenDividerState extends State<GardenDivider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.vineDraw,
  );
  late final Animation<double> _reveal = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InViewTrigger(
      onEnter: () {
        if (!_controller.isCompleted) {
          _controller.forward();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: AspectRatio(
              aspectRatio: 656 / 220,
              child: AnimatedBuilder(
                animation: _reveal,
                builder: (context, child) => Opacity(
                  opacity: (_reveal.value * 2).clamp(0.0, 1.0),
                  child: ClipRect(
                    clipper: _CenterReveal(_reveal.value),
                    child: child,
                  ),
                ),
                child: const LayoutBuilder(builder: _garland),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _garland(BuildContext context, BoxConstraints constraints) =>
      WildflowerIcon(
        Wildflower.garland,
        width: constraints.maxWidth,
        height: constraints.maxHeight,
      );
}

/// Recorte que se abre desde el centro hacia los dos lados.
class _CenterReveal extends CustomClipper<Rect> {
  _CenterReveal(this.t);

  final double t;

  @override
  Rect getClip(Size size) => Rect.fromCenter(
    center: size.center(Offset.zero),
    width: size.width * (0.15 + 0.85 * t),
    height: size.height,
  );

  @override
  bool shouldReclip(_CenterReveal oldClipper) => oldClipper.t != t;
}
