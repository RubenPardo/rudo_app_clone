
import 'dart:convert';

class AuthToken{

  final String accessToken,refreshToken;
  final DateTime expiryDate;

  static const String storageKey = "authTokenkey";

  AuthToken({required this.accessToken,required this.expiryDate, required this.refreshToken,});


  factory AuthToken.fromJsonToken(Map<String,dynamic> jsonToken){
    // the expiryDate can be with expires_in o expires_at
    var expiryDateTmp = jsonToken['expires_in'] != null 
        ? DateTime.now().add(Duration(milliseconds: jsonToken['expires_in']))
        : DateTime.fromMillisecondsSinceEpoch(jsonToken['expires_at']);
    return AuthToken(
      accessToken: jsonToken['access_token'], 
      expiryDate: expiryDateTmp, 
      refreshToken: jsonToken['refresh_token'] 
    );
  }

  factory AuthToken.fromStringSecureStorage(String tokenString){
    return AuthToken.fromJsonToken(const JsonDecoder().convert(tokenString));
  }

  String toStringSecureStorage(){
    return const JsonEncoder().convert({
      'access_token': accessToken, 
      'expires_at': expiryDate.millisecondsSinceEpoch, 
      'refresh_token': refreshToken 
    });
  }


  @override
  String toString() {
    return "AuthToken [rawToken: $accessToken, expiryDate: ${expiryDate.millisecondsSinceEpoch}, refresh_token: $refreshToken]";
  }
  

  bool isExpired(){
    return expiryDate.millisecondsSinceEpoch < DateTime.now().millisecondsSinceEpoch;
  }

}