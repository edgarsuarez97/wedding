---
name: svg-assets
description: Cómo preparar, optimizar, registrar y mostrar en Flutter Web los SVG creados con Claude Design (ilustraciones de jardín, monograma G&E, sobre, adornos). Usar al agregar o reemplazar un SVG en assets/, al mostrarlo con flutter_svg, o al separarlo en capas para animarlo.
---

# SVG en el sitio de bodas

El sitio es Flutter Web y dibuja los SVG con `flutter_svg` (ya está en `pubspec.yaml`). `flutter_svg` no es un navegador: entiende un subconjunto de SVG. Un SVG que se ve bien en Claude Design puede salir distinto en Flutter si usa funciones que el renderizador ignora.

## 1. Pedir el SVG a Claude Design de forma compatible

Al generar o exportar un SVG, pedir explícitamente:

- `viewBox` definido y sin `width`/`height` fijos en px (o que coincidan con el viewBox).
- Solo formas y trazos: `path`, `circle`, `ellipse`, `rect`, `line`, `polyline`, `polygon`, `g` con `transform`.
- Colores como atributos (`fill="#8EA883"`) o `style=""` en línea. **Nada de bloques `<style>` con clases.**
- Degradados lineales o radiales están bien.
- **Sin** filtros (`feGaussianBlur`, `feTurbulence`, sombras), sin `foreignObject`, sin animación SMIL/CSS, sin fuentes web en `<text>`: el texto debe ir convertido a trazos (contornos). El efecto acuarela se logra con varias capas de opacidad, no con filtros.
- Un `id` legible en cada grupo que se vaya a animar (`id="petal-left"`, `id="flap"`, `id="monogram-g"`).
- Paleta de la skill `garden-design`: usar los tonos de `lib/ui/core/theme/app_theme.dart` o los verdes y rosas de las ilustraciones existentes.

Revisar con: `grep -nE '<style|<filter|foreignObject|<animate|<text' archivo.svg` debe salir vacío.

## 2. Dónde va y cómo se nombra

- `assets/illustrations/` para ilustraciones y adornos (`floral_corner_watercolor.svg`, `vine_vertical_watercolor.svg`).
- `assets/brand/` para el monograma y piezas de identidad (`monogram_ge.svg`, `monogram_ge_mark.svg`).
- `assets/envelope/` para las capas del sobre de la animación inicial.
- Nombres en `snake_case`, en inglés, describiendo la pieza, no la sección.

## 3. Optimizar sin romper capas

```bash
npx svgo --multipass --config='{"plugins":[{"name":"preset-default","params":{"overrides":{"cleanupIds":false,"collapseGroups":false,"convertShapeToPath":false}}}]}' archivo.svg -o archivo.svg
```

Conservar `id` y grupos porque se usan para separar capas. Objetivo: menos de ~30 KB por ilustración; si pesa más, simplificar trazos en Claude Design antes que bajar la precisión a mano.

## 4. Registrar en pubspec.yaml

Hoy `pubspec.yaml` lista los assets uno por uno. Agregar cada SVG nuevo ahí (o la carpeta con `/` final). Sin esto Flutter Web da 404 en producción aunque funcione en `flutter run`.

Para SVG grandes o que salen en el primer pantallazo (sobre, monograma), precompilar con `vector_graphics` para que carguen más rápido:

```yaml
flutter:
  assets:
    - path: assets/brand/monogram_ge.svg
      transformers:
        - package: vector_graphics_compiler
```

y mostrarlo con `SvgPicture(const AssetBytesLoader('assets/brand/monogram_ge.svg'))` (requiere `vector_graphics` y `vector_graphics_compiler` como dependencias). Para el resto basta `SvgPicture.asset`.

## 5. Mostrarlo en Flutter

```dart
SvgPicture.asset(
  'assets/illustrations/floral_corner_watercolor.svg',
  width: 220,
  fit: BoxFit.contain,
  semanticsLabel: 'Esquina floral', // omitir y usar excludeFromSemantics: true si es solo decoración
)
```

- Adornos puramente decorativos: `excludeFromSemantics: true`.
- Recolorear una pieza monocroma (por ejemplo el monograma en blanco sobre foto): `colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)`.
- Envolver ilustraciones grandes y estáticas en `RepaintBoundary` cuando estén cerca de algo animado.
- Precargar lo que aparece en la animación inicial para evitar parpadeo: `final loader = SvgAssetLoader(path); await svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));` antes de arrancar la animación.

## 6. SVG que se va a animar

Flutter no anima partes internas de un `SvgPicture`. Dos caminos:

1. **Capas separadas (preferido para el sobre y flores):** exportar cada parte móvil como su propio SVG, todos con el **mismo `viewBox`**, y apilarlos en un `Stack` con `Positioned.fill`. Así quedan alineados y cada capa se anima con `Transform`/`Opacity`. Ejemplo para el sobre: `envelope_back.svg`, `envelope_card.svg`, `envelope_front.svg`, `envelope_flap.svg`, `wax_seal.svg`.
2. **Trazo que se dibuja (enredaderas, firma del monograma):** copiar el atributo `d` del path y convertirlo con `parseSvgPathData` del paquete `path_drawing`, luego dibujar en un `CustomPainter` con `PathMetric.extractPath` según el progreso. Ver la skill `motion-design`.

Anotar el punto de giro de cada capa (por ejemplo la bisagra de la solapa del sobre) en coordenadas del viewBox, porque el `Transform` necesita ese `alignment`/`origin`.

## 7. Verificar

- `flutter build web` y abrir el build: comparar con el preview de Claude Design.
- Si una parte desaparece o sale negra, casi siempre es un filtro, un `<style>` o una máscara compleja: volver al paso 1.
