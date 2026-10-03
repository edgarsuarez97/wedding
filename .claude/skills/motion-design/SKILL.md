---
name: motion-design
description: Personalidad y movimiento del sitio de bodas G&E con temática de jardín, incluida la animación inicial del sobre que se abre con el monograma, enredaderas que se dibujan, pétalos y aparición de secciones. Usar al crear o revisar animaciones o interacciones del sitio; complementa la skill animations del plugin VGV.
---

# Movimiento con personalidad de jardín

Las reglas técnicas generales (implícitas vs. `AnimationController`, dispose, curvas con nombre) están en la skill `animations` del plugin VGV y se siguen siempre. Esta skill agrega lo propio del sitio: qué tipo de movimiento usar, cómo hacerlo con SVG y cómo mantenerlo fluido en Flutter Web.

## Principios

- **Natural y orgánico:** como hojas, papel y pétalos. Curvas suaves (`Curves.easeOutCubic`, `Curves.easeInOutSine`), nada de rebotes elásticos fuertes salvo en un detalle pequeño.
- **Un protagonista a la vez:** una animación llamativa por pantalla; el resto, sutil.
- **Rápido para el usuario:** las entradas duran 400 a 900 ms; el sobre inicial no más de unos 3.5 s y siempre se puede saltar.
- **Respetar "reducir movimiento":** leer `MediaQuery.maybeOf(context)?.disableAnimations` como ya hacen `components/scroll.dart` y `wedding_counter.dart`. Con movimiento reducido, mostrar el estado final con un fundido corto.
- **Constantes con nombre:** juntar duraciones y curvas en una clase `AppMotion` (por ejemplo en `lib/ui/core/theme/app_motion.dart`) en lugar de `Duration(...)` sueltos.

## Vocabulario de movimiento

| Momento | Movimiento | Técnica |
|---|---|---|
| Entrada de sección | sube 24 px y aparece | reutilizar el componente de `components/scroll.dart` |
| Separador / enredadera | el trazo se dibuja de un extremo al otro | `CustomPainter` + `PathMetric.extractPath` |
| Esquinas florales | se abren un poco (escala 0.92→1, giro de 2 a 4°) | `TweenAnimationBuilder` o `AnimatedScale` |
| Ambiente | 3 a 6 pétalos cayendo lento, deriva lateral | un solo `CustomPainter` con un `Ticker`, no un widget por pétalo |
| Hover / tap en botones | hoja que se inclina, brillo suave | `AnimatedContainer`, `AnimatedRotation` |
| Monograma | trazo que se firma o aparece con fundido y escala | path drawing o `FadeTransition` + `ScaleTransition` |

## Trazo que se dibuja (enredaderas, monograma)

```dart
// d = atributo "d" del <path> del SVG
final path = parseSvgPathData(d); // package:path_drawing (agregarlo a pubspec.yaml)

class DrawPathPainter extends CustomPainter {
  DrawPathPainter({required this.path, required this.progress, required this.viewBox, required this.strokePaint})
      : super(repaint: progress);

  final Path path;
  final Animation<double> progress;
  final Size viewBox;
  final Paint strokePaint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / viewBox.width, size.height / viewBox.height);
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress.value), strokePaint);
    }
  }

  @override
  bool shouldRepaint(DrawPathPainter old) => old.path != path;
}
```

Calcular `computeMetrics()` una sola vez si el path es largo (guardar la lista en el estado).

## Animación inicial del sobre

Secuencia sugerida con un solo `AnimationController` e `Interval`s:

1. 0.00–0.15 sobre cerrado aparece y se asienta (fundido + escala 0.96→1).
2. 0.15–0.30 el sello de cera se levanta o se parte.
3. 0.30–0.55 la solapa gira sobre su bisagra superior (`Transform` con `Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(ángulo)` y `alignment: Alignment.topCenter`). Al pasar 90° la solapa queda detrás de la tarjeta: cambiar el orden del `Stack` en ese punto.
4. 0.55–0.80 la tarjeta sube hasta la mitad, con el monograma G&E.
5. 0.80–1.00 el monograma brilla o se dibuja y el sobre se desvanece hacia el sitio.

Capas del SVG separadas con el mismo `viewBox` (ver skill `svg-assets`). Incluir botón "Saltar" accesible y no volver a mostrar el sobre si el invitado ya lo vio en la sesión.

## Rendimiento en Flutter Web

- `RepaintBoundary` alrededor de cada pieza animada y de las ilustraciones grandes estáticas que la rodean.
- Animar `Transform` y `Opacity`, no `width`/`height`/`padding`.
- Evitar `BackdropFilter` y `ImageFilter.blur` animados: son muy caros en web.
- Precargar SVG e imágenes de la intro antes de arrancarla para que no aparezcan a saltos.
- Probar con `flutter build web --release` en un teléfono real o en Chrome con la CPU limitada; la versión debug no es representativa.

## Checklist

- ¿Sigue las reglas de la skill `animations` (dispose, constantes, la opción más simple)?
- ¿Respeta `disableAnimations`?
- ¿Se ve fluido en móvil en release?
- ¿Se puede saltar o ignorar sin perder contenido?
- ¿Se siente orgánico y de jardín, no mecánico?
