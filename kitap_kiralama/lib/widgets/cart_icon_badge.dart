import 'package:flutter/material.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';

class CartIconBadge extends StatelessWidget {
  const CartIconBadge({super.key, required this.count, this.isCompact = false});

  final int count;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final double size = isCompact ? 26 : 46;

    return SizedBox(
      width: size + 10,
      height: size + 10,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isCompact ? Colors.transparent : Colors.white,
              borderRadius: BorderRadius.circular(isCompact ? 0 : 16),
              border: isCompact
                  ? null
                  : Border.all(color: const Color(0xFFE7E0D5)),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: AppPalette.ink,
              size: isCompact ? 24 : 22,
            ),
          ),
          if (count > 0)
            Positioned(
              right: 0,
              top: -2,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppPalette.accent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppPalette.surface, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
