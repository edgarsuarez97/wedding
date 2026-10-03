# Confirmaciones en Google Sheets

El formulario del sitio guarda cada confirmación en una hoja de Google a
través de un pequeño script (Apps Script). No necesitas un servidor, y es
gratis.

## Configuración (una sola vez, unos 5 minutos)

1. Crea una hoja nueva en [sheets.new](https://sheets.new) y ponle un nombre,
   por ejemplo "Boda G&E – Confirmaciones".
2. En el menú, abre **Extensiones → Apps Script**.
3. Borra lo que trae `Código.gs`, pega todo el contenido de [`Code.gs`](Code.gs)
   y guarda.
4. Arriba, elige la función `prepararHoja` y pulsa **Ejecutar**. Google te
   pedirá permiso para que el script use tu hoja; acéptalo. Se crearán las
   pestañas **Invitados** y **Respuestas**.
5. Pulsa **Implementar → Nueva implementación**. En el engranaje, elige
   **Aplicación web** y configura:
   - Ejecutar como: **Yo**
   - Quién tiene acceso: **Cualquier usuario**
6. Pulsa **Implementar** y copia la **URL de la aplicación web** (termina en
   `/exec`).
7. Pega esa URL en `lib/data/config/rsvp_config.dart`, dentro de
   `rsvpEndpoint`, o pásasela a Claude para que la ponga y publique el sitio.

Si después cambias el script, ve a **Implementar → Gestionar
implementaciones**, edita la que ya tienes y elige **Nueva versión**. Así la
URL no cambia.

## Invitados y cupos

En la pestaña **Invitados**, escribe una fila por invitación:

| Código | Nombre | Cupos |
| ------ | ------ | ----- |
| GE01 | Ana Pérez | 1 |
| GE02 | Carlos y Marta | 2 |

Cada invitado recibe su enlace personal con su código:

```
https://edgarsuarez97.github.io/wedding/?i=GE01
```

- Con **1 cupo**, el formulario no muestra "Número de asistentes" y guarda
  1 persona.
- Con **2 cupos o más**, puede elegir cuántos vienen, hasta su límite.
- Si alguien entra sin código, puede confirmar solo por sí mismo.

Usa códigos difíciles de adivinar si no quieres que alguien pruebe otros
(por ejemplo `GE-7K2P` en vez de `GE01`).

## Respuestas

La pestaña **Respuestas** se llena sola. Si alguien vuelve a responder, el
sitio le avisa que ya respondió y le pregunta si quiere reemplazar su
respuesta. Si acepta, se actualiza su misma fila: cambia "Última
actualización" y aumenta "Veces respondido".

Con código, la respuesta se identifica por el código. Sin código, se
identifica por el correo.
