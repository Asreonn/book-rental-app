import 'package:flutter/material.dart';
import 'package:kitap_kiralama/models/book.dart';
import 'package:kitap_kiralama/models/order_record.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';
import 'package:kitap_kiralama/widgets/book_cover.dart';
import 'package:kitap_kiralama/widgets/summary_row.dart';

class CartTab extends StatelessWidget {
  const CartTab({
    super.key,
    required this.cartItems,
    required this.onRemove,
    required this.onContinueShopping,
    required this.onPlaceOrder,
  });

  final List<Book> cartItems;
  final ValueChanged<Book> onRemove;
  final VoidCallback onContinueShopping;
  final ValueChanged<OrderRecord> onPlaceOrder;

  int get totalPrice {
    return cartItems.fold<int>(0, (int value, Book book) => value + book.price);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (cartItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Sepet', style: textTheme.headlineSmall),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppPalette.accentSoft,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        size: 40,
                        color: AppPalette.accent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Sepetiniz simdilik bos', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Begendiginiz kitaplari ekleyin, siparisi tek adimda tamamlayin.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppPalette.forest,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: onContinueShopping,
                      child: const Text('Kitaplara Don'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Sepet', style: textTheme.headlineSmall),
              Text('${cartItems.length} kitap', style: textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: cartItems.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 14),
              itemBuilder: (BuildContext context, int index) {
                final Book book = cartItems[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 86,
                        child: BookCover(
                          book: book,
                          height: 124,
                          borderRadius: 20,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(book.title, style: textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Text(book.author, style: textTheme.bodyMedium),
                            const SizedBox(height: 14),
                            Text(
                              book.priceLabel,
                              style: textTheme.titleLarge?.copyWith(
                                color: AppPalette.forest,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => onRemove(book),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppPalette.deepForest,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: <Widget>[
                SummaryRow(
                  label: 'Ara Toplam',
                  value: '$totalPrice TL',
                  light: true,
                ),
                const SizedBox(height: 12),
                const SummaryRow(
                  label: 'Kargo',
                  value: 'Ucretsiz',
                  light: true,
                ),
                const SizedBox(height: 12),
                const SummaryRow(
                  label: 'Siparis Hazirlama',
                  value: 'Ayni gun',
                  light: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Color(0x335C7A6C), height: 1),
                ),
                SummaryRow(
                  label: 'Toplam',
                  value: '$totalPrice TL',
                  light: true,
                  strong: true,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPalette.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      final String orderCode =
                          'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                      final OrderRecord order = OrderRecord(
                        orderCode: orderCode,
                        items: List<Book>.from(cartItems),
                        totalPrice: totalPrice,
                        createdAt: DateTime.now(),
                      );

                      await showDialog<void>(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            backgroundColor: AppPalette.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            title: const Text('Siparis Verildi'),
                            content: Text(
                              '$orderCode numarali siparisiniz alindi.\n${order.items.length} kitap icin toplam ${order.totalPrice} TL onaylandi.',
                              style: textTheme.bodyLarge,
                            ),
                            actions: <Widget>[
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppPalette.forest,
                                ),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text('Tamam'),
                              ),
                            ],
                          );
                        },
                      );

                      onPlaceOrder(order);

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Siparisiniz olusturuldu.'),
                        ),
                      );
                    },
                    child: const Text('Siparis Ver'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
