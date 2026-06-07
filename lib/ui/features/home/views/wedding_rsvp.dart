import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedding_g_and_e/domain/models/rsvp_submission.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_theme.dart';
import 'package:wedding_g_and_e/ui/features/home/cubit/rsvp_cubit.dart';
import 'package:wedding_g_and_e/ui/features/home/views/wedding_home_page.dart';

class RsvpSection extends StatefulWidget {
  const RsvpSection({super.key});

  @override
  State<RsvpSection> createState() => _RsvpSectionState();
}

class _RsvpSectionState extends State<RsvpSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dietaryController = TextEditingController();
  String _attendance = 'Asistiré con gusto';
  int _guestCount = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dietaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocConsumer<RsvpCubit, RsvpState>(
      listener: (context, state) {
        if (state.message case final message?) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == RsvpSubmissionStatus.submitting;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirmación de asistencia',
              style: textTheme.displaySmall?.copyWith(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              'Elige la forma de confirmar asistencia. El formulario nativo mantiene a tus invitados en el sitio. Google Forms es ideal para una recolección rápida externa.',
              style: textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF5B6167),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('RSVP nativo en Flutter'),
                  selected: state.mode == RsvpMode.native,
                  onSelected: (_) =>
                      context.read<RsvpCubit>().setMode(RsvpMode.native),
                ),
                ChoiceChip(
                  label: const Text('RSVP con Google Forms'),
                  selected: state.mode == RsvpMode.google,
                  onSelected: (_) =>
                      context.read<RsvpCubit>().setMode(RsvpMode.google),
                ),
              ],
            ),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: state.mode == RsvpMode.native
                  ? Form(
                      key: _formKey,
                      child: Column(
                        key: const ValueKey('native-rsvp-form'),
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 760;
                              if (isWide) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _nameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Nombre completo',
                                        ),
                                        validator: (value) =>
                                            (value == null ||
                                                value.trim().isEmpty)
                                            ? 'Por favor ingresa tu nombre'
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _emailController,
                                        decoration: const InputDecoration(
                                          labelText: 'Correo electrónico',
                                        ),
                                        validator: (value) =>
                                            (value == null ||
                                                !value.contains('@'))
                                            ? 'Ingresa un correo válido'
                                            : null,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Column(
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre completo',
                                    ),
                                    validator: (value) =>
                                        (value == null || value.trim().isEmpty)
                                        ? 'Por favor ingresa tu nombre'
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Correo electrónico',
                                    ),
                                    validator: (value) =>
                                        (value == null || !value.contains('@'))
                                        ? 'Ingresa un correo válido'
                                        : null,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _attendance,
                            items: const [
                              DropdownMenuItem(
                                value: 'Asistiré con gusto',
                                child: Text('Asistiré con gusto'),
                              ),
                              DropdownMenuItem(
                                value: 'Con cariño, no podré asistir',
                                child: Text('Con cariño, no podré asistir'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _attendance = value);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Asistencia',
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: _guestCount,
                            items: List.generate(
                              maxGuestsPerInvitation,
                              (index) => DropdownMenuItem(
                                value: index + 1,
                                child: Text(
                                  '${index + 1} invitado${index == 0 ? '' : 's'}',
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _guestCount = value);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Número de asistentes',
                              helperText: 'Máximo 2 asistentes por invitación',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dietaryController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Notas alimentarias',
                              hintText:
                                  'Alergias, vegetariano, sin gluten, etc.',
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () {
                                      if (!(_formKey.currentState?.validate() ??
                                          false)) {
                                        return;
                                      }

                                      context.read<RsvpCubit>().submit(
                                        RsvpSubmission(
                                          name: _nameController.text.trim(),
                                          email: _emailController.text.trim(),
                                          attendance: _attendance,
                                          guestCount: _guestCount,
                                          dietaryNotes: _dietaryController.text
                                              .trim(),
                                        ),
                                      );
                                    },
                              child: Text(
                                isSubmitting
                                    ? 'Enviando confirmación...'
                                    : 'Enviar confirmación',
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _GoogleFormsCard(
                      key: const ValueKey('google-rsvp-card'),
                      fallbackName: _nameController.text.trim(),
                      fallbackEmail: _emailController.text.trim(),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _GoogleFormsCard extends StatelessWidget {
  const _GoogleFormsCard({
    required super.key,
    required this.fallbackName,
    required this.fallbackEmail,
  });

  final String fallbackName;
  final String fallbackEmail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final prefilled = _googleFormLink(name: fallbackName, email: fallbackEmail);

    return Card(
      color: AppTheme.rose.withValues(alpha: 0.44),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Formulario externo de confirmación',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Úsalo si prefieres gestionar respuestas en Google Forms y Sheets. Podemos rellenar nombre y correo si están disponibles.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () => openExternal(prefilled),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Abrir Google Form'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      openExternal('https://docs.google.com/forms/u/0/'),
                  icon: const Icon(Icons.settings),
                  label: const Text('Administrar formulario'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _googleFormLink({required String name, required String email}) {
  final base = 'https://docs.google.com/forms/d/e/your-form-id/viewform';
  final prefilledName = Uri.encodeQueryComponent(name);
  final prefilledEmail = Uri.encodeQueryComponent(email);
  return '$base?usp=pp_url&entry.1111111111=$prefilledName&entry.2222222222=$prefilledEmail';
}
