import 'package:flutter/material.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';

class HighlightTag extends StatelessWidget {
  const HighlightTag({super.key, required this.label, this.light = false});

  final String label;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: light
            ? Colors.white.withValues(alpha: 0.16)
            : AppPalette.accentSoft,
        borderRadius: BorderRadius.circular(999),
        border: light
            ? Border.all(color: Colors.white.withValues(alpha: 0.18))
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: light ? Colors.white : AppPalette.forest,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
