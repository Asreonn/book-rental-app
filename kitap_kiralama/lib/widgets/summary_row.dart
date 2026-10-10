import 'package:flutter/material.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.light = false,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool light;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final Color color = light ? Colors.white : AppPalette.ink;
    final Color secondary = light ? const Color(0xFFBFD3C6) : AppPalette.muted;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: strong ? color : secondary,
            fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: strong ? 18 : 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
