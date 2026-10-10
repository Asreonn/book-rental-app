import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitap_kiralama/data/books_repository.dart';
import 'package:kitap_kiralama/data/user_repository.dart';
import 'package:kitap_kiralama/models/book.dart';
import 'package:kitap_kiralama/models/order_record.dart';
import 'package:kitap_kiralama/screens/book_detail_page.dart';
import 'package:kitap_kiralama/screens/cart_tab.dart';
import 'package:kitap_kiralama/screens/orders_tab.dart';
import 'package:kitap_kiralama/screens/store_home_tab.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';
import 'package:kitap_kiralama/widgets/cart_icon_badge.dart';

class BookStoreApp extends StatefulWidget {
  const BookStoreApp({super.key});

  @override
  State<BookStoreApp> createState() => _BookStoreAppState();
}

class _BookStoreAppState extends State<BookStoreApp> {
  final BooksRepository _booksRepo = BooksRepository();
  final UserRepository _userRepo = UserRepository();

  int _selectedIndex = 0;
  List<Book> _books = <Book>[];
  Map<String, Book> _booksById = <String, Book>{};
  List<Book> _cart = <Book>[];
  List<OrderRecord> _orders = <OrderRecord>[];
  bool _loading = true;
  String? _loadError;

  StreamSubscription<List<String>>? _cartSub;
  StreamSubscription<List<OrderRecord>>? _ordersSub;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _cartSub?.cancel();
    _ordersSub?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final List<Book> books = await _booksRepo.fetchBooks();
      final Map<String, Book> byId = <String, Book>{
        for (final Book b in books) b.id: b,
      };
      if (!mounted) return;
      setState(() {
        _books = books;
        _booksById = byId;
        _loading = false;
      });

      _cartSub = _userRepo.watchCartIds().listen((List<String> ids) {
        if (!mounted) return;
        setState(() {
          _cart = <Book>[
            for (final String id in ids)
              if (_booksById[id] != null) _booksById[id]!,
          ];
        });
      });

      _ordersSub = _userRepo.watchOrders(_booksById).listen((
        List<OrderRecord> orders,
      ) {
        if (!mounted) return;
        setState(() => _orders = orders);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  bool _isInCart(Book book) => _cart.any((Book item) => item.id == book.id);

  Future<bool> _addToCart(Book book) async {
    if (_isInCart(book)) return false;
    final List<String> next = <String>[..._cart.map((Book b) => b.id), book.id];
    await _userRepo.setCart(next);
    return true;
  }

  Future<void> _removeFromCart(Book book) async {
    final List<String> next = _cart
        .where((Book b) => b.id != book.id)
        .map((Book b) => b.id)
        .toList();
    await _userRepo.setCart(next);
  }

  void _openCart() => setState(() => _selectedIndex = 1);
  void _openBooks() => setState(() => _selectedIndex = 0);

  Future<void> _completeOrder(OrderRecord order) async {
    await _userRepo.placeOrder(order);
    if (!mounted) return;
    setState(() => _selectedIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext appContext) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppPalette.surface,
            elevation: 0,
            title: const Text(
              'Kitap Dukkani',
              style: TextStyle(color: AppPalette.ink),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.logout, color: AppPalette.ink),
                tooltip: 'Cikis',
                onPressed: () => FirebaseAuth.instance.signOut(),
              ),
            ],
          ),
          body: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Veri yuklenemedi:\n$_loadError',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _bootstrap,
                            child: const Text('Tekrar dene'),
                          ),
                        ],
                      ),
                    ),
                  )
                : IndexedStack(
                    index: _selectedIndex,
                    children: <Widget>[
                      StoreHomeTab(
                        books: _books,
                        onBookSelected: (Book book) {
                          Navigator.of(appContext).push(
                            MaterialPageRoute<void>(
                              builder: (BuildContext detailContext) {
                                return BookDetailPage(
                                  book: book,
                                  isInCart: _isInCart(book),
                                  onAddToCart: () async {
                                    return _addToCart(book);
                                  },
                                  onOpenCart: _openCart,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      CartTab(
                        cartItems: _cart,
                        onRemove: _removeFromCart,
                        onContinueShopping: _openBooks,
                        onPlaceOrder: _completeOrder,
                      ),
                      OrdersTab(
                        orders: _orders,
                        onContinueShopping: _openBooks,
                      ),
                    ],
                  ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) =>
                setState(() => _selectedIndex = index),
            height: 74,
            backgroundColor: AppPalette.surface,
            indicatorColor: AppPalette.accentSoft,
            destinations: <Widget>[
              const NavigationDestination(
                icon: Icon(Icons.grid_view_rounded),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Kitaplar',
              ),
              NavigationDestination(
                icon: CartIconBadge(count: _cart.length, isCompact: true),
                selectedIcon: CartIconBadge(
                  count: _cart.length,
                  isCompact: true,
                ),
                label: 'Sepet',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_rounded),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'Siparislerim',
              ),
            ],
          ),
        );
      },
    );
  }
}
