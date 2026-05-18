import '../../domain/models/rsvp_submission.dart';

class RsvpRepository {
  Future<void> submitRsvp(RsvpSubmission submission) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (submission.name.trim().isEmpty) {
      throw StateError('Name is required.');
    }
  }
}
