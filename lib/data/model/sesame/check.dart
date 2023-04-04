import 'package:geolocator/geolocator.dart';
import 'package:rudo_app_clone/data/model/sesame/check_type.dart';
import 'package:rudo_app_clone/data/model/sesame/geo_point.dart';

/// class that represent a check
/// @[point] the geo position where it is make
/// @[status] the type of check, in out or pause
/// @[date] when it was done
class Check{
  final GeoPoint? point;
  final CheckType status;
  final DateTime? date;

  Check({this.date, this.point, required this.status});

  factory Check.fromJson(Map<String, dynamic> json){
    return Check(
      date: json['created'] != null ? DateTime.parse(json['created']) : null,
      status: CheckType.fromStatus(json['status'])
    );
  }

  factory Check.checkIn(Position position){
    return Check(
      date: DateTime.now(),
      status: CheckType.checkIn,
      point: GeoPoint(longitude: position.longitude.toString(), latitud: position.latitude.toString()),
    );
  }

  Map<String, dynamic> toJson(){
    if(point!=null){
      return {
        'type':status.value,
        'longitude': point!.longitude,
        'latitude': point!.latitud,
      };
    }

    return {};
    
  }

  @override
  String toString() {
    return 'Check: [ Status: $status, Date: $date, Point: $point]';
  }
}