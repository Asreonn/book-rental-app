import 'package:flutter/material.dart';
import 'package:kitap_kiralama/app/app_config.dart';
import 'package:kitap_kiralama/models/book.dart';
import 'package:kitap_kiralama/models/order_record.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';
import 'package:kitap_kiralama/widgets/book_cover.dart';
import 'package:kitap_kiralama/widgets/detail_info_tile.dart';
import 'package:kitap_kiralama/widgets/order_status_pill.dart';

/// Admin'in tek bir siparisin tum detaylarini gordugu ve kargo durumunu
/// bir acilir liste (combobox) ile degistirdigi ekran.
class AdminOrderDetailPage extends StatefulWidget {
  const AdminOrderDetailPage({
    super.key,
    required this.order,
    required this.onStatusChanged,
  });

  final OrderRecord order;

  /// Yeni durum secildiginde cagrilir; Firestore guncellemesini yapar.
  final Future<void> Function(OrderRecord order, String status) onStatusChanged;

  @override
  State<AdminOrderDetailPage> createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends State<AdminOrderDetailPage> {
  late String _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
  }

  Future<void> _onChanged(String? value) async {
    if (value == null || value == _status) return;
    setState(() => _saving = true);
    try {
      await widget.onStatusChanged(widget.order, value);
      if (!mounted) return;
      setState(() {
        _status = value;
        _saving = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Durum guncellendi: $value')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Guncellenemedi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final OrderRecord order = widget.order;

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
                OrderStatusPill(label: _status, inverse: true),
                const SizedBox(height: 18),
                Text(
                  order.orderCode,
                  style: textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Siparis ${order.createdLabel} tarihinde olusturuldu.',
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
                Text('Musteri', style: textTheme.titleLarge),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.person_outline,
                      size: 20,
                      color: AppPalette.forest,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.userEmail.isEmpty
                            ? 'Bilinmeyen kullanici'
                            : order.userEmail,
                        style: textTheme.bodyLarge,
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
                Text('Kargo Durumu', style: textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'Durumu degistirin; musterinin siparisi aninda guncellenir.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppPalette.cardSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _status,
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(16),
                            items: kOrderStatuses
                                .map(
                                  (String s) => DropdownMenuItem<String>(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: _saving ? null : _onChanged,
                          ),
                        ),
                      ),
                      if (_saving)
                        const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
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
                if (order.items.isEmpty)
                  Text('Kitap bilgisi yok', style: textTheme.bodyMedium)
                else
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
                                  Text(
                                    item.title,
                                    style: textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.author,
                                    style: textTheme.bodyMedium,
                                  ),
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
