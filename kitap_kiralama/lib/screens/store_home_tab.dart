import 'package:flutter/material.dart';
import 'package:kitap_kiralama/models/book.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';
import 'package:kitap_kiralama/widgets/book_card.dart';

class StoreHomeTab extends StatefulWidget {
  const StoreHomeTab({
    super.key,
    required this.books,
    required this.onBookSelected,
  });

  final List<Book> books;
  final ValueChanged<Book> onBookSelected;

  @override
  State<StoreHomeTab> createState() => _StoreHomeTabState();
}

class _StoreHomeTabState extends State<StoreHomeTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _selectedCategories = <String>{};
  BookSortOption _sortOption = BookSortOption.recommended;

  List<String> get _categories {
    final List<String> categories =
        widget.books.map((Book book) => book.category).toSet().toList()..sort();
    return categories;
  }

  bool get _hasFilters {
    return _selectedCategories.isNotEmpty ||
        _sortOption != BookSortOption.recommended;
  }

  List<Book> get _visibleBooks {
    final String normalizedQuery = _searchQuery.trim().toLowerCase();
    final List<Book> filteredBooks = widget.books.where((Book book) {
      final bool matchesQuery =
          normalizedQuery.isEmpty ||
          book.title.toLowerCase().contains(normalizedQuery) ||
          book.author.toLowerCase().contains(normalizedQuery) ||
          book.category.toLowerCase().contains(normalizedQuery);
      final bool matchesCategory =
          _selectedCategories.isEmpty ||
          _selectedCategories.contains(book.category);
      return matchesQuery && matchesCategory;
    }).toList();

    switch (_sortOption) {
      case BookSortOption.recommended:
        break;
      case BookSortOption.priceLowToHigh:
        filteredBooks.sort((Book a, Book b) => a.price.compareTo(b.price));
        break;
      case BookSortOption.priceHighToLow:
        filteredBooks.sort((Book a, Book b) => b.price.compareTo(a.price));
        break;
      case BookSortOption.titleAZ:
        filteredBooks.sort((Book a, Book b) => a.title.compareTo(b.title));
        break;
    }

    return filteredBooks;
  }

  Future<void> _openFilterSheet() async {
    final _StoreFilterResult? result =
        await showModalBottomSheet<_StoreFilterResult>(
          context: context,
          backgroundColor: AppPalette.surface,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (BuildContext context) {
            Set<String> tempCategories = Set<String>.from(_selectedCategories);
            BookSortOption tempSortOption = _sortOption;

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      20 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Filtreler',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kategori ve siralamayi buradan secin.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Kategoriler',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          ..._categories.map((String category) {
                            return CheckboxListTile(
                              value: tempCategories.contains(category),
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: AppPalette.forest,
                              title: Text(category),
                              onChanged: (bool? value) {
                                setModalState(() {
                                  if (value ?? false) {
                                    tempCategories.add(category);
                                  } else {
                                    tempCategories.remove(category);
                                  }
                                });
                              },
                            );
                          }),
                          const SizedBox(height: 12),
                          Text(
                            'Siralama',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          ...BookSortOption.values.map((BookSortOption option) {
                            final bool isSelected = tempSortOption == option;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(option.label),
                              leading: Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: isSelected
                                    ? AppPalette.forest
                                    : AppPalette.muted,
                              ),
                              onTap: () {
                                setModalState(() {
                                  tempSortOption = option;
                                });
                              },
                            );
                          }),
                          const SizedBox(height: 20),
                          Row(
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    tempCategories.clear();
                                    tempSortOption = BookSortOption.recommended;
                                  });
                                },
                                child: const Text('Temizle'),
                              ),
                              const Spacer(),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppPalette.forest,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(
                                    _StoreFilterResult(
                                      selectedCategories: tempCategories,
                                      sortOption: tempSortOption,
                                    ),
                                  );
                                },
                                child: const Text('Uygula'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );

    if (result == null) {
      return;
    }

    setState(() {
      _selectedCategories = result.selectedCategories;
      _sortOption = result.sortOption;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategories.clear();
      _sortOption = BookSortOption.recommended;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<Book> visibleBooks = _visibleBooks;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE6DED1)),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.search_rounded,
                              color: AppPalette.muted,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (String value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Kitap veya yazar ara',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _openFilterSheet,
                      child: Ink(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE6DED1)),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: AppPalette.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _hasFilters
                            ? '${visibleBooks.length} kitap listeleniyor • filtre aktif'
                            : '${visibleBooks.length} kitap listeleniyor',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    if (_hasFilters || _searchQuery.isNotEmpty)
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Temizle'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (visibleBooks.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppPalette.cardSoft,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.search_off_rounded,
                        size: 34,
                        color: AppPalette.forest,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Sonuc bulunamadi', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Arama metnini veya filtreleri degistirip tekrar deneyin.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                mainAxisExtent: 408,
              ),
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                final Book book = visibleBooks[index];
                return BookCard(
                  book: book,
                  onTap: () => widget.onBookSelected(book),
                );
              }, childCount: visibleBooks.length),
            ),
          ),
      ],
    );
  }
}

enum BookSortOption {
  recommended('Onerilen'),
  priceLowToHigh('Fiyat artan'),
  priceHighToLow('Fiyat azalan'),
  titleAZ('Basliga gore');

  const BookSortOption(this.label);

  final String label;
}

class _StoreFilterResult {
  const _StoreFilterResult({
    required this.selectedCategories,
    required this.sortOption,
  });

  final Set<String> selectedCategories;
  final BookSortOption sortOption;
}
