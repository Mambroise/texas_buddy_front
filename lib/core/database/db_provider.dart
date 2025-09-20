//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :lib/core/database/db_provider.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider instance = DBProvider._();

  static Database? _db;
  Future<Database> get db async => _db ??= await _initDB();

  Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'texas_buddy_local.db');
    final database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        // migrations éventuelles plus tard
      },
    );
    return database;
  }

  Future<void> _onCreate(Database db, int version) async {
    // trips
    await db.execute('''
      CREATE TABLE IF NOT EXISTS trips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id INTEGER,
        user_id INTEGER,
        title TEXT NOT NULL,
        start_date TEXT,
        end_date TEXT,
        adults INTEGER DEFAULT 1,
        children INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      );
    ''');

    // trip_days
    await db.execute('''
      CREATE TABLE IF NOT EXISTS trip_days (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id INTEGER,
        trip_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        address_cache_id INTEGER,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(trip_id) REFERENCES trips(id) ON DELETE CASCADE
      );
    ''');

    // trip_steps (colones compatibles avec TripStepModel)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS trip_steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id INTEGER,
        trip_day_id INTEGER NOT NULL,
        activity_id INTEGER,
        event_id INTEGER,
        start_time TEXT NOT NULL,
        estimated_duration_minutes INTEGER NOT NULL DEFAULT 60,
        travel_mode TEXT DEFAULT 'driving',
        travel_duration_minutes INTEGER DEFAULT 0,
        travel_distance_meters INTEGER DEFAULT 0,
        end_time TEXT,
        notes TEXT,
        position INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(trip_day_id) REFERENCES trip_days(id) ON DELETE CASCADE
      );
    ''');
  }

  Future<void> close() async {
    final database = _db;
    if (database != null) {
      await database.close();
      _db = null;
    }
  }
}
