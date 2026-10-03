---
name: garden-design
description: Guía visual del sitio de bodas G&E con temática de boda de jardín (paleta, tipografía, ornamentos florales, texturas, espaciado y tono). Usar al diseñar o revisar cualquier sección, widget, color o ilustración del sitio, o al pedir SVG a Claude Design.
---

# Diseño de jardín para G&E

Boda de jardín de Gabita y Edgar (28 de agosto de 2027, Tribus Privé, Valencia). El sitio debe sentirse como una invitación de papel fino en un jardín: luminoso, botánico, romántico y con aire, nunca recargado ni "plantilla de boda genérica".

Antes de cambiar estilos, leer `lib/ui/core/theme/app_theme.dart`. Ese archivo es la fuente de verdad: si hace falta un color o estilo nuevo, se agrega ahí como constante con nombre, no en el widget (ver también la skill `material-theming` del plugin VGV).

## Paleta

Base actual en `AppTheme`: `mint #BED7D1`, `lavender #F7C4F7`, `lime #E7FBD4`, `rose #F8E1E7`, `blush #F8D1E0`, texto `#2F3843`.

Para la temática de jardín, ampliar con tonos que ya aparecen en las ilustraciones SVG del repo:

| Rol | Tono | Uso |
|---|---|---|
| Hoja profunda | `#6F8A65` | tallos, detalles finos, iconos |
| Salvia | `#8EA883` | trazos principales, acentos |
| Brote | `#B1C7A1` | rellenos suaves, separadores |
| Peonía | `#E4B8C8` | flores, botones secundarios |
| Durazno | `#F1CAA1` | flores cálidas, destellos |
| Papel | blanco con `paper_texture.jpg` | fondo |

Reglas:
- Verdes para estructura (tallos, líneas, bordes), rosas y durazno para las flores y los momentos importantes.
- Máximo un acento saturado por sección.
- El texto siempre en `#2F3843` (u oscuro equivalente) sobre fondos claros; verificar contraste AA (4.5:1) en texto normal. Los pasteles no sirven como color de texto.

## Tipografía

- Títulos: Playfair Display (ya configurada en `displayLarge` … `titleLarge`).
- Cuerpo: Source Sans 3.
- Si se agrega una caligráfica (nombres, monograma, "Save the date"), usar solo para 1 a 4 palabras por pantalla, nunca para párrafos, y cargarla desde `google_fonts`.
- El monograma G&E se usa como SVG (texto convertido a trazos), no como fuente.

## Ornamentos botánicos

- Ilustraciones estilo acuarela con trazos de línea fina: hojas, enredaderas, ramas, peonías, flores silvestres.
- Las esquinas florales enmarcan, no tapan contenido: ubicarlas en bordes y esquinas con `Positioned`, a baja opacidad cuando quedan detrás de texto.
- Asimetría natural: una esquina florida y la opuesta con una rama ligera se ve más orgánico que cuatro esquinas idénticas.
- Separadores entre secciones: una rama o enredadera horizontal en lugar de `Divider`.
- Preparación y carga de los SVG: skill `svg-assets`.

## Superficies y formas

- Fondo de papel con textura (`paper_texture.jpg`), tarjetas blancas o crema translúcidas encima.
- Bordes redondeados suaves (los existentes: 24 en tarjetas, 14 en campos). Para marcos de invitación se valen arcos tipo "arco de jardín" (parte superior redondeada).
- Sombras muy suaves y cálidas o ninguna; nada de sombras grises duras de Material.
- Mucho espacio en blanco: usar múltiplos de 8 y dejar respirar cada sección.

## Tono del contenido

Español, cálido y cercano, en segunda persona ("te esperamos"). Frases cortas. Evitar clichés en exceso.

## Movimiento

Las animaciones deben parecer naturales del jardín (pétalos, hojas, enredaderas que crecen, papel que se abre). Ver la skill `motion-design`.

## Checklist al revisar una sección

- ¿Usa colores y estilos de `AppTheme` en lugar de valores sueltos?
- ¿Hay como máximo un acento fuerte y suficiente espacio en blanco?
- ¿Los ornamentos enmarcan sin tapar el contenido ni bajar el contraste del texto?
- ¿Se ve bien en móvil (ancho de 360 a 430) y escritorio?
- ¿Se siente como jardín y no como una plantilla genérica?
