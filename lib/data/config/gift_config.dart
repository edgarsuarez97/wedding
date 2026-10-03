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
    qrAsset: 'assets/gifts/binance_qr.png',
    details: [('Usuario', 'EdgarAle97')],
  ),
  GiftOption(
    label: 'Venezuela',
    details: [
      ('Pago móvil', 'Banco Banesco (0134)'),
      ('Teléfono', '04244649772'),
      ('Cédula', 'V26162720'),
    ],
  ),
  GiftOption(
    label: 'Estados Unidos',
    details: [
      ('Beneficiario', 'EDGAR ALEJANDRO SUAREZ MANFREDI'),
      ('Número de cuenta', '56110034668'),
      ('Routing (ACH)', '021502189'),
      ('SWIFT', 'FILCPR22'),
      ('Banco', 'FACEBANK International'),
      ('Correo', 'edgarsuarez97@gmail.com'),
    ],
  ),
];
