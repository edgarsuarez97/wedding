import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/repositories/rsvp_repository.dart';
import 'data/repositories/wedding_content_repository.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/home/cubit/invitation_cubit.dart';
import 'ui/features/home/cubit/rsvp_cubit.dart';
import 'ui/features/home/cubit/wedding_content_cubit.dart';
import 'ui/features/home/views/wedding_home_page.dart';
import 'ui/features/intro/views/invitation_gate.dart';

class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => RsvpRepository()),
        RepositoryProvider(create: (_) => WeddingContentRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                WeddingContentCubit(context.read<WeddingContentRepository>())
                  ..load(),
          ),
          BlocProvider(
            create: (context) =>
                RsvpCubit(context.read<RsvpRepository>())
                  ..loadInvite(Uri.base.queryParameters['i']),
          ),
          BlocProvider(create: (_) => InvitationCubit()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Boda de Edgar y Gabriela',
          locale: const Locale('es', 'ES'),
          supportedLocales: const [Locale('es', 'ES')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.lightTheme,
          home: const InvitationGate(child: WeddingHomePage()),
        ),
      ),
    );
  }
}
