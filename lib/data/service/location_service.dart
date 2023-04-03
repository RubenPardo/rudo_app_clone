import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rudo_app_clone/data/model/sesame/geo_point.dart';

class LocationService{

  /// return true if the location service is enabled
  static Future<bool> isServiceEnabled() async{
    return await Geolocator.isLocationServiceEnabled();
  }

  /// make a location permision request and return a [LocationPermission]
  /// [LocationPermission.whileInUse] or [LocationPermission.always] means it can be used
  /// [LocationPermission.deniedForever] can not be used
  /// [LocationPermission.denied] cant be used but it can requested again
  static Future<LocationPermission> handleLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// get the current position
  static Future<GeoPoint> getPosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    GeoPoint gp = GeoPoint(longitude: position.longitude.toString(), latitud: position.latitude.toString());
    return gp;
  }


}