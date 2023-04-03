
import 'dart:developer';

import 'package:rudo_app_clone/core/request.dart';
import 'package:rudo_app_clone/core/storage_keys.dart';
import 'package:rudo_app_clone/data/model/auth_token.dart';
import 'package:rudo_app_clone/data/service/rudo_api_service.dart';
import 'package:rudo_app_clone/data/service/storage_service.dart';

class CheckValidTokenUseCase {

  final RudoApiService _authService = RudoApiService();
  final StorageService _secureStorage = StorageService();


  /// check if the token is expired, if then update it
  /// If all ok, return true and save the new token, otherwise return false
  Future<bool> call() async{
    try{
      String? tokenSaved = await _secureStorage.readSecureData(StorageKeys.authToken);
    if(tokenSaved != null){
      AuthToken authToken = AuthToken.fromStringSecureStorage(tokenSaved);
      
      // token no exired, return tru
      if(!authToken.isExpired()){
        log('token no expired');
        log(authToken.toStringSecureStorage());
        Request.instance.updateAuthorization(authToken.accessToken);
        return true;
      }
      // token expirado, refresh it
      else{
        log('token expired');
        AuthToken newToken = await _authService.refreshToken(authToken);
        Request.instance.updateAuthorization(newToken.accessToken);
        StorageService().writeSecureData(StorageKeys.authToken, newToken.toStringSecureStorage());
        return true;
      }
    }else{
      // no token saved
      log('token no saved');
      return false;
    }  
    }catch(e){
      log('error al obtener el token: $e');
      return false;
    }
  }

}