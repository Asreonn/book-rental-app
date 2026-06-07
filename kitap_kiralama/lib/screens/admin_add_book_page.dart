import 'package:flutter/material.dart';
import 'package:kitap_kiralama/theme/app_palette.dart';

/// Admin'in yeni kitap eklemesini saglayan form. Temel alanlari ister,
/// kalan alanlara makul varsayilanlar verir ve "books" koleksiyonuna yazar.
class AdminAddBookPage extends StatefulWidget {
  const AdminAddBookPage({super.key, required this.onAdd});

  /// Form gonderildiginde kitap verisini Firestore'a yazar.
  final Future<void> Function(Map<String, dynamic> data) onAdd;

  @override
  State<AdminAddBookPage> createState() => _AdminAddBookPageState();
}

class _AdminAddBookPageState extends State<AdminAddBookPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _title = TextEditingController();
  final TextEditingController _author = TextEditingController();
  final TextEditingController _category = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _pages = TextEditingController();
  final TextEditingController _subtitle = TextEditingController();
  final TextEditingController _description = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _category.dispose();
    _price.dispose();
    _pages.dispose();
    _subtitle.dispose();
    _description.dispose();
    super.dispose();
  }

  String _slug(String input) {
    final String base = input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final String suffix = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(8);
    return base.isEmpty ? 'kitap-$suffix' : '$base-$suffix';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final String title = _title.text.trim();
    final String id = _slug(title);
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'title': title,
      'author': _author.text.trim(),
      'category': _category.text.trim().isEmpty
          ? 'Genel'
          : _category.text.trim(),
      'subtitle': _subtitle.text.trim(),
      'description': _description.text.trim(),
      'whyRead': '',
      'readerNote': '',
      'readingTime': '5 saat',
      'edition': '1. Baski',
      'rating': '4.5',
      'pages': int.tryParse(_pages.text.trim()) ?? 0,
      'price': int.tryParse(_price.text.trim()) ?? 0,
      'language': 'Turkce',
      'publisher': '',
      'highlights': <String>[],
      'startColor': 0xFF1C7C8C,
      'endColor': 0xFF155765,
    };

    try {
      await widget.onAdd(data);
      if (!mounted) return;
      setState(() => _saving = false);
      _formKey.currentState?.reset();
      for (final TextEditingController c in <TextEditingController>[
        _title,
        _author,
        _category,
        _price,
        _pages,
        _subtitle,
        _description,
      ]) {
        c.clear();
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('"$title" eklendi.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Eklenemedi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: <Widget>[
            Text('Yeni Kitap Ekle', style: textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Eklenen kitap aninda magazada gorunur.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            _field(_title, 'Kitap adi', required: true),
            _field(_author, 'Yazar', required: true),
            _field(_category, 'Kategori (orn. Roman)'),
            _field(
              _price,
              'Fiyat (TL)',
              keyboardType: TextInputType.number,
              required: true,
            ),
            _field(_pages, 'Sayfa sayisi', keyboardType: TextInputType.number),
            _field(_subtitle, 'Alt baslik'),
            _field(_description, 'Aciklama', maxLines: 4),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.forest,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Kitabi Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        validator: required
            ? (String? v) =>
                  (v == null || v.trim().isEmpty) ? 'Bu alan zorunlu' : null
            : null,
      ),
    );
  }
}
