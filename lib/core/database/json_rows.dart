import 'package:drift/drift.dart';

import 'app_database.dart';

/// Parses the wire / seed JSON shapes into Drift companions.
///
/// The bundled seed file and the optional mock server share these shapes, so
/// both paths write identical rows into the local database.
typedef JsonMap = Map<String, dynamic>;

List<JsonMap> jsonList(Object? value) =>
    (value as List<dynamic>? ?? const <dynamic>[]).cast<JsonMap>();

ProductsCompanion productFromJson(JsonMap json) => ProductsCompanion.insert(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      priceMmk: json['priceMmk'] as int,
      isNew: Value(json['isNew'] as bool? ?? false),
      discountPercent: Value(json['discountPercent'] as int?),
      imageAsset: json['imageAsset'] as String,
      imageUrl: Value(json['imageUrl'] as String?),
      description: json['description'] as String,
    );

BannersCompanion bannerFromJson(JsonMap json, int sortOrder) =>
    BannersCompanion.insert(
      id: json['id'] as String,
      title: json['title'] as String,
      tag: Value(json['tag'] as String?),
      backgroundHex: json['backgroundHex'] as String,
      imageAsset: json['imageAsset'] as String,
      imageUrl: Value(json['imageUrl'] as String?),
      sortOrder: sortOrder,
    );

HomeSectionsCompanion sectionFromJson(JsonMap json, int sortOrder) =>
    HomeSectionsCompanion.insert(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: Value(json['emoji'] as String?),
      layout: json['layout'] as String,
      sortOrder: sortOrder,
    );

List<SectionProductsCompanion> sectionProductsFromJson(JsonMap json) {
  final sectionId = json['id'] as String;
  final ids = (json['productIds'] as List<dynamic>).cast<String>();
  return [
    for (var i = 0; i < ids.length; i++)
      SectionProductsCompanion.insert(
        sectionId: sectionId,
        productId: ids[i],
        sortOrder: i,
      ),
  ];
}

ShopsCompanion shopFromJson(JsonMap json, int sortOrder) =>
    ShopsCompanion.insert(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      imageAsset: json['imageAsset'] as String,
      imageUrl: Value(json['imageUrl'] as String?),
      sortOrder: sortOrder,
    );

TiersCompanion tierFromJson(JsonMap json, int sortOrder) =>
    TiersCompanion.insert(
      id: json['id'] as String,
      name: json['name'] as String,
      minPoints: json['minPoints'] as int,
      sortOrder: sortOrder,
    );

MembersCompanion memberFromJson(JsonMap json) => MembersCompanion.insert(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      photoAsset: json['photoAsset'] as String,
      tierId: json['tierId'] as String,
      tierPoints: json['tierPoints'] as int,
      totalPoints: json['totalPoints'] as int,
      notificationCount: json['notificationCount'] as int,
      rewardsCount: json['rewardsCount'] as int,
    );

ChallengesCompanion challengeFromJson(JsonMap json, int sortOrder) =>
    ChallengesCompanion.insert(
      id: json['id'] as String,
      title: json['title'] as String,
      progress: json['progress'] as int,
      goal: json['goal'] as int,
      rewardPoints: json['rewardPoints'] as int,
      artwork: json['artwork'] as String,
      imageAsset: json['imageAsset'] as String,
      sortOrder: sortOrder,
    );

GiftsCompanion giftFromJson(JsonMap json, int sortOrder) =>
    GiftsCompanion.insert(
      id: json['id'] as String,
      title: json['title'] as String,
      pointsCost: json['pointsCost'] as int,
      imageAsset: json['imageAsset'] as String,
      sortOrder: sortOrder,
    );

/// Maps every element of [items] with its index, for `sortOrder` columns.
List<R> indexedRows<R>(List<JsonMap> items, R Function(JsonMap, int) map) => [
      for (var i = 0; i < items.length; i++) map(items[i], i),
    ];
