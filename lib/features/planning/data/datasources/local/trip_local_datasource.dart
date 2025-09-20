//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/datasources/local/trip_local_datasource.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:sqflite/sqflite.dart';
import 'package:texas_buddy/core/database/db_provider.dart';
import '../../models/trip_model.dart';

class TripLocalDataSource {
  TripLocalDataSource._();
  static final TripLocalDataSource instance = TripLocalDataSource._();

  Future<int> insertTrip(TripModel t) async {
    final Database db = await DBProvider.instance.db;
    return await db.insert('trips', t.toMap());
  }

  Future<int> updateTrip(TripModel t) async {
    if (t.id == null) throw Exception('TripModel.id is null');
    final Database db = await DBProvider.instance.db;
    return await db.update('trips', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<TripModel?> getTripById(int id) async {
    final Database db = await DBProvider.instance.db;
    final rows = await db.query('trips', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return TripModel.fromMap(rows.first);
  }

  Future<List<TripModel>> getAllTrips() async {
    final Database db = await DBProvider.instance.db;
    final rows = await db.query('trips', orderBy: 'created_at DESC');
    return rows.map((r) => TripModel.fromMap(r)).toList();
  }

  Future<int> deleteTrip(int id) async {
    final Database db = await DBProvider.instance.db;
    return await db.delete('trips', where: 'id = ?', whereArgs: [id]);
  }
}