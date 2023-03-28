import 'dart:developer';

import 'package:rudo_app_clone/core/request.dart';
import 'package:rudo_app_clone/core/storage_keys.dart';
import 'package:rudo_app_clone/data/model/auth_token.dart';
import 'package:rudo_app_clone/data/model/user/user_auth.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/data/service/auth_service.dart';
import 'package:rudo_app_clone/data/service/storage_service.dart';
import 'package:rudo_app_clone/domain/use_cases/auth/refresh_token_use_case.dart';

class GoogleSigInUseCase {

  final AuthService _authService = AuthService();
  final StorageService _secureStorage = StorageService();
  final CheckValidTokenUseCase checkValidTokenUseCase = CheckValidTokenUseCase();


  /// sigin with google use case, 
  /// first of all check if the user is already logged, 
  /// - if it is just get his information
  /// - otherwise get the google user, call google login of the api and save internally the auth token
  /// @returns the user if all ok, null otherwise
  Future<UserData?> call() async{
    UserAuth? user;
    bool isTokenValid = await checkValidTokenUseCase.call();
          
    if(!isTokenValid){
      // google login
      user = await  _authService.getGoogleUser();
      if(user!=null){
        AuthToken token = await  _authService.loginGoogle(user);
        await _secureStorage.writeSecureData(StorageKeys.authToken, token.toStringSecureStorage());
        Request.instance.updateAuthorization(token.accessToken);

        // get the user data

        UserData uaserData = await _authService.getUserData();

        return uaserData; // if all ok return user
      }
    }else{
      // logged already, get the user
       await _authService.getUserData();
    }
      
    
    return null;   
  }

}