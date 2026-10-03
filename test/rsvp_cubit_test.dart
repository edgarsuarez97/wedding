import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_g_and_e/data/repositories/rsvp_repository.dart';
import 'package:wedding_g_and_e/domain/models/rsvp_submission.dart';
import 'package:wedding_g_and_e/ui/features/home/cubit/rsvp_cubit.dart';

/// Repositorio en memoria: recuerda quién respondió, como la hoja real.
class _FakeRsvpRepository extends RsvpRepository {
  _FakeRsvpRepository({this.invites = const {}}) : super(endpoint: '');

  final Map<String, GuestInvite> invites;
  final Map<String, RsvpSubmission> saved = {};
  final answeredAt = DateTime(2026, 10, 3);

  @override
  Future<GuestInvite?> fetchInvite(String code) async => invites[code];

  @override
  Future<RsvpResult> submit(
    RsvpSubmission submission, {
    bool overwrite = false,
  }) async {
    final key = submission.inviteCode ?? submission.email;
    final exists = saved.containsKey(key);
    if (exists && !overwrite) {
      return RsvpAlreadyAnswered(answeredAt: answeredAt);
    }
    saved[key] = submission;
    return RsvpSaved(updated: exists);
  }
}

const _submission = RsvpSubmission(
  name: 'Edgar Suarez',
  email: 'edgar@example.com',
  attending: true,
  guestCount: 2,
  dietaryNotes: 'Ninguna',
);

const _invite = GuestInvite(code: 'GE01', name: 'Familia Suarez', maxGuests: 2);

void main() {
  group('RsvpCubit', () {
    late _FakeRsvpRepository repository;

    setUp(() {
      repository = _FakeRsvpRepository(invites: {'GE01': _invite});
    });

    blocTest<RsvpCubit, RsvpState>(
      'loads the invite from a personal link',
      build: () => RsvpCubit(repository),
      act: (cubit) => cubit.loadInvite('GE01'),
      expect: () => [const RsvpState(invite: _invite)],
      verify: (cubit) => expect(cubit.state.maxGuests, 2),
    );

    blocTest<RsvpCubit, RsvpState>(
      'ignores an unknown invite code',
      build: () => RsvpCubit(repository),
      act: (cubit) => cubit.loadInvite('NOPE'),
      expect: () => <RsvpState>[],
    );

    blocTest<RsvpCubit, RsvpState>(
      'saves only one guest without a personal link',
      build: () => RsvpCubit(repository),
      act: (cubit) => cubit.submit(_submission),
      expect: () => [
        const RsvpState(status: RsvpSubmissionStatus.submitting),
        const RsvpState(status: RsvpSubmissionStatus.success),
      ],
      verify: (_) =>
          expect(repository.saved['edgar@example.com']?.guestCount, 1),
    );

    blocTest<RsvpCubit, RsvpState>(
      'saves the invite code and its guests with a personal link',
      build: () => RsvpCubit(repository),
      seed: () => const RsvpState(invite: _invite),
      act: (cubit) => cubit.submit(_submission),
      verify: (_) {
        expect(repository.saved['GE01']?.guestCount, 2);
        expect(repository.saved['GE01']?.inviteCode, 'GE01');
      },
    );

    blocTest<RsvpCubit, RsvpState>(
      'asks before replacing a previous answer, then updates it',
      build: () => RsvpCubit(repository),
      act: (cubit) async {
        await cubit.submit(_submission);
        await cubit.submit(_submission);
        await cubit.confirmOverwrite();
      },
      skip: 2,
      expect: () => [
        const RsvpState(status: RsvpSubmissionStatus.submitting),
        RsvpState(
          status: RsvpSubmissionStatus.alreadyAnswered,
          answeredAt: DateTime(2026, 10, 3),
        ),
        const RsvpState(status: RsvpSubmissionStatus.submitting),
        const RsvpState(status: RsvpSubmissionStatus.success, updated: true),
      ],
    );

    blocTest<RsvpCubit, RsvpState>(
      'keeps the previous answer when the guest cancels',
      build: () => RsvpCubit(repository),
      act: (cubit) async {
        await cubit.submit(_submission);
        await cubit.submit(_submission);
        cubit.cancelOverwrite();
      },
      skip: 4,
      expect: () => [const RsvpState()],
    );

    blocTest<RsvpCubit, RsvpState>(
      'saves zero guests when not attending',
      build: () => RsvpCubit(repository),
      seed: () => const RsvpState(invite: _invite),
      act: (cubit) => cubit.submit(
        const RsvpSubmission(
          name: 'Edgar Suarez',
          email: 'edgar@example.com',
          attending: false,
          guestCount: 2,
          dietaryNotes: '',
        ),
      ),
      verify: (_) => expect(repository.saved['GE01']?.guestCount, 0),
    );
  });
}
