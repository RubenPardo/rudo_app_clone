import 'package:geolocator/geolocator.dart';
import 'package:rudo_app_clone/data/model/location.dart';
import 'package:rudo_app_clone/data/model/sesame/check.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';
import 'package:rudo_app_clone/data/model/sesame/check_type.dart';
import 'package:rudo_app_clone/data/model/sesame/geo_point.dart';
import 'package:rudo_app_clone/data/service/location_service.dart';
import 'package:rudo_app_clone/data/service/rudo_api_service.dart';

class CheckInUseCase{


  Future<Check> call(CheckType checkType) async{

    if(await LocationService.isServiceEnabled()){
      if(await LocationService.handleLocationPermission() == LocationPermission.whileInUse 
        || await LocationService.handleLocationPermission() == LocationPermission.always ){
          GeoPoint currentLocation = await LocationService.getPosition();

          return RudoApiService().updateCheckInfo(currentLocation, checkType);
        }else{
          throw Exception('No se puede realizar esta accion sin los permisos de localización');
        }
    }else{
      throw Exception('No se puede realizar esta accion sin el permiso de localizacion');
    } 
  }

}