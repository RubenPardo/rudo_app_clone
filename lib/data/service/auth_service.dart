
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rudo_app_clone/core/constants.dart';
import 'package:rudo_app_clone/core/request.dart';
import 'package:rudo_app_clone/core/storage_keys.dart';
import 'package:rudo_app_clone/data/model/user/user_auth.dart' as model;
import 'package:rudo_app_clone/data/model/auth_token.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/data/service/storage_service.dart';

class AuthService{

  
  final Request _request = Request.instance;

  var googleSigin =  GoogleSignIn(scopes: <String>["email"]);
  
  /// to get google user info, access token and id token 
  ///
  /// return User if signed correctly and null if cancelled the google popup
  ///
  Future<model.UserAuth?> getGoogleUser() async{
    final GoogleSignInAccount? googleUser = await googleSigin.signIn();
    if(googleUser!=null){
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
       
      return model.UserAuth(
        googleUser.email,
        googleUser.displayName ?? "",
        "", // TODO last name¿
        googleAuth.idToken ?? "",
        Constants.clientIdFirebase, 
        googleAuth.accessToken ?? ""
      );
    }
   // await googleSigin.signOut();// close google session to avoid token porblems
    

    return null;
  }

  /// logout the user on the api
  ///
  /// @user User to login
  Future<void> logOut(AuthToken token) async{

    var res = await _request.post("auth/revoke-token",
    data: {
      'token':token.accessToken,
      'client_id':Constants.clientId,
      'client_secret':Constants.clientSecret
    });
    
    if(res.statusCode == 200){
     
    }else{
      throw Exception("Error en authService loginGoogle. StatusCode: ${res.statusCode} Data: ${res.data}");
    }
  }

  /// login the user on the api
  ///
  /// @user User to login
  Future<AuthToken> loginGoogle(model.UserAuth user) async{

    var res = await _request.post("google/login",data: user.toJson());
    log(res.data.toString());
    if(res.statusCode == 200){
      return AuthToken.fromJsonToken(res.data);
    }else if(res.statusCode == 400 && res.data['detail'] != null && (res.data['detail'] as String).contains('Token expired')){
      throw Exception("Error en authService loginGoogle. StatusCode: ${res.statusCode} Data: ${res.data}");
    }
    else{
      throw Exception("Error en authService loginGoogle. StatusCode: ${res.statusCode} Data: ${res.data}");
    }
  }

  Future<AuthToken> refreshToken(AuthToken authToken) async{

    var res = await _request.post("google/refresh_token",
      data: {
        'refresh_token':authToken.refreshToken
      }
    );
    
    // sometimes will arrive a 200 and error message 
    if(res.statusCode == 200 && res.data['error'] == null){
      return AuthToken.fromJsonToken(res.data);
    }else{
      throw Exception("Error en authService loginGoogle. StatusCode: ${res.statusCode} Data: ${res.data}");
    }
  }

  Future<void> loginAuth() async{
    var res = await _request.post("auth/token",data: {
      'grant_type':'password',
      'client_id':Constants.clientId,
      'client_secret':Constants.clientSecret,
      'username':'rubenpardo@rudo.es',
      'password':'secret',
    });
    if(res.statusCode == 200){
      print(res.data);
    }else{
      throw Exception("Error en authService loginGoogle. StatusCode: ${res.statusCode} Data: ${res.data}");
    }
  }

   Future<UserData> getUserData()async {
      var res = await _request.get("user/me");
      return UserData.fromJson(res.data);
   }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }


}