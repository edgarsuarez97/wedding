/**
 * Recibe las confirmaciones del sitio de la boda y las guarda en esta hoja.
 *
 * Pestañas que usa (se crean solas la primera vez):
 *   Invitados:  Código | Nombre | Cupos
 *     Una fila por invitación. "Cupos" es cuántas personas pueden venir con
 *     ese enlace (1 = solo el invitado, 2 = con acompañante).
 *   Respuestas: Código | Nombre | Correo | Asistencia | Personas | Notas |
 *               Primera respuesta | Última actualización | Veces respondido
 *
 * Cada invitado recibe su enlace personal: https://edgarsuarez97.github.io/wedding/?i=CODIGO
 * Si alguien entra sin código, puede confirmar solo para sí mismo y su
 * respuesta se identifica por el correo.
 */

const INVITADOS = 'Invitados';
const RESPUESTAS = 'Respuestas';
const ENCABEZADOS_INVITADOS = ['Código', 'Nombre', 'Cupos'];
const ENCABEZADOS_RESPUESTAS = [
  'Código',
  'Nombre',
  'Correo',
  'Asistencia',
  'Personas',
  'Notas',
  'Primera respuesta',
  'Última actualización',
  'Veces respondido',
];

/** GET ?accion=invitacion&codigo=X  →  { ok, nombre, cupos } */
function doGet(e) {
  const p = e.parameter || {};
  if (p.accion === 'invitacion') {
    const inv = buscarInvitacion_(p.codigo);
    if (!inv) return json_({ ok: false, error: 'codigo_no_encontrado' });
    return json_({ ok: true, codigo: inv.codigo, nombre: inv.nombre, cupos: inv.cupos });
  }
  return json_({ ok: true, servicio: 'rsvp' });
}

/**
 * POST (texto JSON): { codigo?, nombre, correo, asistencia, personas, notas,
 * sobrescribir }
 * Si ya había respondido y sobrescribir no es true, no guarda y devuelve
 * { ok: false, yaRespondio: true, fecha }.
 */
function doPost(e) {
  const lock = LockService.getScriptLock();
  lock.waitLock(10000);
  try {
    const d = JSON.parse(e.postData.contents || '{}');
    const nombre = String(d.nombre || '').trim().slice(0, 120);
    const correo = String(d.correo || '').trim().toLowerCase().slice(0, 120);
    if (!nombre || correo.indexOf('@') < 1) {
      return json_({ ok: false, error: 'datos_incompletos' });
    }

    const inv = d.codigo ? buscarInvitacion_(d.codigo) : null;
    const codigo = inv ? inv.codigo : '';
    const cupos = inv ? inv.cupos : 1;
    const asiste = d.asistencia === 'si';
    const personas = asiste
      ? Math.max(1, Math.min(cupos, parseInt(d.personas, 10) || 1))
      : 0;
    const notas = String(d.notas || '').trim().slice(0, 500);

    const hoja = hoja_(RESPUESTAS, ENCABEZADOS_RESPUESTAS);
    const fila = buscarRespuesta_(hoja, codigo, correo);
    const ahora = new Date();

    if (fila && d.sobrescribir !== true) {
      const anterior = hoja.getRange(fila, 8).getValue();
      return json_({
        ok: false,
        yaRespondio: true,
        fecha: anterior instanceof Date ? anterior.toISOString() : null,
      });
    }

    const valores = [
      codigo,
      nombre,
      correo,
      asiste ? 'Asistirá' : 'No asistirá',
      personas,
      notas,
    ];
    if (fila) {
      const veces = Number(hoja.getRange(fila, 9).getValue()) || 1;
      hoja.getRange(fila, 1, 1, 6).setValues([valores]);
      hoja.getRange(fila, 8, 1, 2).setValues([[ahora, veces + 1]]);
    } else {
      hoja.appendRow(valores.concat([ahora, ahora, 1]));
    }
    return json_({ ok: true, actualizado: Boolean(fila), personas: personas });
  } catch (err) {
    return json_({ ok: false, error: String(err) });
  } finally {
    lock.releaseLock();
  }
}

function buscarInvitacion_(codigo) {
  const buscado = String(codigo || '').trim().toUpperCase();
  if (!buscado) return null;
  const filas = hoja_(INVITADOS, ENCABEZADOS_INVITADOS).getDataRange().getValues();
  for (let i = 1; i < filas.length; i++) {
    if (String(filas[i][0]).trim().toUpperCase() === buscado) {
      return {
        codigo: buscado,
        nombre: String(filas[i][1]).trim(),
        cupos: Math.max(1, parseInt(filas[i][2], 10) || 1),
      };
    }
  }
  return null;
}

/** Con código se identifica por el código; sin código, por el correo. */
function buscarRespuesta_(hoja, codigo, correo) {
  const filas = hoja.getDataRange().getValues();
  for (let i = 1; i < filas.length; i++) {
    const mismoCodigo = codigo && String(filas[i][0]).toUpperCase() === codigo;
    const mismoCorreo =
      !codigo && !filas[i][0] && String(filas[i][2]).toLowerCase() === correo;
    if (mismoCodigo || mismoCorreo) return i + 1;
  }
  return null;
}

function hoja_(nombre, encabezados) {
  const libro = SpreadsheetApp.getActiveSpreadsheet();
  let hoja = libro.getSheetByName(nombre);
  if (!hoja) {
    hoja = libro.insertSheet(nombre);
    hoja.appendRow(encabezados);
    hoja.setFrozenRows(1);
    hoja.getRange(1, 1, 1, encabezados.length).setFontWeight('bold');
  }
  return hoja;
}

function json_(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(
    ContentService.MimeType.JSON,
  );
}

/** Ejecútala una vez desde el editor para crear las dos pestañas. */
function prepararHoja() {
  hoja_(INVITADOS, ENCABEZADOS_INVITADOS);
  hoja_(RESPUESTAS, ENCABEZADOS_RESPUESTAS);
}
