//---------------------------------------------------------------------------
// File   : features/user/data/datasources/local/user_local_data_source.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'package:texas_buddy/features/user/data/dtos/user_profile_dto.dart';
import 'package:texas_buddy/features/user/domain/entities/user_profile.dart';

abstract class UserLocalDataSource {
  Future<UserProfile?> getUser();
  Future<void> upsert(UserProfile user);
  Future<void> clear();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  static const _dbName = 'texas_buddy.db';
  static const _table  = 'user_profile';

  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir  = await getDatabasesPath();
    final path = p.join(dir, _dbName);

    _db = await openDatabase(
      path,
      version: 3, // ⬅️ bump (v2: adresse, v3: registration/ip)
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_table(
            id TEXT PRIMARY KEY,
            email TEXT NOT NULL,
            first_name TEXT,
            last_name TEXT,
            nickname TEXT,
            address TEXT,
            city TEXT,
            state TEXT,
            zip_code TEXT,
            country TEXT,
            phone TEXT,
            registration_number TEXT,
            first_ip TEXT,
            second_ip TEXT,
            avatar_url TEXT,
            created_at TEXT
          )
        ''');
      },
      onUpgrade: (db, oldV, newV) async {
        Future<void> _addCol(String name, String type) async {
          try { await db.execute('ALTER TABLE $_table ADD COLUMN $name $type'); } catch (_) {}
        }
        if (oldV < 2) {
          await _addCol('address', 'TEXT');
          await _addCol('zip_code', 'TEXT');
          await _addCol('country', 'TEXT');
          await _addCol('phone', 'TEXT');
          await _addCol('city', 'TEXT');
          await _addCol('state', 'TEXT');
        }
        if (oldV < 3) {
          await _addCol('registration_number', 'TEXT');
          await _addCol('first_ip', 'TEXT');
          await _addCol('second_ip', 'TEXT');
        }
      },
    );
    return _db!;
  }

  // ------------------- REQUIRED METHODS -----------------------------------

  @override
  Future<UserProfile?> getUser() async {
    final db = await _open();
    final rows = await db.query(_table, limit: 1);
    if (rows.isEmpty) return null;
    return UserProfileDto.fromDb(rows.first).toDomain();
  }

  @override
  Future<void> upsert(UserProfile user) async {
    final db  = await _open();
    final dto = UserProfileDto(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      nickname: user.nickname,
      address: user.address,
      city: user.city,
      state: user.state,
      zipCode: user.zipCode,
      country: user.country,
      phone: user.phone,
      registrationNumber: user.registrationNumber,
      firstIp: user.firstIp,
      secondIp: user.secondIp,
      avatarUrl: user.avatarUrl,
      createdAt: user.createdAt,
    );
    await db.insert(
      _table,
      dto.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> clear() async {
    final db = await _open();
    await db.delete(_table);
  }

  // (Optionnel) petit utilitaire debug
  Future<Map<String, dynamic>> debugDump() async {
    final db = await _open();
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_table'),
    ) ?? 0;
    final rows = await db.query(_table, limit: 1);
    return {'count': count, 'firstRow': rows.isNotEmpty ? rows.first : null};
  }
}
