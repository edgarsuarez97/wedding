import 'package:flutter/widgets.dart';

/// Escucha el scroll de la página y avisa dónde está [child] respecto a la
/// ventana. Sirve para animaciones que dependen del scroll en ambos sentidos.
class ViewportProgressBuilder extends StatefulWidget {
  const ViewportProgressBuilder({
    super.key,
    required this.builder,
    this.anchor = 0.75,
    this.child,
  });

  /// Recibe el progreso 0..1: cuánto del widget ya pasó por la línea [anchor]
  /// de la ventana (0.75 = a tres cuartos de alto).
  final Widget Function(BuildContext context, double progress, Widget? child)
  builder;
  final double anchor;
  final Widget? child;

  @override
  State<ViewportProgressBuilder> createState() =>
      _ViewportProgressBuilderState();
}

class _ViewportProgressBuilderState extends State<ViewportProgressBuilder> {
  ScrollPosition? _position;
  double _progress = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Scrollable.maybeOf(context)?.position;
    if (next != _position) {
      _position?.removeListener(_update);
      _position = next;
      _position?.addListener(_update);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void dispose() {
    _position?.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (!mounted) {
      return;
    }
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) {
      return;
    }
    final viewport = MediaQuery.sizeOf(context).height;
    final top = box.localToGlobal(Offset.zero).dy;
    final height = box.size.height == 0 ? 1.0 : box.size.height;
    final progress = ((viewport * widget.anchor - top) / height).clamp(
      0.0,
      1.0,
    );
    if ((progress - _progress).abs() > 0.001) {
      setState(() => _progress = progress);
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _progress, widget.child);
}

/// Llama a [onEnter] una sola vez, cuando el widget entra en la ventana.
class InViewTrigger extends StatefulWidget {
  const InViewTrigger({
    super.key,
    required this.child,
    required this.onEnter,
    this.threshold = 0.9,
  });

  final Widget child;
  final VoidCallback onEnter;

  /// Fracción del alto de la ventana a partir de la cual cuenta como visible.
  final double threshold;

  @override
  State<InViewTrigger> createState() => _InViewTriggerState();
}

class _InViewTriggerState extends State<InViewTrigger> {
  ScrollPosition? _position;
  bool _fired = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Scrollable.maybeOf(context)?.position;
    if (next != _position) {
      _position?.removeListener(_check);
      _position = next;
      _position?.addListener(_check);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    super.dispose();
  }

  void _check() {
    if (_fired || !mounted) {
      return;
    }
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) {
      return;
    }
    final top = box.localToGlobal(Offset.zero).dy;
    if (top < MediaQuery.sizeOf(context).height * widget.threshold) {
      _fired = true;
      _position?.removeListener(_check);
      widget.onEnter();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
