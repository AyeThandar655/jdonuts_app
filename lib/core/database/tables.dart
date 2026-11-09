import 'package:drift/drift.dart';

// Schema history
// v1: catalog (products, banners, sections, shops), member, tiers, rewards,
//     users (fake auth store).
// v2: cart_items (persistent cart).

@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  IntColumn get priceMmk => integer()();
  BoolColumn get isNew => boolean().withDefault(const Constant(false))();
  IntColumn get discountPercent => integer().nullable()();
  TextColumn get imageAsset => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('BannerRow')
class Banners extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get tag => text().nullable()();
  TextColumn get backgroundHex => text()();
  TextColumn get imageAsset => text()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('HomeSectionRow')
class HomeSections extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get emoji => text().nullable()();
  TextColumn get layout => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SectionProductRow')
class SectionProducts extends Table {
  TextColumn get sectionId => text().references(HomeSections, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {sectionId, productId};
}

@DataClassName('ShopRow')
class Shops extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get imageAsset => text()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TierRow')
class Tiers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get minPoints => integer()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MemberRow')
class Members extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get photoAsset => text()();
  TextColumn get tierId => text().references(Tiers, #id)();
  IntColumn get tierPoints => integer()();
  IntColumn get totalPoints => integer()();
  IntColumn get notificationCount => integer()();
  IntColumn get rewardsCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ChallengeRow')
class Challenges extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get progress => integer()();
  IntColumn get goal => integer()();
  IntColumn get rewardPoints => integer()();
  TextColumn get artwork => text()();
  TextColumn get imageAsset => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('GiftRow')
class Gifts extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get pointsCost => integer()();
  TextColumn get imageAsset => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Local user store behind the fake [AuthRepository].
@DataClassName('UserRow')
class Users extends Table {
  TextColumn get phone => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {phone};
}

/// Added in schema v2.
@DataClassName('CartItemRow')
class CartItems extends Table {
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get quantity => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {productId};
}
