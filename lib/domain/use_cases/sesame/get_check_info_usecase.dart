
import 'dart:developer';

import 'package:rudo_app_clone/core/request.dart';
import 'package:rudo_app_clone/core/storage_keys.dart';
import 'package:rudo_app_clone/data/model/auth_token.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';
import 'package:rudo_app_clone/data/model/user/user_auth.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/data/service/location_service.dart';
import 'package:rudo_app_clone/data/service/rudo_api_service.dart';
import 'package:rudo_app_clone/data/service/storage_service.dart';
import 'package:rudo_app_clone/domain/use_cases/auth/refresh_token_use_case.dart';

class GetCheckInfoUseCase {

  final RudoApiService _apiService = RudoApiService();
  final LocationService _locationService = LocationService();


  /// GetCheckInfoUseCase, 
  ///  check the token validation and get the check info of the current user
  /// - 
  Future<CheckInfo> call() async{
    bool isTokenValid = await CheckValidTokenUseCase().call();
          
    if(isTokenValid){
      return  await  _apiService.getCheckInfo();

      
    }else{
      throw Exception('no se pudo refrescar el token'); // TODO hacerlo mejor
    }
    
    
       
  }

}