/// Datos para la ventana "Aporta a nuestra vida juntos".
///
/// Un dato con valor vacío no se muestra. Si una opción no tiene ningún dato,
/// la ventana dice que pronto se agregarán.
class GiftOption {
  const GiftOption({required this.label, required this.details, this.qrAsset});

  /// Nombre de la pestaña, por ejemplo "Binance Pay".
  final String label;

  /// Pares (etiqueta, valor) que el invitado puede copiar.
  final List<(String, String)> details;

  /// Imagen de un código QR en assets/gifts/, si la opción tiene uno.
  final String? qrAsset;
}

const giftOptions = [
  GiftOption(
    label: 'Binance Pay',
    // Ejemplo: 'assets/gifts/binance_qr.png'
    qrAsset: null,
    details: [('Pay ID', ''), ('Usuario', '')],
  ),
  GiftOption(
    label: 'Venezuela',
    details: [
      ('Banco', ''),
      ('Titular', ''),
      ('Cédula', ''),
      ('Número de cuenta', ''),
      ('Pago móvil (teléfono)', ''),
    ],
  ),
  GiftOption(
    label: 'Estados Unidos',
    details: [
      ('Zelle', ''),
      ('Banco', ''),
      ('Titular', ''),
      ('Número de cuenta', ''),
      ('Routing (ABA)', ''),
    ],
  ),
];
