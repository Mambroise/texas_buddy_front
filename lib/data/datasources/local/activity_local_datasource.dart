//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/datasources/local/activity_local_datasource.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:sqflite/sqflite.dart';
import 'local_db.dart';
import '../../models/activity_model.dart';

/// A data source for performing CRUD operations on the local
/// SQLite 'activities' table. Acts as the DAO (Data Access Object)
/// layer of your app’s data tier.
class ActivityLocalDatasource {
  final LocalDatabase _db = LocalDatabase();

  /// Inserts a new [ActivityModel] into the 'activities' table.
  ///
  /// If an activity with the same primary key already exists,
  /// it will be replaced (ConflictAlgorithm.replace).
  Future<void> insertActivity(ActivityModel activity) async {
    final db = await _db.database;
    await db.insert(
      'activities',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves a single [ActivityModel] by its [id].
  ///
  /// Returns null if no matching row is found.
  Future<ActivityModel?> getActivityById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ActivityModel.fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves all [ActivityModel] rows from the 'activities' table.
  ///
  /// Returns an empty list if the table is empty.
  Future<List<ActivityModel>> getAllActivities() async {
    final db = await _db.database;
    final result = await db.query('activities');
    return result.map((map) => ActivityModel.fromMap(map)).toList();
  }

  /// Deletes the activity row matching the given [id].
  ///
  /// If no row matches, nothing happens.
  Future<void> deleteActivity(int id) async {
    final db = await _db.database;
    await db.delete(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clears all rows from the 'activities' table.
  ///
  /// Use with care: this will remove all locally cached activities.
  Future<void> clearAll() async {
    final db = await _db.database;
    await db.delete('activities');
  }
}
