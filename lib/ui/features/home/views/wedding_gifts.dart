import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wedding_g_and_e/data/config/gift_config.dart';
import 'package:wedding_g_and_e/ui/core/garden/choice_pill.dart';
import 'package:wedding_g_and_e/ui/core/garden/wildflower.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_motion.dart';
import 'package:wedding_g_and_e/ui/core/theme/app_theme.dart';

/// Abre la ventana de aportes con sus opciones de pago.
Future<void> showGiftDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const _GiftDialog(),
  );
}

class _GiftDialog extends StatefulWidget {
  const _GiftDialog();

  @override
  State<_GiftDialog> createState() => _GiftDialogState();
}

class _GiftDialogState extends State<_GiftDialog> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final option = giftOptions[_selected];
    final details = [
      for (final detail in option.details)
        if (detail.$2.trim().isNotEmpty) detail,
    ];
    final hasContent = details.isNotEmpty || option.qrAsset != null;
    final duration = AppMotion.reduced(context)
        ? Duration.zero
        : const Duration(milliseconds: 280);

    return Dialog(
      backgroundColor: AppTheme.paper,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppTheme.inkSoft),
                ),
              ),
              const Center(
                child: WildflowerIcon(Wildflower.sweetPea, size: 44),
              ),
              const SizedBox(height: 8),
              Text(
                'Aporta a nuestra vida juntos',
                textAlign: TextAlign.center,
                style: AppTheme.display(fontSize: 30),
              ),
              const SizedBox(height: 12),
              Text(
                'Ningún aporte es pequeño y cada uno lo agradecemos de corazón. '
                'Aun así, tu presencia es el regalo más importante para '
                'nosotros. Si no puedes acompañarnos pero quieres aportar, '
                'también lo recibiremos con muchísimo cariño.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppTheme.inkSoft,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final (i, option) in giftOptions.indexed)
                    ChoicePill(
                      label: option.label,
                      selected: i == _selected,
                      onTap: () => setState(() => _selected = i),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: duration,
                child: Container(
                  key: ValueKey(_selected),
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: hasContent
                      ? Column(
                          children: [
                            if (option.qrAsset case final qr?) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  qr,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                  semanticLabel: 'Código QR de ${option.label}',
                                ),
                              ),
                              if (details.isNotEmpty)
                                const SizedBox(height: 14),
                            ],
                            for (final (label, value) in details)
                              _CopyRow(label: label, value: value),
                            if (details.length > 1) ...[
                              const SizedBox(height: 10),
                              _CopyAllButton(
                                text: [
                                  option.label,
                                  for (final (label, value) in details)
                                    '$label: $value',
                                ].join('\n'),
                              ),
                            ],
                          ],
                        )
                      : Text(
                          'Pronto agregaremos estos datos.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppTheme.inkSoft,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Con cariño, Edgar y Gabriela',
                textAlign: TextAlign.center,
                style: AppTheme.script(fontSize: 28, color: AppTheme.roseInk),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un dato de la cuenta con un botón para copiarlo.
class _CopyRow extends StatefulWidget {
  const _CopyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  State<_CopyRow> createState() => _CopyRowState();
}

class _CopyRowState extends State<_CopyRow> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) {
      return;
    }
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (mounted) {
      setState(() => _copied = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label.toUpperCase(),
                  style: AppTheme.eyebrow().copyWith(fontSize: 11),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  widget.value,
                  style: textTheme.bodyLarge?.copyWith(color: AppTheme.ink),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: _copied ? 'Copiado' : 'Copiar',
            onPressed: _copy,
            icon: Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 20,
              color: _copied ? AppTheme.olive : AppTheme.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

/// Copia todos los datos de la opción de una vez.
class _CopyAllButton extends StatefulWidget {
  const _CopyAllButton({required this.text});

  final String text;

  @override
  State<_CopyAllButton> createState() => _CopyAllButtonState();
}

class _CopyAllButtonState extends State<_CopyAllButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) {
      return;
    }
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() => _copied = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _copy,
      icon: Icon(
        _copied ? Icons.check_rounded : Icons.copy_all_rounded,
        size: 18,
      ),
      label: Text(_copied ? '¡Datos copiados!' : 'Copiar todos los datos'),
      style: OutlinedButton.styleFrom(
        foregroundColor: _copied ? AppTheme.olive : AppTheme.ink,
        side: const BorderSide(color: AppTheme.stem),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    );
  }
}
