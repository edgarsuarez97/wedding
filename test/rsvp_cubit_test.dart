import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_g_and_e/data/repositories/rsvp_repository.dart';
import 'package:wedding_g_and_e/domain/models/rsvp_submission.dart';
import 'package:wedding_g_and_e/ui/features/home/cubit/rsvp_cubit.dart';

void main() {
  group('RsvpCubit', () {
    late RsvpCubit cubit;

    setUp(() {
      cubit = RsvpCubit(RsvpRepository());
    });

    tearDown(() async {
      await cubit.close();
    });

    blocTest<RsvpCubit, RsvpState>(
      'changes mode to google',
      build: () => cubit,
      act: (cubit) => cubit.setMode(RsvpMode.google),
      expect: () => [const RsvpState(mode: RsvpMode.google)],
    );

    blocTest<RsvpCubit, RsvpState>(
      'submits RSVP and emits success',
      build: () => cubit,
      act: (cubit) => cubit.submit(
        const RsvpSubmission(
          name: 'Edgar Suarez',
          email: 'edgar@example.com',
          attendance: 'Joyfully attending',
          guestCount: 2,
          dietaryNotes: 'None',
        ),
      ),
      expect: () => [
        const RsvpState(status: RsvpSubmissionStatus.submitting),
        const RsvpState(
          status: RsvpSubmissionStatus.success,
          message: 'Thank you! Your RSVP was sent.',
        ),
      ],
    );
  });
}
