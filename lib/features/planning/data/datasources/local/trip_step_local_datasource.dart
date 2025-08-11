//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/datasources/local/trip_step_local_datasource.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:sqflite/sqflite.dart';
import '../../../../../core/database/local_db.dart';
import '../../models/trip_step_model.dart';

/// A data source for performing CRUD operations on the local
/// SQLite 'trip_steps' table. Acts as the DAO layer for TripStepModel.
class TripStepLocalDatasource {
  final LocalDatabase _db = LocalDatabase();

  /// Inserts a new [TripStepModel] into the 'trip_steps' table.
  ///
  /// If an entry with the same primary key already exists,
  /// it will be replaced (ConflictAlgorithm.replace).
  Future<void> insertTripStep(TripStepModel tripStep) async {
    final db = await _db.database;
    await db.insert(
      'trip_steps',
      tripStep.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves a single [TripStepModel] by its [id].
  ///
  /// Returns null if no matching row is found.
  Future<TripStepModel?> getTripStepById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      'trip_steps',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return TripStepModel.fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves all [TripStepModel] rows associated with a given [tripDayId].
  ///
  /// Returns an empty list if no trip steps are found.
  Future<List<TripStepModel>> getTripStepsByTripDayId(int tripDayId) async {
    final db = await _db.database;
    final result = await db.query(
      'trip_steps',
      where: 'trip_day_id = ?',
      whereArgs: [tripDayId],
      orderBy: 'start_time',
    );
    return result.map((map) => TripStepModel.fromMap(map)).toList();
  }

  /// Deletes the trip step row matching the given [id].
  ///
  /// If no row matches, nothing happens.
  Future<void> deleteTripStep(int id) async {
    final db = await _db.database;
    await db.delete(
      'trip_steps',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clears all rows from the 'trip_steps' table.
  ///
  /// Use with care: this will remove all locally cached trip steps.
  Future<void> clearAll() async {
    final db = await _db.database;
    await db.delete('trip_steps');
  }
}
