import 'package:flutter/material.dart';

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.subtitle,
    required this.description,
    required this.whyRead,
    required this.readerNote,
    required this.readingTime,
    required this.edition,
    required this.rating,
    required this.pages,
    required this.price,
    required this.language,
    required this.publisher,
    required this.highlights,
    required this.startColor,
    required this.endColor,
    this.coverAsset,
  });

  final String id;
  final String title;
  final String author;
  final String category;
  final String subtitle;
  final String description;
  final String whyRead;
  final String readerNote;
  final String readingTime;
  final String edition;
  final String rating;
  final int pages;
  final int price;
  final String language;
  final String publisher;
  final List<String> highlights;
  final Color startColor;
  final Color endColor;
  final String? coverAsset;

  String get priceLabel => '$price TL';
}
