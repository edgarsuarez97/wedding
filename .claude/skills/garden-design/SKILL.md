---
name: garden-design
description: Guía visual del sitio de bodas G&E con temática de boda de jardín (paleta, tipografía, ornamentos florales, texturas, espaciado y tono). Usar al diseñar o revisar cualquier sección, widget, color o ilustración del sitio, o al pedir SVG a Claude Design.
---

# Diseño de jardín para G&E

Boda de jardín de Gabita y Edgar (28 de agosto de 2027, Tribus Privé, Valencia). El sitio debe sentirse como una invitación de papel fino en un jardín: luminoso, botánico, romántico y con aire, nunca recargado ni "plantilla de boda genérica".

Antes de cambiar estilos, leer `lib/ui/core/theme/app_theme.dart`. Ese archivo es la fuente de verdad: si hace falta un color o estilo nuevo, se agrega ahí como constante con nombre, no en el widget (ver también la skill `material-theming` del plugin VGV).

## Paleta

Paleta "Garden Party" elegida por Edgar. Está en `AppTheme` como constantes con nombre:

| Rol | Constante | Tono |
|---|---|---|
| Azul campanilla | `bellBlue` | `#9DBCE6` |
| Oliva | `oliveLeaf` | `#B6C489` |
| Rosa guisante | `sweetPea` | `#F4C3D3` |
| Durazno | `peach` | `#FFCC8F` |
| Mantequilla | `butter` | `#FFEB9F` |
| Lavanda | `lavender` | `#C9C1E3` |

Apoyo: `sky #BCD7F2`, `lilac #DCC2F1`, `bubblegum #FFA8C1`, `mint #B7D7AA`, `cream #F8F0B0`. Papel: `paper #FBF9F3` con `paper_texture.jpg` al 50 %.

Reglas:
- Los pasteles son para flores, fondos y adornos, nunca para texto.
- Texto en `ink #34392F` o `inkSoft #5E6457`. Etiquetas en `olive #6F7D45`. Acento de títulos (cursiva) en `lavenderInk #8A6FC0`. Firmas en caligrafía en `roseInk #B95A84`. Tallos en `stem #93A160`.
- Botón principal: `bubblegum` con texto `ink` (el blanco no tiene contraste).
- Verificar contraste AA (4.5:1) en texto normal.

## Tipografía

- Nombres y frases cortas: Pinyon Script (`AppTheme.script`), máximo 1 a 4 palabras.
- Títulos: Cormorant Garamond (`AppTheme.display`), con una parte en cursiva lavanda (`GardenHeading`).
- Cuerpo: Jost.
- El monograma G&E se usa como SVG (texto convertido a trazos), no como fuente.

## Ornamentos botánicos

- Flores silvestres, **sin rosas ni margaritas**: campanillas, lirios (rosa pastel, no naranja), orquídeas, guisantes de olor, nomeolvides, botones de oro, espuelas de caballero y paniculata, más hojas menta y briznas. Están en `assets/illustrations/wildflowers/` y se usan con `WildflowerIcon`.
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
