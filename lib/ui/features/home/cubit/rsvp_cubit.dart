import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/rsvp_repository.dart';
import '../../../../domain/models/rsvp_submission.dart';

enum RsvpSubmissionStatus {
  idle,
  submitting,
  alreadyAnswered,
  success,
  failure,
}

class RsvpState extends Equatable {
  const RsvpState({
    this.status = RsvpSubmissionStatus.idle,
    this.invite,
    this.message,
    this.answeredAt,
    this.updated = false,
  });

  final RsvpSubmissionStatus status;

  /// Invitación del enlace personal, si entró con uno válido.
  final GuestInvite? invite;
  final String? message;

  /// Cuándo respondió antes, cuando [status] es alreadyAnswered.
  final DateTime? answeredAt;

  /// La última confirmación reemplazó una anterior.
  final bool updated;

  /// Sin enlace personal, cada quien confirma solo por sí mismo.
  int get maxGuests => invite?.maxGuests ?? 1;

  RsvpState copyWith({
    RsvpSubmissionStatus? status,
    GuestInvite? invite,
    String? message,
    DateTime? answeredAt,
    bool? updated,
  }) {
    return RsvpState(
      status: status ?? this.status,
      invite: invite ?? this.invite,
      message: message,
      answeredAt: answeredAt,
      updated: updated ?? this.updated,
    );
  }

  @override
  List<Object?> get props => [status, invite, message, answeredAt, updated];
}

class RsvpCubit extends Cubit<RsvpState> {
  RsvpCubit(this._repository) : super(const RsvpState());

  final RsvpRepository _repository;
  RsvpSubmission? _pending;
  RsvpSubmission? _saved;
  bool _openedGifts = false;

  /// El invitado abrió la ventana de aportes. Se guarda con su respuesta, o
  /// se marca enseguida si ya había respondido.
  Future<void> giftsOpened() async {
    _openedGifts = true;
    final saved = _saved;
    if (saved == null) {
      return;
    }
    try {
      await _repository.markGiftsOpened(
        inviteCode: saved.inviteCode,
        email: saved.email,
      );
    } on Object {
      // Es solo un registro; no interrumpe al invitado.
    }
  }

  /// Carga la invitación del enlace `?i=CODIGO`. Un código inválido o sin
  /// conexión deja el formulario general.
  Future<void> loadInvite(String? code) async {
    final trimmed = code?.trim() ?? '';
    if (trimmed.isEmpty) {
      return;
    }
    try {
      final invite = await _repository.fetchInvite(trimmed);
      if (invite != null) {
        emit(state.copyWith(invite: invite));
      }
    } on Object {
      // Se queda con el formulario general.
    }
  }

  Future<void> submit(RsvpSubmission submission) =>
      _send(submission, overwrite: false);

  /// El invitado confirmó que quiere reemplazar su respuesta anterior.
  Future<void> confirmOverwrite() async {
    final pending = _pending;
    if (pending != null) {
      await _send(pending, overwrite: true);
    }
  }

  void cancelOverwrite() {
    _pending = null;
    emit(state.copyWith(status: RsvpSubmissionStatus.idle));
  }

  Future<void> _send(
    RsvpSubmission submission, {
    required bool overwrite,
  }) async {
    final guests = submission.attending
        ? submission.guestCount.clamp(1, state.maxGuests)
        : 0;
    final request = RsvpSubmission(
      name: submission.name,
      email: submission.email,
      attending: submission.attending,
      guestCount: guests,
      dietaryNotes: submission.dietaryNotes,
      drinksAlcohol: submission.attending && submission.drinksAlcohol,
      openedGifts: _openedGifts,
      inviteCode: state.invite?.code,
    );
    _pending = request;
    emit(state.copyWith(status: RsvpSubmissionStatus.submitting));
    try {
      final result = await _repository.submit(request, overwrite: overwrite);
      switch (result) {
        case RsvpSaved(:final updated):
          _pending = null;
          _saved = request;
          emit(
            state.copyWith(
              status: RsvpSubmissionStatus.success,
              updated: updated,
            ),
          );
        case RsvpAlreadyAnswered(:final answeredAt):
          emit(
            state.copyWith(
              status: RsvpSubmissionStatus.alreadyAnswered,
              answeredAt: answeredAt,
            ),
          );
      }
    } on Object {
      emit(
        state.copyWith(
          status: RsvpSubmissionStatus.failure,
          message:
              'No fue posible enviar tu confirmación ahora. Inténtalo de nuevo.',
        ),
      );
    }
  }
}
