import 'package:flutter/material.dart';
import 'package:kitap_kiralama/models/book.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.book,
    required this.height,
    this.borderRadius = 26,
    this.compact = false,
  });

  final Book book;
  final double height;
  final double borderRadius;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[book.startColor, book.endColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            if (book.coverAsset != null)
              Image.asset(
                book.coverAsset!,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) => _CoverFallback(compact: compact),
              )
            else
              _CoverFallback(compact: compact),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.03),
                    Colors.black.withValues(alpha: 0.18),
                  ],
                ),
              ),
            ),
            Positioned(
              top: compact ? 10 : 14,
              left: compact ? 10 : 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  book.category,
                  style: TextStyle(
                    color: AppPalette.ink,
                    fontSize: compact ? 10 : 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.menu_book_rounded,
        size: compact ? 36 : 54,
        color: Colors.white.withValues(alpha: 0.8),
      ),
    );
  }
}
