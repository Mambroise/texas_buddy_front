//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :features/planning/data/datasources/local/trip_day_local_datasource.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:sqflite/sqflite.dart';
import 'package:texas_buddy/core/database/db_provider.dart';
import '../../models/trip_day_model.dart';

class TripDayLocalDataSource {
  TripDayLocalDataSource._();
  static final TripDayLocalDataSource instance = TripDayLocalDataSource._();

  Future<int> insertTripDay(TripDayModel d) async {
    final Database db = await DBProvider.instance.db;
    return await db.insert('trip_days', d.toMap());
  }

  Future<int> updateTripDay(TripDayModel d) async {
    if (d.id == null) throw Exception('TripDayModel.id is null');
    final Database db = await DBProvider.instance.db;
    return await db.update('trip_days', d.toMap(), where: 'id = ?', whereArgs: [d.id]);
  }

  Future<TripDayModel?> getTripDayById(int id) async {
    final Database db = await DBProvider.instance.db;
    final rows = await db.query('trip_days', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return TripDayModel.fromMap(rows.first);
  }

  Future<List<TripDayModel>> getTripDaysForTrip(int tripId) async {
    final Database db = await DBProvider.instance.db;
    final rows = await db.query('trip_days', where: 'trip_id = ?', whereArgs: [tripId], orderBy: 'date ASC');
    return rows.map((r) => TripDayModel.fromMap(r)).toList();
  }

  Future<int> deleteTripDay(int id) async {
    final Database db = await DBProvider.instance.db;
    return await db.delete('trip_days', where: 'id = ?', whereArgs: [id]);
  }
}