import 'package:flutter_bloc/flutter_bloc.dart';

class InvitationCubit extends Cubit<bool> {
  InvitationCubit() : super(false);

  void openInvitation() => emit(true);
}
