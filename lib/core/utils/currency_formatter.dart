class CurrencyFormatter {
  CurrencyFormatter._();

  static String defaultForLocale(String languageCode) =>
      languageCode == 'vi' ? 'VND' : 'USD';

  static String format(double amount, String currency) {
    final sign = amount < 0 ? '-' : '';
    final abs = amount.abs();

    return switch (currency) {
      'VND' => '$sign${_groupInt(abs, '.')}đ',
      'USD' => '$sign\$${_groupDecimal(abs)}',
      'EUR' => '$sign€${_groupDecimal(abs)}',
      'JPY' => '$sign¥${_groupInt(abs, ',')}',
      'THB' => '$sign฿${_groupDecimal(abs)}',
      _ => '$sign${abs.toStringAsFixed(2)} $currency',
    };
  }

  static bool usesDecimals(String currency) => currency != 'VND' && currency != 'JPY';

  static double? parseAmount(String raw, String currency) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    if (usesDecimals(currency)) {
      return double.tryParse(text.replaceAll(',', ''));
    }
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return null;
    return double.tryParse(digits);
  }

  static String currencyLabel(String currency) => switch (currency) {
        'VND' => 'đ',
        'USD' => '\$',
        'EUR' => '€',
        'JPY' => '¥',
        'THB' => '฿',
        _ => currency,
      };

  static String _groupInt(double value, String separator) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}$separator');
  }

  static String _groupDecimal(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$intPart.${parts[1]}';
  }
}
