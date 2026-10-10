import 'package:flutter/material.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';

class DetailInfoTile extends StatelessWidget {
  const DetailInfoTile({
    super.key,
    required this.label,
    required this.value,
    this.dark = false,
  });

  final String label;
  final String value;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: 0.14)
            : AppPalette.cardSoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: dark
            ? Border.all(color: Colors.white.withValues(alpha: 0.16))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: dark
                  ? Colors.white.withValues(alpha: 0.78)
                  : AppPalette.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: dark ? Colors.white : AppPalette.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
