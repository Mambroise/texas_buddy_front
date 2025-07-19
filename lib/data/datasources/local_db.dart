import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  static Database? _database;

  LocalDatabase._internal();

  factory LocalDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'texas_buddy.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    // Trip table
    await db.execute('''
      CREATE TABLE trips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT,
        start_date TEXT,
        end_date TEXT,
        adults INTEGER,
        children INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
    '''
    );

    // TripDay table
    await db.execute('''
      CREATE TABLE trip_days (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_id INTEGER,
        date TEXT,
        address_cache_id INTEGER
      )
    '''
    );

    // TripStep table
    await db.execute('''
      CREATE TABLE trip_steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_day_id INTEGER,
        activity_id INTEGER,
        event_id INTEGER,
        start_time TEXT,
        estimated_duration_minutes INTEGER,
        travel_mode TEXT,
        travel_duration_minutes INTEGER,
        travel_distance_meters INTEGER,
        end_time TEXT,
        notes TEXT,
        position INTEGER
      )
    '''
    );

    // Advertisement table
    await db.execute('''
      CREATE TABLE advertisements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        io_reference_number TEXT,
        contract_id INTEGER,
        campaign_type TEXT,
        format TEXT,
        title TEXT,
        ad_creative_content_text TEXT,
        image_url TEXT,
        video_url TEXT,
        link_url TEXT,
        push_message TEXT,
        start_date TEXT,
        end_date TEXT,
        related_activity_id INTEGER,
        related_event_id INTEGER
      )
    '''
    );

    // Activity table
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        address TEXT,
        city TEXT,
        state TEXT,
        zip_code TEXT,
        location TEXT,
        place_id TEXT,
        website TEXT,
        phone TEXT,
        email TEXT,
        latitude REAL,
        longitude REAL,
        image_url TEXT,
        price REAL,
        duration TEXT,
        average_rating REAL,
        staff_favorite INTEGER,
        is_unique INTEGER,
        is_active INTEGER,
        created_at TEXT
      )
    '''
    );

    // Event table
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        start_datetime TEXT,
        end_datetime TEXT,
        address TEXT,
        city TEXT,
        state TEXT,
        zip_code TEXT,
        location TEXT,
        place_id TEXT,
        latitude REAL,
        longitude REAL,
        website TEXT,
        image_url TEXT,
        price REAL,
        duration TEXT,
        average_rating REAL,
        staff_favorite INTEGER,
        is_national INTEGER,
        is_public INTEGER,
        created_at TEXT
      )
    '''
    );

    // Join tables for Many-to-Many relations
    await db.execute('''
      CREATE TABLE activity_categories (
        activity_id INTEGER,
        category_id INTEGER,
        PRIMARY KEY (activity_id, category_id)
      )
    '''
    );

    await db.execute('''
      CREATE TABLE event_categories (
        event_id INTEGER,
        category_id INTEGER,
        PRIMARY KEY (event_id, category_id)
      )
    '''
    );
  }

  Future<void> close() async {
    final dbClient = await database;
    await dbClient.close();
  }
}
