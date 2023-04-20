
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rudo_app_clone/core/constants.dart';
import 'package:rudo_app_clone/core/request.dart';
import 'package:rudo_app_clone/data/model/alert.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/model/gallery/album.dart';
import 'package:rudo_app_clone/data/model/gallery/photo.dart';
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

   Future<List<Photo>> getAlbumPhotosById(String id)async{
    log('get album photos by id');
    List<Photo> photos =  (({
    "id": 1,
    "name": "Japón",
    "created": "2023-02-15T13:13:23.545449+01:00",
    "cover": {
        "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c6149b9eb1ff4632bc35d5f4655b0061.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=87ea1f1aa71fe4849abb42b4c1a768167dc8aacf2f7b6682dc32e52510c153ea",
        "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c6149b9eb1ff4632bc35d5f4655b0061.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=3bedb65d6ecc273c823a1297404f7e6d2bb78dee41c048a23e004b57e85fe4d7",
        "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c6149b9eb1ff4632bc35d5f4655b0061.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=05bb2fd1d8ad665687caa13ad62e47ae4c8e418ce395529be12e3ba8878970a9",
        "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c6149b9eb1ff4632bc35d5f4655b0061.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=e20aef25886ec7ef08ae232912735f9a25d2c8b551ddff504798910bb16c1579"
    },
    "image_counter": 37,
    "publishers": [
        {
            "id": "US2A13D2",
            "name": "Aitor Poquet",
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ae3a24c42ded32acb191b7aa37a78bc9d99f8aa5378f4a73c4edf480cf6ed932",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9c51c750f834fc726ea96b5b18cc6bc202d1d69b7c97d62ecca87eec53c0a063",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f8bbcd73dff8311eaa16177d9327795ae9e1963fa0f6d74e96506303baec40a5",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=0fd58f7e38877d6d7082b01fdf84f50cd539b13c668a5d4cde90af8a1a5a126d"
            }
        },
        {
            "id": "US4F0E3E",
            "name": "Fer Salom",
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=06ba0972135cfc6a183c354fceb1226db661da3e4135c62743df618cb82adec5",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=53ec4c70bab646387825df49619beb8972df349b285ec669a4273b36aefce233",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5b5526d011ef26ab5311a0a9c10468935bc71562a64e52c3c2fcc590d1b8f261",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ec82dd2960bdec40ade651ebbdedbcba397eefbc53db4e2e5c0db12a8bed86f0"
            }
        },
        {
            "id": "US709A21",
            "name": "Antonio Ferrando",
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=64284a08b2b7b68bb567ef0da3c76cec6a259733cd0f699c9be4ade582b5cf76",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=bb3da609772e62422bcb34a3b2793b1a87b8cd921cb4861504ceaac9795a93a0",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ff13019a89d046882bd9b98d9f0b4c8b77f258ba262e6e0222be50187df2f5b8",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=1bae673f77dafedeeb9d76a2656185229bef5e086065bc25e885111794ec1f50"
            }
        },
        {
            "id": "USBDC391",
            "name": "Aina Moll",
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=6cf49a19e281a0a973bf4ad903a42d82c52dfb66f8c0644626d7dcbc16b889e8",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=b67af9e191c0ab46f55c238dec8e4353326492679069b1a9a2992da82ca22c99",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=68562d6c1b7ba8c5344f9a2a54f0718d5f81a8b5281d05b264032a9591de7e8c",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=7d9d33dafd4fbf6052d4672a3303d53a0d5625879a4cb21cab961968d5efcdc2"
            }
        },
        {
            "id": "US196446",
            "name": "Richard Morla",
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/51955fa599674e2ba806e0fecf1cdfa3.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=cbf6063104e4a934baa1db102bc7f584bda4f11a6add9ca1a66db944cc836d17",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/51955fa599674e2ba806e0fecf1cdfa3.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f1913c46468ac4deb78f8bbda398b34295981568f9c2c4c7a4e6def73e4a75f5",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/51955fa599674e2ba806e0fecf1cdfa3.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=24c9a31fad5e777c5662c5bd3b9a314abe8b76a629f0b14915f057c51cf8e9d0",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/51955fa599674e2ba806e0fecf1cdfa3.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c4775257dc797eb3115f8d2c489a30078c501f6d859daabe04b44c4b506531b4"
            }
        }
    ],
    "photos": [
        {
            "id": 13,
            "user": {
                "id": "USBDC391",
                "name": "Aina Moll",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=6cf49a19e281a0a973bf4ad903a42d82c52dfb66f8c0644626d7dcbc16b889e8",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=b67af9e191c0ab46f55c238dec8e4353326492679069b1a9a2992da82ca22c99",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=68562d6c1b7ba8c5344f9a2a54f0718d5f81a8b5281d05b264032a9591de7e8c",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=7d9d33dafd4fbf6052d4672a3303d53a0d5625879a4cb21cab961968d5efcdc2"
                },
                "email": "aina@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/97f940d9a29d4211b4696e495be765ab.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5e3001e37be33bbaebf1c74b72cbfac88fc2ff164f23befcdf21bddef413b622",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/97f940d9a29d4211b4696e495be765ab.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5a8b178b4f68d2f228f9fc6f96f89019adda7b1ef8d26d2b2b00cedb6bff76a1",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/97f940d9a29d4211b4696e495be765ab.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=3d759065ede667ee1e3d4a87c2e8201d9a8261cd6cdde36428dbcca1c1fb6264",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/97f940d9a29d4211b4696e495be765ab.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=202f1c0d777da0808e898e8b81161c1cc1d531de4873e8e254145b83e2c1ca1a"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": [
                {
                    "id": "US709A21",
                    "name": "Antonio Ferrando",
                    "image": {
                        "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=64284a08b2b7b68bb567ef0da3c76cec6a259733cd0f699c9be4ade582b5cf76",
                        "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=bb3da609772e62422bcb34a3b2793b1a87b8cd921cb4861504ceaac9795a93a0",
                        "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ff13019a89d046882bd9b98d9f0b4c8b77f258ba262e6e0222be50187df2f5b8",
                        "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=1bae673f77dafedeeb9d76a2656185229bef5e086065bc25e885111794ec1f50"
                    }
                }
            ]
        },
        {
            "id": 14,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ae3a24c42ded32acb191b7aa37a78bc9d99f8aa5378f4a73c4edf480cf6ed932",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9c51c750f834fc726ea96b5b18cc6bc202d1d69b7c97d62ecca87eec53c0a063",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f8bbcd73dff8311eaa16177d9327795ae9e1963fa0f6d74e96506303baec40a5",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=0fd58f7e38877d6d7082b01fdf84f50cd539b13c668a5d4cde90af8a1a5a126d"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/bfd4f985abd64270b42b9cac9f9131c7.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=07905883ec0570c5b289b0bb508cf796b939c8d7c2919f7c8083e15f895d717a",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/bfd4f985abd64270b42b9cac9f9131c7.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=6d5a878de32ff7b7e6d317ea928b979d5a62c9678e7fd4e6dc7b631ed4612fc8",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/bfd4f985abd64270b42b9cac9f9131c7.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=fc52c17fc797ffbf52f95a8e86be0406938a480867c14a0516b753bac77f7f9b",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/bfd4f985abd64270b42b9cac9f9131c7.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c41793d93868616302455ad497b3b7583138b03b0f83a93e6c51bf731a817d83"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 15,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ae3a24c42ded32acb191b7aa37a78bc9d99f8aa5378f4a73c4edf480cf6ed932",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9c51c750f834fc726ea96b5b18cc6bc202d1d69b7c97d62ecca87eec53c0a063",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f8bbcd73dff8311eaa16177d9327795ae9e1963fa0f6d74e96506303baec40a5",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=0fd58f7e38877d6d7082b01fdf84f50cd539b13c668a5d4cde90af8a1a5a126d"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/7d8ce3c2e5c7459aa7752c230de3bf52.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=542a598ab833b8681e24d8c1925b357a34ab75a48beeeebd8a72818793089a12",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/7d8ce3c2e5c7459aa7752c230de3bf52.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=8f67b89b7e79a64b0d4d2afb28719f1a836f59cc0768d02734f7662818daba83",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/7d8ce3c2e5c7459aa7752c230de3bf52.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4885af04a2f4d8f146d7c0b16d2474b3b6047feca11e256bd995ed43540eb0c7",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/7d8ce3c2e5c7459aa7752c230de3bf52.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=56dc04cd36222a28d581459de383d82827e669b85e266b730b01c5a729a3730e"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 16,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ae3a24c42ded32acb191b7aa37a78bc9d99f8aa5378f4a73c4edf480cf6ed932",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9c51c750f834fc726ea96b5b18cc6bc202d1d69b7c97d62ecca87eec53c0a063",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f8bbcd73dff8311eaa16177d9327795ae9e1963fa0f6d74e96506303baec40a5",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=0fd58f7e38877d6d7082b01fdf84f50cd539b13c668a5d4cde90af8a1a5a126d"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c72357d9740e42b4bbbbe43e1de55efb.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=13fbb6cbb76767f98a4e3c709c25bbf33e6d4f11a9be4a55cf4e30f7745c5a0c",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c72357d9740e42b4bbbbe43e1de55efb.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=d7591fa3ca1758893077b6cb9ba5bc99c524e00c6567809e99612cedb42ab82d",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c72357d9740e42b4bbbbe43e1de55efb.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=7105812de1562146a1fba32ddd73796dd0d6bafad2f250a3e97649b6a80f6ade",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c72357d9740e42b4bbbbe43e1de55efb.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=6cc9bb58e496f555c7ba34ff9125d3fc3f7726b84e581719ae5361a7c2dd65f8"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 17,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ae3a24c42ded32acb191b7aa37a78bc9d99f8aa5378f4a73c4edf480cf6ed932",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9c51c750f834fc726ea96b5b18cc6bc202d1d69b7c97d62ecca87eec53c0a063",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f8bbcd73dff8311eaa16177d9327795ae9e1963fa0f6d74e96506303baec40a5",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=0fd58f7e38877d6d7082b01fdf84f50cd539b13c668a5d4cde90af8a1a5a126d"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f8bce5d8f64a4e8cb49754d0796e4449.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=b74bb8e2b1e3df4c700ae0a554bf0a0f02e4c113e70c29a0b5b4bd9819d8bc47",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f8bce5d8f64a4e8cb49754d0796e4449.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=6a141a7bc9c3dab184c95c8097cf1fe1618e11e18e4a6c00d1667e45a6ca66e5",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f8bce5d8f64a4e8cb49754d0796e4449.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9a613f3953b40c68c262f7e46abde73e02ade5d11478575af6908770e8ed5444",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f8bce5d8f64a4e8cb49754d0796e4449.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=73e0dc62d01956668a0f06bf6860c1353136cbb3f0e1fdc5c0e36bb106bb5b3b"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 18,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ae3a24c42ded32acb191b7aa37a78bc9d99f8aa5378f4a73c4edf480cf6ed932",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9c51c750f834fc726ea96b5b18cc6bc202d1d69b7c97d62ecca87eec53c0a063",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f8bbcd73dff8311eaa16177d9327795ae9e1963fa0f6d74e96506303baec40a5",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=0fd58f7e38877d6d7082b01fdf84f50cd539b13c668a5d4cde90af8a1a5a126d"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/aeb50f360a594cc5bf46eaca899de657.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=25b73912dfebf2296b28af7b6e0a1ffcf36ac0b38f7e5fc16cc8f58c3785ed0e",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/aeb50f360a594cc5bf46eaca899de657.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=e76d41c4a1c6f42bd532fb38d6f6745e285fe2c4909df820c9419278685d27c6",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/aeb50f360a594cc5bf46eaca899de657.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=eb00f6632cb4da5064c50e645a33392dbf75824258ecdcb43876b3f4b81c7b9d",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/aeb50f360a594cc5bf46eaca899de657.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=a9115d6f4b8dbf7887df15cd843fededc59fa09559d560a452c755c8af527a0d"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 20,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ae3a24c42ded32acb191b7aa37a78bc9d99f8aa5378f4a73c4edf480cf6ed932",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9c51c750f834fc726ea96b5b18cc6bc202d1d69b7c97d62ecca87eec53c0a063",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f8bbcd73dff8311eaa16177d9327795ae9e1963fa0f6d74e96506303baec40a5",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=0fd58f7e38877d6d7082b01fdf84f50cd539b13c668a5d4cde90af8a1a5a126d"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f55e5c51c0e5478c89f03b6a3ffe26c2.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=62cb8d58c327da87c95a85f9cb74e0fe883fcb44ec4b388801822df2d6ace12e",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f55e5c51c0e5478c89f03b6a3ffe26c2.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=d986ce37df365d369c98feea7b9bc54e55709db84eeddf8d41a08db22a5880ea",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f55e5c51c0e5478c89f03b6a3ffe26c2.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=cb9e0d56c626857a346fb36ab54195dced218bbea9e2e283040b4b8b8e2da657",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f55e5c51c0e5478c89f03b6a3ffe26c2.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=2113a92e3fa29650f453fe985c06bbfad1bbc5ad2533dcac04da944c687bdf76"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 21,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ae3a24c42ded32acb191b7aa37a78bc9d99f8aa5378f4a73c4edf480cf6ed932",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9c51c750f834fc726ea96b5b18cc6bc202d1d69b7c97d62ecca87eec53c0a063",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f8bbcd73dff8311eaa16177d9327795ae9e1963fa0f6d74e96506303baec40a5",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=0fd58f7e38877d6d7082b01fdf84f50cd539b13c668a5d4cde90af8a1a5a126d"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8fc631fa5928446a9f0c9ef3b59104ac.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=3bb7c6122fa34699f5615816657e574b56efe18fe826e7b38602db64d0b601e2",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8fc631fa5928446a9f0c9ef3b59104ac.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=225aaed92ae6a60fddb7061ac2589c3d2c1972a8ff04fdfa32053f8bbfcdb7ca",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8fc631fa5928446a9f0c9ef3b59104ac.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073309Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f2b47a4fc8fe88d4caa500054fc447b4126b571642e125ce4583b9010f9a75c2",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8fc631fa5928446a9f0c9ef3b59104ac.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=dca14f289935f47ca8eef71ef8c1f7f05f3800c841d155835d7c4ea770a69ea7"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 22,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5b9656c2bfa293facecd545a28aa4aa5a6986c7c075b8901ca3c9106e98764a3",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=98fa36cd63a9bc0b5d716161cb6623cb724aea8e95b67ce3488fce99aec77f4a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=882469965d781d86828ba23963ba5ead6b2b62fb5e68be0af7e21d94f794af00",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c98c34a1b8e288cecd8fa0c38bffb683d5aab2d2593fae4e11e1f366fa235719"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/58c93aceffd24bcb9318398c3da72b08.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=be9226021cfbc4b222e76f85bd035f99f8ef8358dfd2d5fe3be9ae0d72ec4219",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/58c93aceffd24bcb9318398c3da72b08.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=bd890099e053e3ba8eed1fe15ea054b991da657d52b2e89c800e8a763fd38f4b",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/58c93aceffd24bcb9318398c3da72b08.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=42b78373e6b32ba4eeb093a240e6fd63ba93aa8f1226481a10487556bcbc7b00",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/58c93aceffd24bcb9318398c3da72b08.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=517b809395478a6cc5d7092e51903ef26ea7ffc3fd835fa4f8041b578d97d559"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 23,
            "user": {
                "id": "US196446",
                "name": "Richard Morla",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/51955fa599674e2ba806e0fecf1cdfa3.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ee04a0c94ddee7a4da811ec417b3dd2888f226668244e83b6be274dabb8d5037",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/51955fa599674e2ba806e0fecf1cdfa3.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=79d8ce75cf24fe9e91f132742a5d0c11fd907a19e74dcb75cda7375253dc36ff",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/51955fa599674e2ba806e0fecf1cdfa3.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=631ec5928e99aeaf0922e83daf40be4d697abfd829f26419ab87ad265efb5669",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/51955fa599674e2ba806e0fecf1cdfa3.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=646c453a63c821dd89b876c1b493de97ad04e4810aa34413ff6b97ca8f5a8c38"
                },
                "email": "richard@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/4764fc07a95d4922a5bba94b06587526.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=b0195bb4ee50304104058eb2c7d7d19fea046a31b1a79f26fbea78108d60ab73",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/4764fc07a95d4922a5bba94b06587526.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=451ad58d18e0048a0e7602b0b6ea9ecb39f3c66f767e24e1aa3e1199879aca1d",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/4764fc07a95d4922a5bba94b06587526.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=af60ebf37b39c508357432724114e2a77bdd3274392f7dddc60c70c7a615fa6b",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/4764fc07a95d4922a5bba94b06587526.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=486f81dca7a116badbe50cdc75298b9699a4841c51fdd165bd94996cf99cf58b"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 24,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5b9656c2bfa293facecd545a28aa4aa5a6986c7c075b8901ca3c9106e98764a3",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=98fa36cd63a9bc0b5d716161cb6623cb724aea8e95b67ce3488fce99aec77f4a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=882469965d781d86828ba23963ba5ead6b2b62fb5e68be0af7e21d94f794af00",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c98c34a1b8e288cecd8fa0c38bffb683d5aab2d2593fae4e11e1f366fa235719"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/41cfb8b38f72457eae4ae066efc433b8.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=352cde6ed2e9e57e880ff58f6f74f4cbef6ea64abadc69f4d1eaefcafaa6daea",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/41cfb8b38f72457eae4ae066efc433b8.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=afa336542631fcd0ddfe8d89b77d0f7091efd5868b7612aedd4f6bf74b63312a",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/41cfb8b38f72457eae4ae066efc433b8.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f62b68cf5e8ce47b565991cd5f27dbea95e3e5caac1d0cc5defdbf84937e81b2",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/41cfb8b38f72457eae4ae066efc433b8.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=6d9f0186b1d5286721fc2fa81294f3c3f9f36b6f84928344dd016dc9e1c447ff"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 25,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5b9656c2bfa293facecd545a28aa4aa5a6986c7c075b8901ca3c9106e98764a3",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=98fa36cd63a9bc0b5d716161cb6623cb724aea8e95b67ce3488fce99aec77f4a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=882469965d781d86828ba23963ba5ead6b2b62fb5e68be0af7e21d94f794af00",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c98c34a1b8e288cecd8fa0c38bffb683d5aab2d2593fae4e11e1f366fa235719"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8629b7d8695f4ca4abff5a589dc5086d.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9bcaf2a05c6d3f71855b3c90445c97502eea561ecaf9a108df874708e8d20c8e",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8629b7d8695f4ca4abff5a589dc5086d.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=3ed32f1910a5feadcd6999d826b66be7d1c71788095fc349e016622688e65e78",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8629b7d8695f4ca4abff5a589dc5086d.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=e17d37de88676672cf80901645f33de8bd07b10d7cd8678ea77a84a86c708b73",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8629b7d8695f4ca4abff5a589dc5086d.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=df84a19ed7602d2b7109e671087a7c5d4d4597e30e20419122680c6db105a0a5"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 26,
            "user": {
                "id": "US709A21",
                "name": "Antonio Ferrando",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ecaf0e09c6b2d4d918d931573a1afea8b139f5aeeb52cc8be8206088159c39b9",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5f975a2ba9d9187ec36a4a4c9c0514b273a5ea249461a73cdaa0a1d1975ac05a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4e22f40039f066c623fc1fd4ef0423e3e8da2d0421fec92ea19d9b71b0635833",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4d6953b36a419153e4663aa50ec4cfadd09f90e52de5d3a34c12831177c4692e"
                },
                "email": "antonio@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/fffd3cc2876a493cb508cda1e7d0e2c5.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=3fa4eacb58333235a2c16f769dfa339c27abd6c4440a4c993ba45e58555a40c5",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/fffd3cc2876a493cb508cda1e7d0e2c5.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ceedc651b80e1d25790a77571b76c14af20fbf909ba0f2d9d1699a09dc6767d3",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/fffd3cc2876a493cb508cda1e7d0e2c5.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=684fa6ca858ddb356ad3ddb93893394137417355244c672f8bcb9b21b412e006",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/fffd3cc2876a493cb508cda1e7d0e2c5.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=aeab04bfbebe91b030aa30fa9a0f4891d7ea70fd2355fb8c13ac8adc174844b6"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 27,
            "user": {
                "id": "US709A21",
                "name": "Antonio Ferrando",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ecaf0e09c6b2d4d918d931573a1afea8b139f5aeeb52cc8be8206088159c39b9",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5f975a2ba9d9187ec36a4a4c9c0514b273a5ea249461a73cdaa0a1d1975ac05a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4e22f40039f066c623fc1fd4ef0423e3e8da2d0421fec92ea19d9b71b0635833",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4d6953b36a419153e4663aa50ec4cfadd09f90e52de5d3a34c12831177c4692e"
                },
                "email": "antonio@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/3d51cfdb569a44daa247fb7a1a158315.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=eec2ec36ad098edd0bb8719187870d05a0d24ce94cfa94071542c475aa93442a",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/3d51cfdb569a44daa247fb7a1a158315.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=3ac3a4517aa90ef4d219e917e7acec240368605555144aee72971d0378e829e8",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/3d51cfdb569a44daa247fb7a1a158315.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c0e6aa7f6de20d99538bd8b7ccf4ad0dd5ce95f024bd964805ffda32ebf6ea1e",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/3d51cfdb569a44daa247fb7a1a158315.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ef3ec2fe9c0946aee0b073dc06714de19d4e6e177b02ebe9bd05f58d72a1b6f1"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 28,
            "user": {
                "id": "US709A21",
                "name": "Antonio Ferrando",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ecaf0e09c6b2d4d918d931573a1afea8b139f5aeeb52cc8be8206088159c39b9",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5f975a2ba9d9187ec36a4a4c9c0514b273a5ea249461a73cdaa0a1d1975ac05a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4e22f40039f066c623fc1fd4ef0423e3e8da2d0421fec92ea19d9b71b0635833",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4d6953b36a419153e4663aa50ec4cfadd09f90e52de5d3a34c12831177c4692e"
                },
                "email": "antonio@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/e6b9849e66824e2ba8587f30f5944773.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9d4bf531bff2ca8dbb97bca12125be4ce665759af9544c3b3340510948d6dd2d",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/e6b9849e66824e2ba8587f30f5944773.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=543e2a2d5f65d0a5252c3cbdcdae7985a1b1692e691edc9f798092128c105739",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/e6b9849e66824e2ba8587f30f5944773.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=df07f704f799c44802cc7336e526b4e2663cd967243859443fea8da4362a06cc",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/e6b9849e66824e2ba8587f30f5944773.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=675dc443ff9e315b7575de7824f93cde81bc6c89374ea1472e8a4679ba449468"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 29,
            "user": {
                "id": "US709A21",
                "name": "Antonio Ferrando",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ecaf0e09c6b2d4d918d931573a1afea8b139f5aeeb52cc8be8206088159c39b9",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5f975a2ba9d9187ec36a4a4c9c0514b273a5ea249461a73cdaa0a1d1975ac05a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4e22f40039f066c623fc1fd4ef0423e3e8da2d0421fec92ea19d9b71b0635833",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4d6953b36a419153e4663aa50ec4cfadd09f90e52de5d3a34c12831177c4692e"
                },
                "email": "antonio@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/e8d6d3f8bb6242fb817edd838b31e599.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=24c6bb2ea1dd2a586fd9245637570c1337d7bb8b73373ea25a9ee2c7a026caee",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/e8d6d3f8bb6242fb817edd838b31e599.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=466ff87b9d84483a43aac1a242e5ad906763a839a843e074f3e2a5076db7d9ab",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/e8d6d3f8bb6242fb817edd838b31e599.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f7452b46da69deef134f31dcd995b49fe5ecb4fe3f31d59413a84cf17736a8ee",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/e8d6d3f8bb6242fb817edd838b31e599.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4b55317085924153e188d66801aebacc50246d5df53fa5f18353559dd6b85db4"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 30,
            "user": {
                "id": "US709A21",
                "name": "Antonio Ferrando",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ecaf0e09c6b2d4d918d931573a1afea8b139f5aeeb52cc8be8206088159c39b9",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5f975a2ba9d9187ec36a4a4c9c0514b273a5ea249461a73cdaa0a1d1975ac05a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4e22f40039f066c623fc1fd4ef0423e3e8da2d0421fec92ea19d9b71b0635833",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4d6953b36a419153e4663aa50ec4cfadd09f90e52de5d3a34c12831177c4692e"
                },
                "email": "antonio@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/9692db8b9ba64aa5bdb270183dd7413b.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=055a9b019cd73e2c903d169e7824ed43f39c0ad76bcad071eb9c852f03fdbba4",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/9692db8b9ba64aa5bdb270183dd7413b.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=a31ab493ebd60bb551138dd3fe7e14bd71fc2b9bc5b0b576512b724d036d6bc6",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/9692db8b9ba64aa5bdb270183dd7413b.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=3fbdcdb983f1796fbce663d63e681c558b2d55c218d4b08e0e0576a6ef0a09c6",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/9692db8b9ba64aa5bdb270183dd7413b.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=31bbe44302d0a2879725611d44bf3d6f19bf3193dcdf12ffc079d8715b36e210"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 31,
            "user": {
                "id": "US709A21",
                "name": "Antonio Ferrando",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ecaf0e09c6b2d4d918d931573a1afea8b139f5aeeb52cc8be8206088159c39b9",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5f975a2ba9d9187ec36a4a4c9c0514b273a5ea249461a73cdaa0a1d1975ac05a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4e22f40039f066c623fc1fd4ef0423e3e8da2d0421fec92ea19d9b71b0635833",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4d6953b36a419153e4663aa50ec4cfadd09f90e52de5d3a34c12831177c4692e"
                },
                "email": "antonio@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f8f6ed8797f24de095762988f008607d.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=3a8a875fa04e66aef4a2d807789c704d4cc65ebd28ff1387bb1ba76dc3c19e9d",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f8f6ed8797f24de095762988f008607d.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=2c935119754b97828b0946e1f0e1a662ab2dc748e3aaba5b80654c647d8bcfe2",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f8f6ed8797f24de095762988f008607d.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=6ef513c83c8acac6e92308227e886514b23dd559af3ad999da0270fa7fd1d735",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f8f6ed8797f24de095762988f008607d.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=1a88973ada3804c3a483e4944d97e559ea7253a89c00b1d0e3aca2253a2cd0be"
            },
            "coordinates": "34.663963333333335 - 135.43180833333332",
            "tagged_users": []
        },
        {
            "id": 32,
            "user": {
                "id": "US709A21",
                "name": "Antonio Ferrando",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ecaf0e09c6b2d4d918d931573a1afea8b139f5aeeb52cc8be8206088159c39b9",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5f975a2ba9d9187ec36a4a4c9c0514b273a5ea249461a73cdaa0a1d1975ac05a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4e22f40039f066c623fc1fd4ef0423e3e8da2d0421fec92ea19d9b71b0635833",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4d6953b36a419153e4663aa50ec4cfadd09f90e52de5d3a34c12831177c4692e"
                },
                "email": "antonio@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/0e9eb64e69f6461081069c0b1f2100ef.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=dee110b27df9407cadd2106a2c47da91932e57221236c6bbd456ad6f4c991122",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/0e9eb64e69f6461081069c0b1f2100ef.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=b18b19557f7d229f0a15ff34d8bdaea5a8a6aef7b8dba39f8d35f0d005554c7e",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/0e9eb64e69f6461081069c0b1f2100ef.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=6af479ca92e4c45dc2f78d04f795e55d1d571507ea18fc30f1c1b7109a20721f",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/0e9eb64e69f6461081069c0b1f2100ef.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=8397b44e8ef6f2a6540616af85b1b4bfa80bf2e93fe637236b4610f76c39a5ee"
            },
            "coordinates": "34.66416666666667 - 135.43406666666667",
            "tagged_users": []
        },
        {
            "id": 33,
            "user": {
                "id": "US709A21",
                "name": "Antonio Ferrando",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ecaf0e09c6b2d4d918d931573a1afea8b139f5aeeb52cc8be8206088159c39b9",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5f975a2ba9d9187ec36a4a4c9c0514b273a5ea249461a73cdaa0a1d1975ac05a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4e22f40039f066c623fc1fd4ef0423e3e8da2d0421fec92ea19d9b71b0635833",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4d6953b36a419153e4663aa50ec4cfadd09f90e52de5d3a34c12831177c4692e"
                },
                "email": "antonio@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8ae2a56bfc80475d833b0eb526b81bb5.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=56c6e82fa2d01fe565e95fe6863f43d2d7cc9ec8bec75217b594d62a159cedd4",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8ae2a56bfc80475d833b0eb526b81bb5.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=33b18d29e9e88a3d0ce1d08468473d9a9ee4a7e0b2d6762ec8e39717b637a73d",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8ae2a56bfc80475d833b0eb526b81bb5.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=48a5284082dedb09955c2abb6f0b68a0b635a24db185fd1f6083080d0046a6ab",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8ae2a56bfc80475d833b0eb526b81bb5.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=7b13d76a7a76c9ab47cbdc78823c9b876d02ec85c392283798d73cafd2e75127"
            },
            "coordinates": "34.66598666666667 - 135.43321166666666",
            "tagged_users": []
        },
        {
            "id": 34,
            "user": {
                "id": "US709A21",
                "name": "Antonio Ferrando",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ecaf0e09c6b2d4d918d931573a1afea8b139f5aeeb52cc8be8206088159c39b9",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5f975a2ba9d9187ec36a4a4c9c0514b273a5ea249461a73cdaa0a1d1975ac05a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4e22f40039f066c623fc1fd4ef0423e3e8da2d0421fec92ea19d9b71b0635833",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4d6953b36a419153e4663aa50ec4cfadd09f90e52de5d3a34c12831177c4692e"
                },
                "email": "antonio@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/b038e55428674d2ca17dc908bf736790.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=bcb44dd6cbf5e4c00980393a3f17e929a5aca9ad175e9304907eda0240138915",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/b038e55428674d2ca17dc908bf736790.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=eb997018d38492709c749f17dc85953627c5ebcb6264ca9a26d89430bba29ab7",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/b038e55428674d2ca17dc908bf736790.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=b2975b5d145692bb2e4db44d77726be16cc3d075655a90b31a04391846916260",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/b038e55428674d2ca17dc908bf736790.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=b13e8fdadc83b23f3b53d662ccad9eeb39833622da45442386133364c5a1b8cf"
            },
            "coordinates": "34.667941666666664 - 135.436295",
            "tagged_users": []
        },
        {
            "id": 35,
            "user": {
                "id": "US709A21",
                "name": "Antonio Ferrando",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ecaf0e09c6b2d4d918d931573a1afea8b139f5aeeb52cc8be8206088159c39b9",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5f975a2ba9d9187ec36a4a4c9c0514b273a5ea249461a73cdaa0a1d1975ac05a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4e22f40039f066c623fc1fd4ef0423e3e8da2d0421fec92ea19d9b71b0635833",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/4d58b70f807644b4af7d76a0a08edce6.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4d6953b36a419153e4663aa50ec4cfadd09f90e52de5d3a34c12831177c4692e"
                },
                "email": "antonio@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f5e851edffc04ccabc0a47871d6b070b.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=72e1abda7a91e555c5fd4d291ea59a7a292bd02506e4b7aeefed456b9715e118",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f5e851edffc04ccabc0a47871d6b070b.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=2bddc931e4e678d0e3943d4c2765087ef339db3c746427946d317ff103e7c8ac",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f5e851edffc04ccabc0a47871d6b070b.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=581992b0c5157e8e2f1753dcf7c4914d519b81248012408de631f83b95e71229",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/f5e851edffc04ccabc0a47871d6b070b.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=926e96d02d2c7e8c9fc18bb52b6dbd7251a88178728fe99c802ae0cd161d9583"
            },
            "coordinates": "34.667946666666666 - 135.43628",
            "tagged_users": []
        },
        {
            "id": 36,
            "user": {
                "id": "US4F0E3E",
                "name": "Fer Salom",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=31d3fb0d4b587a3e06bf1bb544a1a11680d8805ec481d7a74a235814dd1abef4",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=be7d9909eb722ace93eab4ae0be7f903562362dc30447e255d8cba4a0d12bf0c",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=a788f98211e893181da86fc542b0580195dd956469eea099068eb16c6053d9b7",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=96a20c8a41af10393151ea58492180355e113c73b563a98557e700e4ddb4e4fb"
                },
                "email": "fer@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/67b241636565454b83539af2f43e6638.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=41c1529d1a56fe8dcdf9cdab07ef5f7738ace634c6f56b50ae13d0f54701321d",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/67b241636565454b83539af2f43e6638.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=dd513dd89a1835a824b6d9ff04624cd067ab6fd392f3fc6f7d0527d12a967154",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/67b241636565454b83539af2f43e6638.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=899bcde866e06519720e698d5f55f0581d7dfde64002b5ce5196708c302ab1a5",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/67b241636565454b83539af2f43e6638.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=fac255e6ec09c1705fa38b87c67c39c01ea585df470390520939d95f962dbfda"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 37,
            "user": {
                "id": "US4F0E3E",
                "name": "Fer Salom",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=31d3fb0d4b587a3e06bf1bb544a1a11680d8805ec481d7a74a235814dd1abef4",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=be7d9909eb722ace93eab4ae0be7f903562362dc30447e255d8cba4a0d12bf0c",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=a788f98211e893181da86fc542b0580195dd956469eea099068eb16c6053d9b7",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=96a20c8a41af10393151ea58492180355e113c73b563a98557e700e4ddb4e4fb"
                },
                "email": "fer@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/60e20547de6f478eacbe9ab67a24f9c9.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ab0fc6b340a30dba4b166eda78da81110152c07808ec30b8e3459d46c3ad38c9",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/60e20547de6f478eacbe9ab67a24f9c9.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=6c86e8d1a19c681c1b3dc135bcfdfef5cba2b2b4fd9755417f4100c00d6a056c",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/60e20547de6f478eacbe9ab67a24f9c9.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5b5c771851b31604bcab23c0ffa8aa9acfbf1f0a59c0684f7ca77a971f2bc1db",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/60e20547de6f478eacbe9ab67a24f9c9.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=b6b513d0664e15c8fd8ccffa981a5454aa4ca7991ab179699b9e0ba3976502f6"
            },
            "coordinates": "34.6689 - 135.49978666666667",
            "tagged_users": []
        },
        {
            "id": 38,
            "user": {
                "id": "US4F0E3E",
                "name": "Fer Salom",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=31d3fb0d4b587a3e06bf1bb544a1a11680d8805ec481d7a74a235814dd1abef4",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=be7d9909eb722ace93eab4ae0be7f903562362dc30447e255d8cba4a0d12bf0c",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=a788f98211e893181da86fc542b0580195dd956469eea099068eb16c6053d9b7",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=96a20c8a41af10393151ea58492180355e113c73b563a98557e700e4ddb4e4fb"
                },
                "email": "fer@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/5b5324c3bab94ef491ef5c7520582063.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c2913fd43c99c92b77dbd1775d774e667cc24d56b194dc5123b505bdfcc29334",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/5b5324c3bab94ef491ef5c7520582063.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=dfd65be7f6578aa1e4ba1871ff94590bd17d4e6722a54a93c45ba73b5d66a962",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/5b5324c3bab94ef491ef5c7520582063.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=7978c28ce04d2836f1150f491636a136053ddde58c54c713a28fcae5c35007f0",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/5b5324c3bab94ef491ef5c7520582063.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ae3314e1c89594bf17dd3d0ab19597457d7def117f286a6afe5213b8b6669081"
            },
            "coordinates": "35.002966666666666 - 135.76107833333333",
            "tagged_users": []
        },
        {
            "id": 39,
            "user": {
                "id": "US4F0E3E",
                "name": "Fer Salom",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=31d3fb0d4b587a3e06bf1bb544a1a11680d8805ec481d7a74a235814dd1abef4",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=be7d9909eb722ace93eab4ae0be7f903562362dc30447e255d8cba4a0d12bf0c",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=a788f98211e893181da86fc542b0580195dd956469eea099068eb16c6053d9b7",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=96a20c8a41af10393151ea58492180355e113c73b563a98557e700e4ddb4e4fb"
                },
                "email": "fer@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/16d11d9408764bebb48864e70a632c3c.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4f5aad14a2344672cb423b28ebb599af9eba8b1793dccac032aa9a447c89b61e",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/16d11d9408764bebb48864e70a632c3c.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=97993a285c556159d60b9f28e9cc094f892c7efdfb53174162c755dd16084c00",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/16d11d9408764bebb48864e70a632c3c.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=a550cb0754204b5ea7a9d063a3bef38a38a8fccf042ddb985d8b499125777b4b",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/16d11d9408764bebb48864e70a632c3c.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=04c4528e604b817360d82e23b563d5b18c3e1be69090216a63b6cd79c41f9647"
            },
            "coordinates": "34.682986666666665 - 135.83425833333334",
            "tagged_users": []
        },
        {
            "id": 40,
            "user": {
                "id": "US4F0E3E",
                "name": "Fer Salom",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=31d3fb0d4b587a3e06bf1bb544a1a11680d8805ec481d7a74a235814dd1abef4",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=be7d9909eb722ace93eab4ae0be7f903562362dc30447e255d8cba4a0d12bf0c",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=a788f98211e893181da86fc542b0580195dd956469eea099068eb16c6053d9b7",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/9d4cd0f55a45420eae5024581ec44b3e.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=96a20c8a41af10393151ea58492180355e113c73b563a98557e700e4ddb4e4fb"
                },
                "email": "fer@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/afec226cef364b6391e19dc3d3ee019b.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=649f4d7aff7be5dba03bb567895e96a5a73fd2e4383bc471c5c277c5fbff9a53",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/afec226cef364b6391e19dc3d3ee019b.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=25203bbcebcadb266ddabaa5525d2ed0bb6f30a904ba20ae573f49581f625a5d",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/afec226cef364b6391e19dc3d3ee019b.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c077aa410e6930bb21ead71e4fdda3b44fa2e47fae2e8abb5a770da778c308da",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/afec226cef364b6391e19dc3d3ee019b.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=cc91b36d72ccd28240ad32d239976c008039b3f48ae09243ce4c1ad449fb47f5"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 41,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5b9656c2bfa293facecd545a28aa4aa5a6986c7c075b8901ca3c9106e98764a3",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=98fa36cd63a9bc0b5d716161cb6623cb724aea8e95b67ce3488fce99aec77f4a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=882469965d781d86828ba23963ba5ead6b2b62fb5e68be0af7e21d94f794af00",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c98c34a1b8e288cecd8fa0c38bffb683d5aab2d2593fae4e11e1f366fa235719"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/0792d3c063e94764993fb68174ede0d8.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9d68de4ece98d9c225ae5ee9f58c1ae0e646efd84bb2dbdbd733000e8b00baeb",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/0792d3c063e94764993fb68174ede0d8.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=7a4f3326f14ead0f6dcec6c63b403638aa83228f9cf2998e31a375cf92fa349e",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/0792d3c063e94764993fb68174ede0d8.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=0579b46d08361f3b38038594a223e72b998dc265d9b701854be1ea4b23aed939",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/0792d3c063e94764993fb68174ede0d8.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=24e2b996fe698d01f5f5820fa7e5310e6efb4e3ae87c521c3249696392ffc461"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 42,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5b9656c2bfa293facecd545a28aa4aa5a6986c7c075b8901ca3c9106e98764a3",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=98fa36cd63a9bc0b5d716161cb6623cb724aea8e95b67ce3488fce99aec77f4a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=882469965d781d86828ba23963ba5ead6b2b62fb5e68be0af7e21d94f794af00",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c98c34a1b8e288cecd8fa0c38bffb683d5aab2d2593fae4e11e1f366fa235719"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/5b581c2d515a4c4ea6a8c07f17a0e75f.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=e32380bc4ed141b69dc2d14ec80275c525853b043bc379d33dc6c9d26b83375d",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/5b581c2d515a4c4ea6a8c07f17a0e75f.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9f982ea66e8e05fd6137e97fe316b0d453483002e3e9a4f12144e4d7d5dbbeff",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/5b581c2d515a4c4ea6a8c07f17a0e75f.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=e86b4b081a086ee947d8738862103f9cecd69692e4014ab41620e782e5b8c777",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/5b581c2d515a4c4ea6a8c07f17a0e75f.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=6d26ff05e0c09bbce91ca764febbd4f8a1fafe78659e74d6433d142b76dfae81"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 43,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5b9656c2bfa293facecd545a28aa4aa5a6986c7c075b8901ca3c9106e98764a3",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=98fa36cd63a9bc0b5d716161cb6623cb724aea8e95b67ce3488fce99aec77f4a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=882469965d781d86828ba23963ba5ead6b2b62fb5e68be0af7e21d94f794af00",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c98c34a1b8e288cecd8fa0c38bffb683d5aab2d2593fae4e11e1f366fa235719"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/db08bb91fd924a6789b0c687b21d964f.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=e774aa61111bf56ea0fbb7a4cbc889db9490a1e22002963ac2fdb7849c5b9b61",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/db08bb91fd924a6789b0c687b21d964f.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=fc1821b3af0089f0e5f5945fdbaa9e253db97731b1206139a262eb642384eec3",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/db08bb91fd924a6789b0c687b21d964f.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=aa71da25b4aaa259ba66c387eaa622bee427ad34a1777fb4a2974b19c2fbcce3",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/db08bb91fd924a6789b0c687b21d964f.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=fb4dd9167071644b4c6ce9e7710e2a1c6f0c9892012702eac53f4e11d6211f27"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 44,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5b9656c2bfa293facecd545a28aa4aa5a6986c7c075b8901ca3c9106e98764a3",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=98fa36cd63a9bc0b5d716161cb6623cb724aea8e95b67ce3488fce99aec77f4a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=882469965d781d86828ba23963ba5ead6b2b62fb5e68be0af7e21d94f794af00",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c98c34a1b8e288cecd8fa0c38bffb683d5aab2d2593fae4e11e1f366fa235719"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/48170f03b2464b6a99f13ec9ff02e3c7.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=7b5fd65cb097497b4ba69fd58ab2ca930cf94ab260a3ede456bc754524984e73",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/48170f03b2464b6a99f13ec9ff02e3c7.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=3d7a30d527a120a490cd1ae655f87038fbe008802d53ae03427181d85fd0775e",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/48170f03b2464b6a99f13ec9ff02e3c7.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=b262f160d57ffafcbc7ef321b374da55ad40ef4b7b89edfe2225c0a2976dc287",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/48170f03b2464b6a99f13ec9ff02e3c7.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=0bc7ad11816eeb0d411f6cd25ff07ca7762670d91de0a612a209db0fe6444c24"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 45,
            "user": {
                "id": "US2A13D2",
                "name": "Aitor Poquet",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5b9656c2bfa293facecd545a28aa4aa5a6986c7c075b8901ca3c9106e98764a3",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=98fa36cd63a9bc0b5d716161cb6623cb724aea8e95b67ce3488fce99aec77f4a",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=882469965d781d86828ba23963ba5ead6b2b62fb5e68be0af7e21d94f794af00",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/3fb29edaa3e740dc9da7619084a4b1f8.png.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c98c34a1b8e288cecd8fa0c38bffb683d5aab2d2593fae4e11e1f366fa235719"
                },
                "email": "aitorpoquet@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/39483fbcaf9d4b08897bdcbef27a17ba.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=22efea6bdc232f760a11fcc7dad24524fc42aeaa862676b97c7d95a49c530f16",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/39483fbcaf9d4b08897bdcbef27a17ba.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f7a0d59ce8f388b64d2b81773887a978a3347ba7dd27e753ae8489a033e950e8",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/39483fbcaf9d4b08897bdcbef27a17ba.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=16738bf0c1c0a94b0798e80846aadf1d14d2992acf1412e74a1b6cdb965127e2",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/39483fbcaf9d4b08897bdcbef27a17ba.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c6cce41e8ab756cd37e1457e20ea34610cc5a4110a91c3a1c0f4a04be2b3e21c"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 46,
            "user": {
                "id": "USBDC391",
                "name": "Aina Moll",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=8cabce12bfe452905c64985b46e851f5b99018a1078d2b418089e5207cf6f15f",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9f5a7d6a643528989d20ca26f15acf7d0c5190ea63d7c32c1517da7402036d32",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4fb43d83b30c2da4be400188ebc8ce74edd4e1b48a272e81522508e571711c9f",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ddd496ec4c2b873163db70e721a4b1bdd66cd7e30a3b9ddb091f6b91896290c2"
                },
                "email": "aina@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/bb311a46b0794fff84fb2cb4123ab6c4.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=598232571954dd9c250779d04e1b11bdce64add7423a4d32d005a68e7bb94d9c",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/bb311a46b0794fff84fb2cb4123ab6c4.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=06ad302607fe400cff083c2171cb798cb506e92a4e72e77f06b46344a536df91",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/bb311a46b0794fff84fb2cb4123ab6c4.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=aa95a4a45bcbc23318f2b6c9b7b744f6e24a679b4031445c28b539b079fd0e68",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/bb311a46b0794fff84fb2cb4123ab6c4.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=494b4ca1e2d87bc700f7bc685a95ba18c72efe89a04045fc0568a44ffc152062"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 47,
            "user": {
                "id": "USBDC391",
                "name": "Aina Moll",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=8cabce12bfe452905c64985b46e851f5b99018a1078d2b418089e5207cf6f15f",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9f5a7d6a643528989d20ca26f15acf7d0c5190ea63d7c32c1517da7402036d32",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4fb43d83b30c2da4be400188ebc8ce74edd4e1b48a272e81522508e571711c9f",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ddd496ec4c2b873163db70e721a4b1bdd66cd7e30a3b9ddb091f6b91896290c2"
                },
                "email": "aina@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8ba9544fdbd8456ea54a45a81adee16c.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=48bd43d1344b091dc81b95717eb0b542a5dc1068aecac930b149015473d72f3d",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8ba9544fdbd8456ea54a45a81adee16c.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=82d37e83211ebbe4f5ef39466a5cdc53a803647e41731d359ac63da328147e57",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8ba9544fdbd8456ea54a45a81adee16c.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c417d1765143729f1232f0bf215f81a9363be07b47a1679fb2c3c191aa257ee6",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/8ba9544fdbd8456ea54a45a81adee16c.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=b0e5fd536785a91c8a2ee04616d41990068a2227e7d53b859dfa7a1b6722dec4"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 48,
            "user": {
                "id": "USBDC391",
                "name": "Aina Moll",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=8cabce12bfe452905c64985b46e851f5b99018a1078d2b418089e5207cf6f15f",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9f5a7d6a643528989d20ca26f15acf7d0c5190ea63d7c32c1517da7402036d32",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4fb43d83b30c2da4be400188ebc8ce74edd4e1b48a272e81522508e571711c9f",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ddd496ec4c2b873163db70e721a4b1bdd66cd7e30a3b9ddb091f6b91896290c2"
                },
                "email": "aina@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/39a3463f00dd4a818ced54e52158ae38.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=08a4bb20d26fcd6496d1c5544b0e419cd54eb87de7910213a7a11764ed5b022b",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/39a3463f00dd4a818ced54e52158ae38.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ac980b511120f7e0695583d61ac361f8fabd11a7f2ae82c9ff728ec3f9496466",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/39a3463f00dd4a818ced54e52158ae38.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=a52797aed0a1a6055a7dd0f287e42b4104397a8888451def9ff5fc0299a156c7",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/39a3463f00dd4a818ced54e52158ae38.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f6a1cb02ab6c4eb8611aeb7e0f542d08d90a16fa02e0148a8caa144c3cee2d78"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 49,
            "user": {
                "id": "USBDC391",
                "name": "Aina Moll",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=8cabce12bfe452905c64985b46e851f5b99018a1078d2b418089e5207cf6f15f",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9f5a7d6a643528989d20ca26f15acf7d0c5190ea63d7c32c1517da7402036d32",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4fb43d83b30c2da4be400188ebc8ce74edd4e1b48a272e81522508e571711c9f",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ddd496ec4c2b873163db70e721a4b1bdd66cd7e30a3b9ddb091f6b91896290c2"
                },
                "email": "aina@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/728296143903443a830054d5170e3f98.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=b1667d42e7d25f5ea48a963770ec109085c0688ba6c290c5f3ea0b29b170029f",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/728296143903443a830054d5170e3f98.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ae228f871c66b55498b39e4c36d685e9ba14e1269e2882289dadf1d7892a6ac1",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/728296143903443a830054d5170e3f98.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=94d1dba629c9aa13c82b759e22fed5924697bc71becc2a198d7330ef207295d7",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/728296143903443a830054d5170e3f98.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=bfb2cb5e7676039f76710130bc326afb704e347157003fcea1177588f75a2283"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        },
        {
            "id": 50,
            "user": {
                "id": "USBDC391",
                "name": "Aina Moll",
                "image": {
                    "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=8cabce12bfe452905c64985b46e851f5b99018a1078d2b418089e5207cf6f15f",
                    "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9f5a7d6a643528989d20ca26f15acf7d0c5190ea63d7c32c1517da7402036d32",
                    "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=4fb43d83b30c2da4be400188ebc8ce74edd4e1b48a272e81522508e571711c9f",
                    "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/image/e26cd91c20a24518af213b947a9c731d.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ddd496ec4c2b873163db70e721a4b1bdd66cd7e30a3b9ddb091f6b91896290c2"
                },
                "email": "aina@rudo.es"
            },
            "image": {
                "file": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c6149b9eb1ff4632bc35d5f4655b0061.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=6865e0b4a700da9ec15abff1b459b0b052678f85b7c4c542012b2867118e0bef",
                "thumbnail": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c6149b9eb1ff4632bc35d5f4655b0061.jpg.128x128_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=036c779fa51d688152dbda8978cfeb1407d506dae6468210420daa4dafd97eee",
                "midsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c6149b9eb1ff4632bc35d5f4655b0061.jpg.720x720_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=e7bff88d5e1e7b9695c12d90e85c466226aaff1eafe2220f1a73b78fde554370",
                "fullsize": "https://rudo.fra1.digitaloceanspaces.com/rudo/media/gallery/c6149b9eb1ff4632bc35d5f4655b0061.jpg.1080x1080_q90.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=VRHK4N7THIJQNLDI3GRJ%2F20230420%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230420T073310Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f24f549aa659a57b342eec5771ddb2beb48bbc16fc5cd74b6f1854907e0dd2e3"
            },
            "coordinates": "0.0 - 0.0",
            "tagged_users": []
        }
      ]
    
     })['photos'] as List).map((e) => Photo.fromJson(e)).toList();
    return photos;
  }
}