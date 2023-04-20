
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rudo_app_clone/core/constants.dart';
import 'package:rudo_app_clone/core/request.dart';
import 'package:rudo_app_clone/data/model/alert.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/model/gallery/album.dart';
import 'package:rudo_app_clone/data/model/google_response_status.dart';
import 'package:rudo_app_clone/data/model/office_day.dart';
import 'package:rudo_app_clone/data/model/sesame/check.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';
import 'package:rudo_app_clone/data/model/sesame/geo_point.dart';
import 'package:rudo_app_clone/data/model/sesame/check_type.dart';
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
    
    Response res = await _request.get("api/v2/google/events");
   
    if(res.statusCode == 200){
       return (res.data as List).map<Event>((rawEvent) => Event.fromJson(rawEvent)).toList();
    }else{
      throw Exception("Error en apiService loginGoogle. StatusCode: ${res.statusCode} Data: ${res.data}");
    }
  }

  /// get the list of checks of the current user from the api
  Future<CheckInfo> getCheckInfo(DateTime day) async{
    var res = await Request.instance.post("api/v2/sesame/time",data: {'fromTime':DateFormat('yyyy-MM-dd').format(day)});
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

  /// update the status from an event
  Future<Event> updateEventStatus(Event event, ResponseStatus status) async{
    var res = await Request.instance.patch("api/v2/google/events/update",
      data: {
        "event_id": event.eventId,
        "response_status": status.name
    });
    if(res.statusCode == 200){
       return Event.fromJson(res.data);
    }else{
      throw Exception("Error en apiService updateEventStatus. StatusCode: ${res.statusCode} Data: ${res.data}");
    }
  }

  Future<Check> updateCheckInfo(GeoPoint currentLocation, CheckType checkType) async{
    var res = await Request.instance.post("sesame/in",
      data: {   
          "type": checkType.value.toString(),
          "longitude": double.parse(currentLocation.longitude),
          "latitude": double.parse(currentLocation.latitud)
      });
    if(res.statusCode == 200){
       return Check.fromJson(res.data['data']['check']);
    }else{
      throw Exception("Error en apiService updateEventStatus. StatusCode: ${res.statusCode} Data: ${res.data}");
    }
  }

  Future<List<Alert>> getAlerts() async {
    var res = await Request.instance.get("posts/notifications");
    if(res.statusCode == 200){
       return [Alert.dummy(false),Alert.dummy(true),Alert.dummy(true)];// (res.data as List).map<Alert>((rawAlert) => Alert.fromJson(rawAlert)).toList();
    }else{
      throw Exception("Error en apiService updateEventStatus. StatusCode: ${res.statusCode} Data: ${res.data}");
    }
  }



  Future <List<Album>> getAlbums() async{
    return [
      {
          "id": 1,
          "name": "Japón",
          "created": "2023-02-15T13:13:23.545449+01:00",
          "cover": {
              "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c6149b9eb1ff4632bc35d5f4655b0061.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=54b6704c149b1c34c73378d4470c66595c9619f4d5fc1fd0aab0e5b2e3b160a9",
              "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c6149b9eb1ff4632bc35d5f4655b0061.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=87e84ebfed8d65ab244acd3bc92438d61c10481a0d6be38cb7be92b065930b07",
              "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c6149b9eb1ff4632bc35d5f4655b0061.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5b9ec99880c47e796a447e8fae7b0509ed8b412e5d912b3b12b6a51c1acb254f",
              "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c6149b9eb1ff4632bc35d5f4655b0061.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=3d8031cd56abbd386b287e83de048d874a31b0c853b5e94da4fdb799774ce08f"
          },
          "image_counter": 37,
          "publishers": [
              {
                  "id": "US2A13D2",
                  "name": "Aitor Poquet",
                  "image": {
                      "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=59fd0d24296ead15c7b3a61d59cac3d58c529c2c032aaabf95ea5e22096f2375",
                      "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ee14976d321cca6f205f7bf7ac8e6229cb38efa115660947b381b8d5d0df91c7",
                      "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=66a6409d878f34cd3c5c746ed38a7f53651878d35e5ecea6bf05862c02eff4e6",
                      "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=724abad422b2aaec8560fa2b9057208d2403a9e862702175d69ed9279975f7e4"
                  }
              },
              {
                  "id": "US4F0E3E",
                  "name": "Fer Salom",
                  "image": {
                      "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=0e3cabfcdf8be4ec15638c3f498bb046b730c35c9f33f75e31097442c01ddc5e",
                      "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=bfdb135ebc2c64f02563fdc8cefee960ca37595e3ec516b78d789a8ccf258938",
                      "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=e85fb554ac528c580cdb461f60e5c334ecd50d940ff670685f6b7ca3bc5176c6",
                      "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4df906a998eaf2930bb50da3b73bb06428805cff0353c7835c2a9b8e1b780629"
                  }
              },
              {
                  "id": "US709A21",
                  "name": "Antonio Ferrando",
                  "image": {
                      "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=d4f18a33b9b91207bbfeedd086cc3ba01890eb26b0596cd14f14b23666a4fe46",
                      "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=22bf915dd3730654b7556c365d3a4ded9c60ed39f08fdedeb9d3cf89c8b7a768",
                      "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=93ee099519971e58f578e37d72c94f292f67264779cbca3a84786c34a9980840",
                      "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=51d2414cf4d2bb9259d178278e66834fea9d6c46cf232cdecc79ef15a7035372"
                  }
              },
              {
                  "id": "USBDC391",
                  "name": "Aina Moll",
                  "image": {
                      "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=db2704d03bc37ed19ed0790296a780fa099b45b2f080e868d66c129a936816ba",
                      "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5ed2c65a3ef9d97b7feb9560a8f44188ebd814394f4a2f5d5209adc23cdbc0b1",
                      "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=e1d7c4feb73ecc6959f8044e881973455ab86d7f0eff3920691b50f0f92afacc",
                      "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=755b31df66f6cd80bf86381eb9b9cb945011fb011bd60c9edf5aa32d98a30133"
                  }
              },
              {
                  "id": "US196446",
                  "name": "Richard Morla",
                  "image": {
                      "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/51955fa599674e2ba806e0fecf1cdfa3.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=d02767c5d7d5bea31bbbe1bd53d81e414679f771da1d72cfb7ef89a9274e37aa",
                      "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/51955fa599674e2ba806e0fecf1cdfa3.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=42784e848873ee30ba087eaf183e026d2dea7410410a41fa653cf593d7ea7d1f",
                      "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/51955fa599674e2ba806e0fecf1cdfa3.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=659e1f3a20f0daef64bf1d25cf70e25d0b80d165923becff44b135d33d7db651",
                      "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/51955fa599674e2ba806e0fecf1cdfa3.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=783980056511d7c856f2483b22d33b17077ce2b6cb3af0622e8fab57fbe5c46b"
                  }
              }
          ]
      },
      {
          "id": 2,
          "name": "Oficina",
          "created": "2023-02-15T13:13:23.545449+01:00",
          "cover": {
              "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8faca991fc964529a0ad93702604af16.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=0ee5ec611386f276a19fa3529c4ddaaf2cd95d1e824496d49e5fc2ae4500e034",
              "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8faca991fc964529a0ad93702604af16.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ef1c72c49722a8689778f9917d8178077ce0bd1bfab57063b8b4ab379196b2f4",
              "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8faca991fc964529a0ad93702604af16.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ef85cbf92c753c2845207bbab25236838256fc31feb7cffcc0bc4e7c123d5e5e",
              "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8faca991fc964529a0ad93702604af16.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=b818445d2d71191143f487822b838e8cfbdbb3ee6833c86dc42f80c34f6a25fd"
          },
          "image_counter": 12,
          "publishers": [
              {
                  "id": "US039E72",
                  "name": "Andrea Paricio",
                  "image": {
                      "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/5399bddae6e44bc098fbccb7cea444b1.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=3e808ba8a271c0bebc5daa7d90a9f25a79cc4d089703f15da7c2c29494379a25",
                      "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/5399bddae6e44bc098fbccb7cea444b1.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f08662b89ef038f19e7e4b027562e4c6ba61185c20ca8f5f05f90ccd1eed1d1a",
                      "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/5399bddae6e44bc098fbccb7cea444b1.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=031351035982da64983565f700cf9211b77cdfeae42c86d16b934d72bf4f48f8",
                      "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/5399bddae6e44bc098fbccb7cea444b1.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=d1a3d9009765cdc4c7151afab3c5e693ad08a90e08932d11e18357eec6acec0b"
                  }
              },
              {
                  "id": "US2618E5",
                  "name": "Jorge Alegre",
                  "image": {
                      "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/cd9973b1d635471d9266332624d6aac3.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=19d0dea002d6c4714b3636daab7f59a5e1c8e4d6b2cbf58becc559c280eae45d",
                      "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/cd9973b1d635471d9266332624d6aac3.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=844325784c655bb871cf6b5e2068ef0d3c6940c4603250cabe40ca1ad7465adb",
                      "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/cd9973b1d635471d9266332624d6aac3.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=d9a2848687aa251facd1b552d6e137e6f33550e69afb211e99a5d61da29e3cf0",
                      "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/cd9973b1d635471d9266332624d6aac3.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=a90e1b8124ffa40769f7bf247787217b062e33ba0a94ee84c624d18036ed8aa1"
                  }
              },
              {
                  "id": "US4F0E3E",
                  "name": "Fer Salom",
                  "image": {
                      "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=0e3cabfcdf8be4ec15638c3f498bb046b730c35c9f33f75e31097442c01ddc5e",
                      "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=bfdb135ebc2c64f02563fdc8cefee960ca37595e3ec516b78d789a8ccf258938",
                      "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=e85fb554ac528c580cdb461f60e5c334ecd50d940ff670685f6b7ca3bc5176c6",
                      "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4df906a998eaf2930bb50da3b73bb06428805cff0353c7835c2a9b8e1b780629"
                  }
              },
              {
                  "id": "USA01F82",
                  "name": "Joan Cremades",
                  "image": {
                      "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/2d17e9ed7aea490b97da4a6aed3d766a.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=6fbe84db9ac325a9376bd027935550b541375981747c44368341fa11f7dfd7bd",
                      "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/2d17e9ed7aea490b97da4a6aed3d766a.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=d4ced2d5beee9eeb26bb2a4a91e8b9ae60a78fc9eadf4698a3b133fe6839f012",
                      "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/2d17e9ed7aea490b97da4a6aed3d766a.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=21032aff2fcbc8a4b35d48eef362b472da8389d770794d6219e58b4a90aa0d72",
                      "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/2d17e9ed7aea490b97da4a6aed3d766a.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=fa596cf6976d3ad39c74fbd422168739a6f5bf1d05b33a6469bb1f99d4b7d8b0"
                  }
              },
              {
                  "id": "USE70B84",
                  "name": "Polina Demidova",
                  "image": {
                      "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/a8173f579a8048b68d3538b5c1788217.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084355Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f51350a45fe163ba88c8fe644e13b1985e33c94b23a3c0e3117f4ef675632c39",
                      "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/a8173f579a8048b68d3538b5c1788217.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084356Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=81bde11b805e6b259a4c1d8a12237a044268afed74314796c78e7c4f1d9f6712",
                      "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/a8173f579a8048b68d3538b5c1788217.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084356Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=433153406d4504d319798d06417b9c31d165e3fed300b2ab04cab839af1d9e6f",
                      "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/a8173f579a8048b68d3538b5c1788217.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084356Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=166606f3aa3f838935ce313095f45a5824044bab0f75138317747d1d9246a651"
                  }
              },
              {
                  "id": "USEB3767",
                  "name": "Jorge Planells",
                  "image": {
                      "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/74630e2cbfba45e681d051669ba05b7f.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084356Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=01e9bd445647fad8de5209a5b248a85bcea4243adab996c8b5567e0179b68b8a",
                      "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/74630e2cbfba45e681d051669ba05b7f.png.128x128_q90.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084356Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=8ef3ac9a2a3c7db9cf8f94656417492c1e8a1d66d6f97d68bdd01d23591e68fc",
                      "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/74630e2cbfba45e681d051669ba05b7f.png.720x720_q90.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084356Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=8f19f512a68bdc6a492a159200d04ab79aef3992fca6ce497cab1828b582ca63",
                      "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/74630e2cbfba45e681d051669ba05b7f.png.1080x1080_q90.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230419%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230419T084356Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=fb74b972e58adb0af2d2993870a778813e0cee364272ab834cf13b119fca7e4a"
                  }
              }
          ]
      }
    ].map((e) => Album.fromJson(e)).toList();
  }
}