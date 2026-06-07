import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/rsvp_repository.dart';
import '../../../../domain/models/rsvp_submission.dart';

enum RsvpMode { native, google }

enum RsvpSubmissionStatus { idle, submitting, success, failure }

const maxGuestsPerInvitation = 2;

class RsvpState extends Equatable {
  const RsvpState({
    this.mode = RsvpMode.native,
    this.status = RsvpSubmissionStatus.idle,
    this.message,
  });

  final RsvpMode mode;
  final RsvpSubmissionStatus status;
  final String? message;

  RsvpState copyWith({
    RsvpMode? mode,
    RsvpSubmissionStatus? status,
    String? message,
    bool clearMessage = false,
  }) {
    return RsvpState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [mode, status, message];
}

class RsvpCubit extends Cubit<RsvpState> {
  RsvpCubit(this._repository) : super(const RsvpState());

  final RsvpRepository _repository;

  void setMode(RsvpMode mode) {
    emit(
      state.copyWith(
        mode: mode,
        status: RsvpSubmissionStatus.idle,
        clearMessage: true,
      ),
    );
  }

  Future<void> submit(RsvpSubmission submission) async {
    if (submission.guestCount > maxGuestsPerInvitation) {
      emit(
        state.copyWith(
          status: RsvpSubmissionStatus.failure,
          message:
              'El máximo permitido por invitación es de $maxGuestsPerInvitation asistentes.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: RsvpSubmissionStatus.submitting,
        clearMessage: true,
      ),
    );
    try {
      await _repository.submitRsvp(submission);
      emit(
        state.copyWith(
          status: RsvpSubmissionStatus.success,
          message: 'Gracias. Tu confirmación fue enviada.',
        ),
      );
    } catch (_) {
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
