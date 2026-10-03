import 'package:flutter/material.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_motion.dart';

enum RevealFrom { left, right }

class ScrollReveal extends StatefulWidget {
  const ScrollReveal({
    super.key,
    required this.child,
    this.from = RevealFrom.left,
    this.delayMs = 0,
  });

  final Widget child;
  final RevealFrom from;
  final int delayMs;

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> {
  ScrollPosition? _position;
  bool _revealed = false;
  bool _revealScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion && !_revealed) {
      _revealed = true;
      return;
    }

    final nextPosition = Scrollable.maybeOf(context)?.position;
    if (_position == nextPosition) {
      return;
    }

    _position?.removeListener(_checkVisibility);
    _position = nextPosition;
    _position?.addListener(_checkVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    _position?.removeListener(_checkVisibility);
    super.dispose();
  }

  void _checkVisibility() {
    if (_revealed || _revealScheduled || !mounted) {
      return;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) {
      return;
    }

    final viewportHeight = MediaQuery.sizeOf(context).height;
    final top = renderObject.localToGlobal(Offset.zero).dy;
    final bottom = top + renderObject.size.height;

    final visibleTop = top.clamp(0.0, viewportHeight).toDouble();
    final visibleBottom = bottom.clamp(0.0, viewportHeight).toDouble();
    final visibleHeight = visibleBottom - visibleTop;
    final shouldReveal =
        visibleHeight >= (renderObject.size.height * 0.18) ||
        top <= viewportHeight * 0.84;

    if (!shouldReveal) {
      return;
    }

    if (widget.delayMs == 0) {
      setState(() => _revealed = true);
      return;
    }

    _revealScheduled = true;
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) {
        return;
      }
      setState(() => _revealed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Aparición "en flor": sube, se endereza y se asienta.
    final tilt = widget.from == RevealFrom.left ? -0.018 : 0.018;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: _revealed ? 1 : 0),
      duration: AppMotion.reveal,
      curve: AppMotion.organic,
      child: widget.child,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 26 * (1 - t)),
            child: Transform.rotate(
              angle: tilt * (1 - t),
              child: Transform.scale(scale: 0.96 + 0.04 * t, child: child),
            ),
          ),
        );
      },
    );
  }
}
