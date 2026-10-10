import 'package:flutter/material.dart';
import 'package:kitap_kiralama/models/book.dart';
import 'package:kitap_kiralama/models/order_record.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';
import 'package:kitap_kiralama/widgets/book_cover.dart';
import 'package:kitap_kiralama/widgets/detail_info_tile.dart';
import 'package:kitap_kiralama/widgets/order_status_pill.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.order});

  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        backgroundColor: AppPalette.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Siparis Detayi'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
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
                OrderStatusPill(label: order.statusLabel, inverse: true),
                const SizedBox(height: 18),
                Text(
                  order.orderCode,
                  style: textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Siparis ${order.createdLabel} tarihinde olusturuldu. Takip kodunuz ${order.trackingCode}.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DetailInfoTile(
                        label: 'Kitap',
                        value: '${order.items.length} adet',
                        dark: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DetailInfoTile(
                        label: 'Toplam',
                        value: '${order.totalPrice} TL',
                        dark: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Siparisteki Kitaplar', style: textTheme.titleLarge),
                const SizedBox(height: 16),
                ...order.items.map((Book item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppPalette.cardSoft.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 72,
                            child: BookCover(
                              book: item,
                              height: 104,
                              borderRadius: 18,
                              compact: true,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(item.title, style: textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(item.author, style: textTheme.bodyMedium),
                                const SizedBox(height: 8),
                                Text(
                                  item.priceLabel,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: AppPalette.forest,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
