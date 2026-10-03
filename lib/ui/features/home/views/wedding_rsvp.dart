import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedding_g_and_e/domain/models/rsvp_submission.dart';
import 'package:wedding_g_and_e/ui/core/garden/garden_card.dart';
import 'package:wedding_g_and_e/ui/core/garden/garden_ornaments.dart';
import 'package:wedding_g_and_e/ui/core/garden/wildflower.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_motion.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_theme.dart';
import 'package:wedding_g_and_e/ui/features/home/cubit/rsvp_cubit.dart';
import 'package:wedding_g_and_e/ui/features/home/views/wedding_home_page.dart';

const _attending = 'Asistiré con gusto';
const _notAttending = 'Con cariño, no podré asistir';

class RsvpSection extends StatefulWidget {
  const RsvpSection({super.key});

  @override
  State<RsvpSection> createState() => _RsvpSectionState();
}

class _RsvpSectionState extends State<RsvpSection> {
  final _formKey = GlobalKey<FormState>();
  final _submitKey = GlobalKey();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dietaryController = TextEditingController();
  String _attendance = _attending;
  int _guestCount = 1;
  String? _thanks;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dietaryController.dispose();
    super.dispose();
  }

  void _celebrate() {
    final firstName = _nameController.text.trim().split(' ').first;
    setState(() {
      _thanks = firstName.isEmpty
          ? '¡Te esperamos!'
          : '¡Gracias, $firstName! Te esperamos';
    });
    final box = _submitKey.currentContext?.findRenderObject();
    if (box is RenderBox && box.attached) {
      showPetalBurst(context, box.localToGlobal(Offset.zero) & box.size);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<RsvpCubit>().submit(
      RsvpSubmission(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        attendance: _attendance,
        guestCount: _guestCount,
        dietaryNotes: _dietaryController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final wide = MediaQuery.sizeOf(context).width >= 640;

    final nameField = TextFormField(
      controller: _nameController,
      autofillHints: const [AutofillHints.name],
      decoration: const InputDecoration(labelText: 'Nombre completo'),
      validator: (value) => (value == null || value.trim().isEmpty)
          ? 'Por favor ingresa tu nombre'
          : null,
    );
    final emailField = TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(labelText: 'Correo electrónico'),
      validator: (value) => (value == null || !value.contains('@'))
          ? 'Ingresa un correo válido'
          : null,
    );

    return BlocConsumer<RsvpCubit, RsvpState>(
      listener: (context, state) {
        if (state.status == RsvpSubmissionStatus.success) {
          _celebrate();
        } else if (state.message case final message?) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == RsvpSubmissionStatus.submitting;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                GardenCard(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(360),
                    bottom: Radius.circular(24),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    wide ? 40 : 22,
                    80,
                    wide ? 40 : 22,
                    36,
                  ),
                  child: Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const GardenHeading(
                            eyebrow: 'Confirmación de asistencia',
                            title: '¿Nos ',
                            accent: 'acompañas?',
                            center: true,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Confírmanos tu asistencia para guardarte un lugar en el jardín.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppTheme.inkSoft,
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (wide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: nameField),
                                const SizedBox(width: 16),
                                Expanded(child: emailField),
                              ],
                            )
                          else ...[
                            nameField,
                            const SizedBox(height: 16),
                            emailField,
                          ],
                          const SizedBox(height: 20),
                          _ChoiceGroup<String>(
                            label: 'Asistencia',
                            value: _attendance,
                            options: const {
                              _attending: _attending,
                              _notAttending: _notAttending,
                            },
                            onChanged: (value) =>
                                setState(() => _attendance = value),
                          ),
                          const SizedBox(height: 16),
                          _ChoiceGroup<int>(
                            label: 'Número de asistentes',
                            value: _guestCount,
                            options: {
                              for (var i = 1; i <= maxGuestsPerInvitation; i++)
                                i: '$i invitado${i == 1 ? '' : 's'}',
                            },
                            onChanged: (value) =>
                                setState(() => _guestCount = value),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _dietaryController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Notas alimentarias',
                              hintText:
                                  'Alergias, vegetariano, sin gluten, etc.',
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: _BloomButton(
                              key: _submitKey,
                              label: isSubmitting
                                  ? 'Enviando confirmación...'
                                  : 'Enviar confirmación',
                              onPressed: isSubmitting ? null : _submit,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedOpacity(
                            opacity: _thanks == null ? 0 : 1,
                            duration: const Duration(milliseconds: 600),
                            child: Text(
                              _thanks ?? ' ',
                              textAlign: TextAlign.center,
                              style: AppTheme.script(
                                fontSize: 34,
                                color: AppTheme.roseInk,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '¿Prefieres Google Forms? ',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.inkSoft,
                                ),
                              ),
                              TextButton(
                                onPressed: () => openExternal(
                                  _googleFormLink(
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.ink,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 36),
                                ),
                                child: const Text(
                                  'Abrir formulario externo',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned(top: -38, child: _FlowerCrown()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChoiceGroup<T> extends StatelessWidget {
  const _ChoiceGroup({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTheme.eyebrow(
            color: AppTheme.inkSoft,
          ).copyWith(letterSpacing: 1.8),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final entry in options.entries)
              ChoiceChip(
                label: Text(entry.value),
                selected: entry.key == value,
                onSelected: (_) => onChanged(entry.key),
              ),
          ],
        ),
      ],
    );
  }
}

/// Botón principal: al pasar el cursor le brotan dos hojas.
class _BloomButton extends StatefulWidget {
  const _BloomButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  State<_BloomButton> createState() => _BloomButtonState();
}

class _BloomButtonState extends State<_BloomButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.reduced(context)
        ? Duration.zero
        : const Duration(milliseconds: 350);
    Widget leaf(double turns) => AnimatedScale(
      scale: _hover ? 1 : 0.2,
      duration: duration,
      curve: AppMotion.sproutCurve,
      child: AnimatedOpacity(
        opacity: _hover ? 1 : 0,
        duration: duration,
        child: Transform.rotate(
          angle: turns,
          child: const WildflowerIcon(Wildflower.leaf, size: 20),
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Focus(
        canRequestFocus: false,
        onFocusChange: (focused) => setState(() => _hover = focused),
        child: AnimatedSlide(
          offset: _hover ? const Offset(0, -0.06) : Offset.zero,
          duration: duration,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              FilledButton(
                onPressed: widget.onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.bubblegum,
                  foregroundColor: AppTheme.ink,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  textStyle: AppTheme.eyebrow(
                    color: AppTheme.ink,
                  ).copyWith(fontSize: 14, letterSpacing: 1.6),
                  elevation: _hover ? 6 : 0,
                  shadowColor: AppTheme.bubblegum,
                ),
                child: Text(widget.label.toUpperCase()),
              ),
              Positioned(left: -10, top: -10, child: leaf(-0.8)),
              Positioned(right: -10, bottom: -10, child: leaf(2.4)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Corona de flores silvestres sobre el arco del RSVP.
class _FlowerCrown extends StatelessWidget {
  const _FlowerCrown();

  @override
  Widget build(BuildContext context) {
    Widget at(double x, double y, Wildflower f, double size, [double r = 0]) {
      return Positioned(
        left: x - size / 2,
        top: y - size / 2,
        child: Transform.rotate(
          angle: r,
          child: WildflowerIcon(f, size: size),
        ),
      );
    }

    return IgnorePointer(
      child: SizedBox(
        width: 300,
        height: 92,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: CustomPaint(painter: _CrownStemPainter())),
            at(134, 30, Wildflower.babysBreath, 30),
            at(166, 30, Wildflower.babysBreath, 30),
            at(74, 58, Wildflower.forgetMeNot, 34),
            at(226, 58, Wildflower.buttercup, 34),
            at(96, 62, Wildflower.bellflower, 34, 0.26),
            at(204, 62, Wildflower.bellflower, 34, -0.26),
            at(116, 46, Wildflower.orchid, 48),
            at(184, 46, Wildflower.orchid, 48),
            at(150, 40, Wildflower.lily, 76),
          ],
        ),
      ),
    );
  }
}

class _CrownStemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(20, 70)
        ..cubicTo(80, 30, 220, 30, 280, 70),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = AppTheme.stem,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _googleFormLink({required String name, required String email}) {
  final base = 'https://docs.google.com/forms/d/e/your-form-id/viewform';
  final prefilledName = Uri.encodeQueryComponent(name);
  final prefilledEmail = Uri.encodeQueryComponent(email);
  return '$base?usp=pp_url&entry.1111111111=$prefilledName&entry.2222222222=$prefilledEmail';
}
