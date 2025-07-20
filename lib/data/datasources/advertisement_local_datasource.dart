//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/datasources/advertisement_local_datasource.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:sqflite/sqflite.dart';
import 'local_db.dart';
import '../models/advertisement_model.dart';

/// A data source for performing CRUD operations on the local
/// SQLite 'advertisements' table. Acts as the DAO layer
/// for AdvertisementModel.
class AdvertisementLocalDatasource {
  final LocalDatabase _db = LocalDatabase();

  /// Inserts a new [AdvertisementModel] into the 'advertisements' table.
  ///
  /// If an advertisement with the same primary key already exists,
  /// it will be replaced (ConflictAlgorithm.replace).
  Future<void> insertAdvertisement(AdvertisementModel advertisement) async {
    final db = await _db.database;
    await db.insert(
      'advertisements',
      advertisement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves a single [AdvertisementModel] by its [id].
  ///
  /// Returns null if no matching row is found.
  Future<AdvertisementModel?> getAdvertisementById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      'advertisements',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AdvertisementModel.fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves all [AdvertisementModel] rows from the 'advertisements' table.
  ///
  /// Returns an empty list if the table is empty.
  Future<List<AdvertisementModel>> getAllAdvertisements() async {
    final db = await _db.database;
    final result = await db.query('advertisements');
    return result
        .map((map) => AdvertisementModel.fromMap(map))
        .toList();
  }

  /// Deletes the advertisement row matching the given [id].
  ///
  /// If no row matches, nothing happens.
  Future<void> deleteAdvertisement(int id) async {
    final db = await _db.database;
    await db.delete(
      'advertisements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clears all rows from the 'advertisements' table.
  ///
  /// Use with care: this will remove all locally cached advertisements.
  Future<void> clearAll() async {
    final db = await _db.database;
    await db.delete('advertisements');
  }
}
