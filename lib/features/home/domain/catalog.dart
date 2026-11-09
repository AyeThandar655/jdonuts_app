import '../../../core/domain/image_ref.dart';
import '../../product/domain/product.dart';

/// A promotional card in the Home carousel.
final class PromoBanner {
  const PromoBanner({
    required this.id,
    required this.title,
    required this.backgroundHex,
    required this.image,
    this.tag,
  });

  final String id;
  final String title;
  final String? tag;
  final String backgroundHex;
  final ImageRef image;
}

/// How a Home section draws its product tiles.
enum SectionLayout {
  /// Landscape photo cards (Seasonal specials).
  wide,

  /// Tall white cards (Popular).
  tall,

  /// Square white cards (Order again).
  square;

  static SectionLayout fromName(String name) => SectionLayout.values
      .firstWhere((l) => l.name == name, orElse: () => SectionLayout.square);
}

final class HomeSection {
  const HomeSection({
    required this.id,
    required this.title,
    required this.layout,
    required this.products,
    this.emoji,
  });

  final String id;
  final String title;
  final String? emoji;
  final SectionLayout layout;
  final List<Product> products;
}

final class Shop {
  const Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.image,
  });

  final String id;
  final String name;
  final String address;
  final ImageRef image;
}
