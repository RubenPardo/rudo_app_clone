
import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:rudo_app_clone/core/constants.dart';
import 'package:rudo_app_clone/core/request.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/model/location.dart';
import 'package:rudo_app_clone/data/model/office_day.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';
import 'package:rudo_app_clone/data/model/sesame/hour_balance.dart';
import 'package:rudo_app_clone/data/model/user/user_auth.dart' as model;
import 'package:rudo_app_clone/data/model/auth_token.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:intl/intl.dart';


class RudoApiService{

  
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
    //await googleSigin.signOut();// close google session to avoid token porblems
    

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
      throw Exception("Error en apiService loginGoogle. StatusCode: ${res.statusCode} Data: ${res.data}");
    }
  }

  /// get the data of the user loged
  /// no parameters needed because of the authtoken at the header
  Future<UserData> getUserData()async {
    var res = await _request.get("user/me");
    if(res.statusCode == 200){
       return UserData.fromJson(res.data);
    }else{
      throw Exception("Error en apiService loginGoogle. StatusCode: ${res.statusCode} Data: ${res.data}");
    }

   
  }

  /// get the data of the user loged
  /// no parameters needed because of the authtoken at the header
  Future<List<OfficeDay>> getOfficeDays()async {
    var res = await _request.get("user/office");
    if(res.statusCode == 200){
       
       return (res.data as List).map<OfficeDay>((rawOfficeDay) => OfficeDay.fromJson(rawOfficeDay)).toList();
    }else{
      throw Exception("Error en apiService loginGoogle. StatusCode: ${res.statusCode} Data: ${res.data}");
    }
  }

  /// get the google calendar events of the user loged
  /// no parameters needed because of the authtoken at the header
  Future<List<Event>> getGoogleCallendarEvents()async {
    var res = await _request.get("google/events");
    if(res.statusCode == 200){
       return (res.data['items'] as List).map<Event>((rawEvent) => Event.fromJson(rawEvent)).toList();
    }else{
      throw Exception("Error en apiService loginGoogle. StatusCode: ${res.statusCode} Data: ${res.data}");
    }
  }

  /// get the list of checks of the current user from the api
  Future<CheckInfo> getCheckInfo() async{
    var res = await Request.instance.post("api/v2/sesame/time",data: {'fromTime':DateFormat('yyyy-MM-dd').format(DateTime.now())});
    if(res.statusCode == 200){
       return CheckInfo.fromJson(res.data);
    }else{
      throw Exception("Error en apiService getCheckInfo. StatusCode: ${res.statusCode} Data: ${res.data}");
    }
  }

  /// get the list of checks of the current user from the api
  Future<HourBalance> getHourBalanceFromTo(DateTime from, DateTime to) async{
    var res = await Request.instance.post("api/v2/sesame/time/range",
      data: {
        'startAt':DateFormat('yyyy-MM-dd hh:mm:ss').format(from),
        'endAt':DateFormat('yyyy-MM-dd hh:mm:ss').format(to),
      });
    if(res.statusCode == 200){
       return HourBalance.fromJson(res.data);
    }else{
      throw Exception("Error en apiService getHourBalanceFromTo. StatusCode: ${res.statusCode} Data: ${res.data}");
    }
  }

}