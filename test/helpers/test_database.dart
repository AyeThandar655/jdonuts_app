import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/seed_source.dart';

/// The real bundled seed, read from disk.
String readSeedJson() => File('assets/seed/seed.json').readAsStringSync();

/// A fresh in-memory database seeded like a first launch.
AppDatabase createTestDatabase({String? seedJson}) => AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
      seedSource: StringSeedSource(seedJson ?? readSeedJson()),
    );
