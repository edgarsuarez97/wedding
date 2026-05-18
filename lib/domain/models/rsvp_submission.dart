import 'package:equatable/equatable.dart';

class RsvpSubmission extends Equatable {
  const RsvpSubmission({
    required this.name,
    required this.email,
    required this.attendance,
    required this.guestCount,
    required this.dietaryNotes,
  });

  final String name;
  final String email;
  final String attendance;
  final int guestCount;
  final String dietaryNotes;

  @override
  List<Object> get props => [name, email, attendance, guestCount, dietaryNotes];
}
