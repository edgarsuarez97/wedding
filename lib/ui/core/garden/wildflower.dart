import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Flores silvestres en acuarela del sitio
/// (assets/illustrations/watercolor). Cada imagen viene recortada al borde
/// de la ilustración, con el tallo hacia abajo.
enum Wildflower {
  buttercupSprig('buttercup_sprig'),
  violets('violets'),
  coralCosmos('coral_cosmos'),
  pinkWildRose('pink_wild_rose'),
  yellowPrimrose('yellow_primrose'),
  forgetMeNotSprig('forget_me_not_sprig'),
  lilacPeony('lilac_peony'),
  yellowCosmos('yellow_cosmos'),
  peachButtercups('peach_buttercups'),
  blueBellflower('blue_bellflower'),
  tealBuds('teal_buds'),
  tealBudsTall('teal_buds_tall'),
  purpleAnemone('purple_anemone'),
  yellowBranch('yellow_branch'),
  lilacVine('lilac_vine'),
  pinkPoppy('pink_poppy'),
  lavenderArc('lavender_arc'),
  lavender('lavender'),
  butterfly('butterfly'),

  /// Solo la flor, recortada del tallo, para iconos pequeños.
  bloomPinkRose('bloom_pink_wild_rose'),
  bloomLilacPeony('bloom_lilac_peony'),
  bloomYellowCosmos('bloom_yellow_cosmos'),
  bloomPurpleAnemone('bloom_purple_anemone'),
  bloomCoralCosmos('bloom_coral_cosmos'),
  bloomPeachButtercup('bloom_peach_buttercups'),
  bloomViolet('bloom_violets'),

  /// Ramilletes compuestos con las flores de arriba.
  cornerBouquet('corner_bouquet'),
  garland('garland'),
  crownBouquet('crown_bouquet'),

  /// Hojita en línea para viñetas pequeñas.
  leaf('leaf', svg: true);

  const Wildflower(this.file, {this.svg = false});

  final String file;
  final bool svg;

  String get asset => svg
      ? 'assets/illustrations/watercolor/$file.svg'
      : 'assets/illustrations/watercolor/$file.webp';

  ImageProvider get image => AssetImage(asset);
}

/// Dibuja una [Wildflower] dentro de una caja de [size] (o de [width] por
/// [height]) sin deformarla. Las acuarelas aparecen con un fundido suave al
/// terminar de cargar.
class WildflowerIcon extends StatelessWidget {
  const WildflowerIcon(
    this.flower, {
    super.key,
    this.size = 40,
    this.width,
    this.height,
    this.flipX = false,
    this.alignment = Alignment.center,
  });

  final Wildflower flower;
  final double size;
  final double? width;
  final double? height;
  final bool flipX;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final w = width ?? size;
    final h = height ?? size;
    final Widget picture = flower.svg
        ? SvgPicture.asset(
            flower.asset,
            width: w,
            height: h,
            alignment: alignment,
            excludeFromSemantics: true,
          )
        : Image.asset(
            flower.asset,
            width: w,
            height: h,
            alignment: alignment,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            excludeFromSemantics: true,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) {
                return child;
              }
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                child: child,
              );
            },
          );
    return flipX ? Transform.flip(flipX: true, child: picture) : picture;
  }
}
