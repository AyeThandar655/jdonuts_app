import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/auth_entities.dart';

/// Local persistence for registered users (the fake back end's "accounts").
abstract interface class UserStore {
  Future<User?> findByPhone(String phone);
  Future<void> insert(User user);
}

final class DriftUserStore implements UserStore {
  DriftUserStore(this._db);
  final AppDatabase _db;

  @override
  Future<User?> findByPhone(String phone) async {
    final query = _db.select(_db.users)..where((u) => u.phone.equals(phone));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toUser(row);
  }

  @override
  Future<void> insert(User user) => _db.into(_db.users).insert(
        UsersCompanion.insert(
          phone: user.phone,
          firstName: user.firstName,
          lastName: Value(user.lastName),
          dateOfBirth: user.dateOfBirth,
          createdAt: DateTime.now(),
        ),
      );

  User _toUser(UserRow row) => User(
        phone: row.phone,
        firstName: row.firstName,
        lastName: row.lastName,
        dateOfBirth: row.dateOfBirth,
      );
}

/// Map-backed store for tests.
final class InMemoryUserStore implements UserStore {
  final Map<String, User> _users = {};

  @override
  Future<User?> findByPhone(String phone) async => _users[phone];

  @override
  Future<void> insert(User user) async => _users[user.phone] = user;
}
