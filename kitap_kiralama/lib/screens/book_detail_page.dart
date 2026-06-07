import 'package:flutter/material.dart';
import 'package:kitap_kiralama/models/book.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';
import 'package:kitap_kiralama/widgets/book_cover.dart';
import 'package:kitap_kiralama/widgets/detail_info_tile.dart';
import 'package:kitap_kiralama/widgets/detail_section_card.dart';
import 'package:kitap_kiralama/widgets/detail_stat_card.dart';
import 'package:kitap_kiralama/widgets/highlight_tag.dart';

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({
    super.key,
    required this.book,
    this.isInCart = false,
    this.onAddToCart,
    this.onOpenCart,
    this.previewMode = false,
  });

  final Book book;
  final bool isInCart;
  final Future<bool> Function()? onAddToCart;
  final VoidCallback? onOpenCart;

  /// Admin magazada gezerken sadece onizleme yapar; satin alma cubugu gizlenir.
  final bool previewMode;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late bool _isInCart;

  @override
  void initState() {
    super.initState();
    _isInCart = widget.isInCart;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Book book = widget.book;

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: AppPalette.background,
            elevation: 0,
            pinned: true,
            surfaceTintColor: Colors.transparent,
            title: const Text('Kitap Detayi'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      gradient: const LinearGradient(
                        colors: <Color>[
                          AppPalette.deepForest,
                          AppPalette.forest,
                          AppPalette.accent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Hero(
                          tag: book.id,
                          child: BookCover(
                            book: book,
                            height: 380,
                            borderRadius: 28,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: book.highlights
                              .map(
                                (String item) =>
                                    HighlightTag(label: item, light: true),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    book.category.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    book.title,
                                    style: textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    book.author,
                                    style: textTheme.titleMedium?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.88,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    book.subtitle,
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                book.priceLabel,
                                style: textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      DetailStatCard(
                        icon: Icons.auto_stories_rounded,
                        label: 'Sayfa',
                        value: '${book.pages}',
                      ),
                      DetailStatCard(
                        icon: Icons.schedule_rounded,
                        label: 'Okuma',
                        value: book.readingTime,
                      ),
                      DetailStatCard(
                        icon: Icons.star_rounded,
                        label: 'Puan',
                        value: book.rating,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  DetailSectionCard(
                    title: 'Konu Ozeti',
                    content: book.description,
                  ),
                  const SizedBox(height: 18),
                  DetailSectionCard(
                    title: 'Neden Okumali?',
                    content: book.whyRead,
                    emphasize: true,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Kitap Bilgileri', style: textTheme.titleLarge),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: <Widget>[
                            DetailInfoTile(label: 'Yazar', value: book.author),
                            DetailInfoTile(
                              label: 'Yayinevi',
                              value: book.publisher,
                            ),
                            DetailInfoTile(label: 'Dil', value: book.language),
                            DetailInfoTile(label: 'Baski', value: book.edition),
                            DetailInfoTile(label: 'Tur', value: book.category),
                            const DetailInfoTile(
                              label: 'Teslimat',
                              value: 'Ayni gun kargo',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.previewMode
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Satis Fiyati',
                            style: TextStyle(
                              color: AppPalette.muted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.priceLabel,
                            style:
                                textTheme.titleLarge?.copyWith(
                                  color: AppPalette.forest,
                                ) ??
                                const TextStyle(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _isInCart
                              ? AppPalette.accent
                              : AppPalette.forest,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          if (_isInCart) {
                            widget.onOpenCart?.call();
                            Navigator.of(context).pop();
                            return;
                          }

                          final bool added =
                              await widget.onAddToCart?.call() ?? false;
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                added
                                    ? '${book.title} sepete eklendi.'
                                    : '${book.title} zaten sepette.',
                              ),
                            ),
                          );

                          if (added) {
                            setState(() {
                              _isInCart = true;
                            });
                          }
                        },
                        child: Text(_isInCart ? 'Sepete Git' : 'Sepete Ekle'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
