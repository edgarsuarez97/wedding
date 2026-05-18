import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/rsvp_repository.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/home/cubit/invitation_cubit.dart';
import 'ui/features/home/cubit/rsvp_cubit.dart';
import 'ui/features/home/views/wedding_home_page.dart';

class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => RsvpRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => InvitationCubit()),
          BlocProvider(
            create: (context) => RsvpCubit(context.read<RsvpRepository>()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Edgar & Gabriela Wedding',
          theme: AppTheme.lightTheme,
          home: const WeddingHomePage(),
        ),
      ),
    );
  }
}
