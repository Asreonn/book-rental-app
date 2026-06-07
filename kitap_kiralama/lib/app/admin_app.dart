import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitap_kiralama/data/admin_repository.dart';
import 'package:kitap_kiralama/data/books_repository.dart';
import 'package:kitap_kiralama/models/book.dart';
import 'package:kitap_kiralama/models/order_record.dart';
import 'package:kitap_kiralama/screens/admin_add_book_page.dart';
import 'package:kitap_kiralama/screens/admin_order_detail_page.dart';
import 'package:kitap_kiralama/screens/book_detail_page.dart';
import 'package:kitap_kiralama/screens/store_home_tab.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';
import 'package:kitap_kiralama/widgets/order_status_pill.dart';
import 'package:kitap_kiralama/widgets/summary_row.dart';

/// Admin hesabiyla giris yapildiginda gosterilen yonetici paneli.
/// Uc sekme icerir: tum siparisler, magaza onizleme ve yeni kitap ekleme.
class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  final BooksRepository _booksRepo = BooksRepository();
  final AdminRepository _adminRepo = AdminRepository();

  int _selectedIndex = 0;
  List<Book> _books = <Book>[];
  Map<String, Book> _booksById = <String, Book>{};
  List<OrderRecord> _orders = <OrderRecord>[];
  bool _loading = true;
  String? _loadError;

  StreamSubscription<List<OrderRecord>>? _ordersSub;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      await _loadBooks();
      _ordersSub = _adminRepo
          .watchAllOrders(_booksById)
          .listen(
            (List<OrderRecord> orders) {
              if (!mounted) return;
              setState(() {
                _orders = orders;
                _loading = false;
              });
            },
            onError: (Object e) {
              if (!mounted) return;
              setState(() {
                _loadError = e.toString();
                _loading = false;
              });
            },
          );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadBooks() async {
    final List<Book> books = await _booksRepo.fetchBooks();
    if (!mounted) return;
    setState(() {
      _books = books;
      _booksById = <String, Book>{for (final Book b in books) b.id: b};
    });
  }

  Future<void> _changeStatus(OrderRecord order, String status) {
    return _adminRepo.updateStatus(order, status);
  }

  Future<void> _addBook(Map<String, dynamic> data) async {
    await _adminRepo.addBook(data);
    await _loadBooks();
  }

  void _openOrderDetail(OrderRecord order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            AdminOrderDetailPage(order: order, onStatusChanged: _changeStatus),
      ),
    );
  }

  void _openBookPreview(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookDetailPage(book: book, previewMode: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> titles = <String>[
      'Yonetici - Siparisler',
      'Yonetici - Magaza',
      'Yonetici - Kitap Ekle',
    ];

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        backgroundColor: AppPalette.surface,
        elevation: 0,
        title: Text(
          titles[_selectedIndex],
          style: const TextStyle(color: AppPalette.ink),
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
            ? _ErrorView(message: _loadError!, onRetry: _bootstrap)
            : IndexedStack(
                index: _selectedIndex,
                children: <Widget>[
                  _OrdersTab(orders: _orders, onOpen: _openOrderDetail),
                  StoreHomeTab(books: _books, onBookSelected: _openBookPreview),
                  AdminAddBookPage(onAdd: _addBook),
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
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Siparisler',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_rounded),
            label: 'Magaza',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_rounded),
            label: 'Kitap Ekle',
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Siparisler yuklenemedi:\n$message',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Tekrar dene')),
          ],
        ),
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({required this.orders, required this.onOpen});

  final List<OrderRecord> orders;
  final void Function(OrderRecord order) onOpen;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (orders.isEmpty) {
      return Center(
        child: Text('Henuz siparis yok', style: textTheme.titleLarge),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Tum Siparisler', style: textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            '${orders.length} siparis bulunuyor',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 14),
              itemBuilder: (BuildContext context, int index) {
                final OrderRecord order = orders[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(26),
                    onTap: () => onOpen(order),
                    child: Ink(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      order.orderCode,
                                      style: textTheme.titleMedium?.copyWith(
                                        color: AppPalette.forest,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.createdLabel,
                                      style: textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              OrderStatusPill(label: order.statusLabel),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              const Icon(
                                Icons.person_outline,
                                size: 18,
                                color: AppPalette.muted,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  order.userEmail.isEmpty
                                      ? 'Bilinmeyen kullanici'
                                      : order.userEmail,
                                  style: textTheme.bodyLarge,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppPalette.muted,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: SummaryRow(
                                  label: 'Kitap Sayisi',
                                  value: '${order.items.length}',
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: SummaryRow(
                                  label: 'Toplam',
                                  value: '${order.totalPrice} TL',
                                  strong: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
