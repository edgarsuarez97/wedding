import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_motion.dart';

/// En la web, Flutter mueve la página a saltos de unos 100 px por cada
/// "clic" de la rueda del ratón. Este widget, puesto dentro del scroll,
/// intercepta esos eventos y desliza la página hasta el destino con una
/// curva suave. El arrastre táctil y los trackpads no se tocan: ya son
/// continuos.
class SmoothWheelScroll extends StatefulWidget {
  const SmoothWheelScroll({super.key, required this.child});

  final Widget child;

  @override
  State<SmoothWheelScroll> createState() => _SmoothWheelScrollState();
}

class _SmoothWheelScrollState extends State<SmoothWheelScroll> {
  double? _target;

  void _onSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent ||
        event.kind == PointerDeviceKind.trackpad ||
        event.scrollDelta.dy == 0 ||
        AppMotion.reduced(context)) {
      return;
    }
    final position = Scrollable.maybeOf(context)?.position;
    if (position == null) {
      return;
    }
    // Registrarse aquí, más adentro que el Scrollable, hace que este
    // manejador gane y el Scrollable no aplique el salto.
    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      final scroll = event as PointerScrollEvent;
      // Si ya va deslizándose, el siguiente clic suma al destino pendiente.
      final from = _target ?? position.pixels;
      final target = (from + scroll.scrollDelta.dy).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if (target == position.pixels) {
        return;
      }
      _target = target;
      position
          .animateTo(
            target,
            duration: AppMotion.wheelScroll,
            curve: AppMotion.wheelCurve,
          )
          .whenComplete(() {
            if (_target == target) {
              _target = null;
            }
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(onPointerSignal: _onSignal, child: widget.child);
  }
}
