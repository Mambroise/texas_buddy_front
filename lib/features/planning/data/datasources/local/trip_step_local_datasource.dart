//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/datasources/local/trip_step_local_datasource.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:sqflite/sqflite.dart';
import 'package:texas_buddy/core/database/db_provider.dart';
import '../../models/trip_step_model.dart';

class TripStepLocalDataSource {
  TripStepLocalDataSource._();
  static final TripStepLocalDataSource instance = TripStepLocalDataSource._();

  Future<int> insertTripStep(TripStepModel s) async {
    final Database db = await DBProvider.instance.db;
    return await db.insert('trip_steps', s.toMap());
  }

  Future<int> updateTripStep(TripStepModel s) async {
    if (s.id == null) throw Exception('TripStepModel.id is null for update');
    final Database db = await DBProvider.instance.db;
    return await db.update('trip_steps', s.toMap(), where: 'id = ?', whereArgs: [s.id]);
  }

  Future<TripStepModel?> getTripStepById(int id) async {
    final Database db = await DBProvider.instance.db;
    final rows = await db.query('trip_steps', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return TripStepModel.fromMap(rows.first);
  }

  Future<List<TripStepModel>> getTripStepsForDay(int tripDayId) async {
    final Database db = await DBProvider.instance.db;
    final rows = await db.query(
      'trip_steps',
      where: 'trip_day_id = ?',
      whereArgs: [tripDayId],
      orderBy: 'start_time ASC',
    );
    return rows.map((r) => TripStepModel.fromMap(r)).toList();
  }

  Future<int> deleteTripStep(int id) async {
    final Database db = await DBProvider.instance.db;
    return await db.delete('trip_steps', where: 'id = ?', whereArgs: [id]);
  }
}