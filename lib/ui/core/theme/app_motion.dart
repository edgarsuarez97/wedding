import 'package:flutter/widgets.dart';

/// Duraciones y curvas compartidas por las animaciones de jardín.
class AppMotion {
  static const Duration reveal = Duration(milliseconds: 900);
  static const Duration heroText = Duration(milliseconds: 1100);
  static const Duration vineDraw = Duration(milliseconds: 1800);
  static const Duration sprout = Duration(milliseconds: 600);
  static const Duration bloom = Duration(milliseconds: 700);
  static const Duration countdownTick = Duration(milliseconds: 450);
  static const Duration petalBurst = Duration(milliseconds: 2200);
  static const Duration butterflyFlight = Duration(seconds: 11);
  static const Duration butterflyEvery = Duration(seconds: 26);
  static const Duration cornerSway = Duration(seconds: 6);

  static const Curve organic = Curves.easeOutCubic;
  static const Curve sproutCurve = Curves.easeOutBack;
  static const Curve gentle = Curves.easeInOutSine;

  /// Indica si el visitante pidió reducir el movimiento.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}
