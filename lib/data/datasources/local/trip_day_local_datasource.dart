//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/datasources/local/trip_day_local_datasource.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:sqflite/sqflite.dart';
import 'local_db.dart';
import '../../models/trip_day_model.dart';

/// A data source for performing CRUD operations on the local
/// SQLite 'trip_days' table. Acts as the DAO layer for TripDayModel.
class TripDayLocalDatasource {
  final LocalDatabase _db = LocalDatabase();

  /// Inserts a new [TripDayModel] into the 'trip_days' table.
  ///
  /// If an entry with the same primary key already exists,
  /// it will be replaced (ConflictAlgorithm.replace).
  Future<void> insertTripDay(TripDayModel tripDay) async {
    final db = await _db.database;
    await db.insert(
      'trip_days',
      tripDay.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves a single [TripDayModel] by its [id].
  ///
  /// Returns null if no matching row is found.
  Future<TripDayModel?> getTripDayById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      'trip_days',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return TripDayModel.fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves all [TripDayModel] rows associated with a given [tripId].
  ///
  /// Returns an empty list if no trip days are found.
  Future<List<TripDayModel>> getTripDaysByTripId(int tripId) async {
    final db = await _db.database;
    final result = await db.query(
      'trip_days',
      where: 'trip_id = ?',
      whereArgs: [tripId],
    );
    return result.map((map) => TripDayModel.fromMap(map)).toList();
  }

  /// Deletes the trip day row matching the given [id].
  ///
  /// If no row matches, nothing happens.
  Future<void> deleteTripDay(int id) async {
    final db = await _db.database;
    await db.delete(
      'trip_days',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clears all rows from the 'trip_days' table.
  ///
  /// Use with care: this will remove all locally cached trip days.
  Future<void> clearAll() async {
    final db = await _db.database;
    await db.delete('trip_days');
  }
}
