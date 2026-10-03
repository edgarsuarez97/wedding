import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/cubit/invitation_cubit.dart';
import '../../home/cubit/wedding_content_cubit.dart';
import 'gatefold_intro.dart';

/// Muestra la portada floral animada encima del sitio hasta que se abre la invitación.
///
/// El sitio se construye detrás desde el inicio, así que al abrir el sobre ya
/// está cargado.
class InvitationGate extends StatelessWidget {
  const InvitationGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isOpen = context.select((InvitationCubit cubit) => cubit.state);
    final weddingDate = context.select(
      (WeddingContentCubit cubit) => cubit.state.content?.weddingDate,
    );

    return Stack(
      children: [
        Positioned.fill(child: child),
        if (!isOpen)
          Positioned.fill(
            child: GatefoldIntro(
              dateLabel: weddingDate == null
                  ? '28 · 08 · 2027'
                  : _formatDate(weddingDate),
              onOpened: context.read<InvitationCubit>().openInvitation,
            ),
          ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(date.day)} · ${twoDigits(date.month)} · ${date.year}';
  }
}
