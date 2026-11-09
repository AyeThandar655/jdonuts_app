import '../../../core/domain/image_ref.dart';

final class Product {
  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.priceMmk,
    required this.isNew,
    required this.image,
    required this.description,
    this.discountPercent,
  });

  final String id;
  final String code;
  final String name;

  /// Whole kyat; MMK has no minor unit in practice.
  final int priceMmk;
  final bool isNew;
  final int? discountPercent;
  final ImageRef image;
  final String description;

  bool get hasDiscount => (discountPercent ?? 0) > 0;
}
