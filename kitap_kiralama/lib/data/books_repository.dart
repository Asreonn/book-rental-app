import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitap_kiralama/models/book.dart';

class BooksRepository {
  BooksRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<Book>> fetchBooks() async {
    final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
        .collection('books')
        .get();
    return snap.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> d) {
      final Map<String, dynamic> m = d.data();
      return Book(
        id: (m['id'] as String?) ?? d.id,
        title: (m['title'] as String?) ?? '',
        author: (m['author'] as String?) ?? '',
        category: (m['category'] as String?) ?? '',
        subtitle: (m['subtitle'] as String?) ?? '',
        description: (m['description'] as String?) ?? '',
        whyRead: (m['whyRead'] as String?) ?? '',
        readerNote: (m['readerNote'] as String?) ?? '',
        readingTime: (m['readingTime'] as String?) ?? '',
        edition: (m['edition'] as String?) ?? '',
        rating: (m['rating'] as String?) ?? '0.0',
        pages: (m['pages'] as num?)?.toInt() ?? 0,
        price: (m['price'] as num?)?.toInt() ?? 0,
        language: (m['language'] as String?) ?? '',
        publisher: (m['publisher'] as String?) ?? '',
        highlights: ((m['highlights'] as List<dynamic>?) ?? <dynamic>[])
            .map((dynamic e) => e.toString())
            .toList(),
        startColor: Color(
          (m['startColor'] as num?)?.toInt() ?? 0xFF1C7C8C,
        ).withAlpha(0xFF),
        endColor: Color(
          (m['endColor'] as num?)?.toInt() ?? 0xFF155765,
        ).withAlpha(0xFF),
        coverAsset: m['coverAsset'] as String?,
      );
    }).toList();
  }
}
