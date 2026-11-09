import 'package:flutter/services.dart';

/// Supplies the JSON used to seed the database on first launch.
abstract interface class SeedSource {
  Future<String> load();
}

/// Reads the seed bundled with the app, so a first launch needs no network.
final class AssetSeedSource implements SeedSource {
  const AssetSeedSource({AssetBundle? bundle, this.path = defaultPath})
      : _bundle = bundle;

  static const String defaultPath = 'assets/seed/seed.json';

  final AssetBundle? _bundle;
  final String path;

  @override
  Future<String> load() => (_bundle ?? rootBundle).loadString(path);
}

/// In-memory seed for tests.
final class StringSeedSource implements SeedSource {
  const StringSeedSource(this.json);
  final String json;

  @override
  Future<String> load() async => json;
}
