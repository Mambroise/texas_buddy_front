

import 'package:dio/dio.dart';
import '../../dtos/detail_dtos.dart';


class DetailRemoteDataSource {
  final Dio dio;
  DetailRemoteDataSource(this.dio);


  static const _activities = 'activities';
  static const _events = 'events';


  Future<ActivityDetailDto> fetchActivityById(String id) async {
    final res = await dio.get('activities/$_activities/$id/');
    return ActivityDetailDto.fromJson(res.data as Map<String,dynamic>);
  }


  Future<EventDetailDto> fetchEventById(String id) async {
    final res = await dio.get('activities/$_events/$id/');
    return EventDetailDto.fromJson(res.data as Map<String,dynamic>);
  }


  Future<ActivityDetailDto> fetchActivityByPlace(String placeId) async {
    final res = await dio.get('activities/$_activities/place/$placeId/');
    return ActivityDetailDto.fromJson(res.data as Map<String,dynamic>);
  }


  Future<EventDetailDto> fetchEventByPlace(String placeId) async {
    final res = await dio.get('activities/$_events/place/$placeId/');
    return EventDetailDto.fromJson(res.data as Map<String,dynamic>);
  }
}