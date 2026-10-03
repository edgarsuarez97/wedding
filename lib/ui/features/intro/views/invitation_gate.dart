import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/cubit/invitation_cubit.dart';
import 'gatefold_intro.dart';

/// Muestra la portada floral animada encima del sitio hasta que se abre la invitación.
///
/// El sitio se construye detrás desde el inicio, así que al abrir las puertas
/// aparece directamente, sin pasos extra.
class InvitationGate extends StatelessWidget {
  const InvitationGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isOpen = context.select((InvitationCubit cubit) => cubit.state);

    return Stack(
      children: [
        Positioned.fill(child: child),
        if (!isOpen)
          Positioned.fill(
            child: GatefoldIntro(
              onOpened: context.read<InvitationCubit>().openInvitation,
            ),
          ),
      ],
    );
  }
}
