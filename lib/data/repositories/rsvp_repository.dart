import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/rsvp_submission.dart';
import '../config/rsvp_config.dart';

/// Guarda las confirmaciones en Google Sheets a través de Apps Script.
class RsvpRepository {
  RsvpRepository({http.Client? client, String endpoint = rsvpEndpoint})
    : _client = client ?? http.Client(),
      _endpoint = endpoint;

  final http.Client _client;
  final String _endpoint;

  bool get _configured => _endpoint.isNotEmpty;

  /// Busca la invitación del enlace personal. Devuelve null si no existe.
  Future<GuestInvite?> fetchInvite(String code) async {
    if (!_configured) {
      return null;
    }
    final uri = Uri.parse(
      _endpoint,
    ).replace(queryParameters: {'accion': 'invitacion', 'codigo': code});
    final data = _decode(await _client.get(uri));
    if (data['ok'] != true) {
      return null;
    }
    return GuestInvite(
      code: data['codigo'] as String,
      name: data['nombre'] as String,
      maxGuests: (data['cupos'] as num).toInt(),
    );
  }

  /// Envía la confirmación. Si ya había respondido y [overwrite] es false,
  /// no guarda nada y devuelve [RsvpAlreadyAnswered].
  Future<RsvpResult> submit(
    RsvpSubmission submission, {
    bool overwrite = false,
  }) async {
    if (!_configured) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      return const RsvpSaved(updated: false);
    }
    // text/plain evita la consulta previa de CORS, que Apps Script no admite.
    final response = await _client.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'text/plain;charset=utf-8'},
      body: jsonEncode({
        'codigo': submission.inviteCode,
        'nombre': submission.name,
        'correo': submission.email,
        'asistencia': submission.attending ? 'si' : 'no',
        'personas': submission.guestCount,
        'notas': submission.dietaryNotes,
        'sobrescribir': overwrite,
      }),
    );
    final data = _decode(response);
    if (data['ok'] == true) {
      return RsvpSaved(updated: data['actualizado'] == true);
    }
    if (data['yaRespondio'] == true) {
      final date = data['fecha'];
      return RsvpAlreadyAnswered(
        answeredAt: date is String ? DateTime.tryParse(date)?.toLocal() : null,
      );
    }
    throw StateError('RSVP rechazado: ${data['error']}');
  }

  Map<String, Object?> _decode(http.Response response) {
    if (response.statusCode != 200) {
      throw StateError('RSVP HTTP ${response.statusCode}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, Object?>;
  }
}
