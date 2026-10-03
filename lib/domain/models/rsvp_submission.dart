import 'package:equatable/equatable.dart';

/// Lo que el invitado envía desde el formulario.
class RsvpSubmission extends Equatable {
  const RsvpSubmission({
    required this.name,
    required this.email,
    required this.attending,
    required this.guestCount,
    required this.dietaryNotes,
    this.drinksAlcohol = false,
    this.openedGifts = false,
    this.inviteCode,
  });

  final String name;
  final String email;
  final bool attending;
  final int guestCount;
  final String dietaryNotes;

  /// Quiere bebidas con alcohol en la celebración.
  final bool drinksAlcohol;

  /// Abrió la ventana de aportes antes de enviar.
  final bool openedGifts;

  /// Código del enlace personal (`?i=CODIGO`), si entró con uno.
  final String? inviteCode;

  @override
  List<Object?> get props => [
    name,
    email,
    attending,
    guestCount,
    dietaryNotes,
    drinksAlcohol,
    openedGifts,
    inviteCode,
  ];
}

/// Invitación registrada en la hoja: a nombre de quién y cuántas personas
/// pueden venir con ella.
class GuestInvite extends Equatable {
  const GuestInvite({
    required this.code,
    required this.name,
    required this.maxGuests,
  });

  final String code;
  final String name;
  final int maxGuests;

  @override
  List<Object> get props => [code, name, maxGuests];
}

/// Resultado de enviar una confirmación.
sealed class RsvpResult {
  const RsvpResult();
}

/// Se guardó. [updated] indica que reemplazó una respuesta anterior.
class RsvpSaved extends RsvpResult {
  const RsvpSaved({required this.updated});

  final bool updated;
}

/// Ya había respondido y no se pidió reemplazar la respuesta.
class RsvpAlreadyAnswered extends RsvpResult {
  const RsvpAlreadyAnswered({this.answeredAt});

  final DateTime? answeredAt;
}
