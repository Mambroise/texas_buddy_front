//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/datasources/local/event_local_datasource.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:sqflite/sqflite.dart';
import '../../../../../core/database/local_db.dart';
import '../../models/event_model.dart';

/// A data source for performing CRUD operations on the local
/// SQLite 'events' table. Acts as the DAO layer for EventModel.
class EventLocalDatasource {
  final LocalDatabase _db = LocalDatabase();

  /// Inserts a new [EventModel] into the 'events' table.
  ///
  /// If an event with the same primary key already exists,
  /// it will be replaced (ConflictAlgorithm.replace).
  Future<void> insertEvent(EventModel event) async {
    final db = await _db.database;
    await db.insert(
      'events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves a single [EventModel] by its [id].
  ///
  /// Returns null if no matching row is found.
  Future<EventModel?> getEventById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return EventModel.fromMap(maps.first);
    }
    return null;
  }

  /// Retrieves all [EventModel] rows from the 'events' table.
  ///
  /// Returns an empty list if the table is empty.
  Future<List<EventModel>> getAllEvents() async {
    final db = await _db.database;
    final result = await db.query('events');
    return result.map((map) => EventModel.fromMap(map)).toList();
  }

  /// Deletes the event row matching the given [id].
  ///
  /// If no row matches, nothing happens.
  Future<void> deleteEvent(int id) async {
    final db = await _db.database;
    await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Clears all rows from the 'events' table.
  ///
  /// Use with care: this will remove all locally cached events.
  Future<void> clearAll() async {
    final db = await _db.database;
    await db.delete('events');
  }
}
