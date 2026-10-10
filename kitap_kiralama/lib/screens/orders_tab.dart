import 'package:flutter/material.dart';
import 'package:kitap_kiralama/models/order_record.dart';
import 'package:kitap_kiralama/screens/order_detail_page.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';
import 'package:kitap_kiralama/widgets/order_status_pill.dart';
import 'package:kitap_kiralama/widgets/summary_row.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({
    super.key,
    required this.orders,
    required this.onContinueShopping,
  });

  final List<OrderRecord> orders;
  final VoidCallback onContinueShopping;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Gecmis Siparislerim', style: textTheme.headlineSmall),
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
                        color: AppPalette.cardSoft,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 40,
                        color: AppPalette.forest,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Henuz siparis yok', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Tamamlanan siparisler burada listelenecek.',
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
          Text('Gecmis Siparislerim', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '${orders.length} siparis kaydi bulunuyor',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
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
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext detailContext) {
                            return OrderDetailPage(order: order);
                          },
                        ),
                      );
                    },
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
                          const SizedBox(height: 14),
                          Text(order.bookTitles, style: textTheme.bodyLarge),
                          const SizedBox(height: 16),
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
