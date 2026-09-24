import 'package:flutter/material.dart';
import 'package:rental_management/core/utils/currency_formatter.dart';

/// Reusable Widget for displaying money amounts formatted as VND.
class CurrencyText extends StatelessWidget {
  final num? amount;
  final TextStyle? style;
  final bool isCompact;

  const CurrencyText({
    super.key,
    required this.amount,
    this.style,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = isCompact
        ? CurrencyFormatter.formatCompact(amount)
        : CurrencyFormatter.format(amount);

    return Text(
      text,
      style: style ??
          TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}
