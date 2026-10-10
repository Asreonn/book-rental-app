import 'package:flutter/material.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';

class DetailSectionCard extends StatelessWidget {
  const DetailSectionCard({
    super.key,
    required this.title,
    required this.content,
    this.emphasize = false,
  });

  final String title;
  final String content;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: emphasize ? AppPalette.cardSoft : Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(content, style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}
