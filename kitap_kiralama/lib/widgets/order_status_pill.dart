import 'package:flutter/material.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';

class OrderStatusPill extends StatelessWidget {
  const OrderStatusPill({super.key, required this.label, this.inverse = false});

  final String label;
  final bool inverse;

  /// Duruma gore arka plan ve metin rengi secer.
  Color get _accent {
    switch (label) {
      case 'Teslim Edildi':
        return const Color(0xFF2E7D32);
      case 'Kargoya Verildi':
        return const Color(0xFF1565C0);
      case 'Hazirlaniyor':
        return AppPalette.accent;
      case 'Onay Bekliyor':
      default:
        return const Color(0xFFB26A00);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: inverse
            ? Colors.white.withValues(alpha: 0.16)
            : _accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: inverse
            ? Border.all(color: Colors.white.withValues(alpha: 0.18))
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: inverse ? Colors.white : _accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
