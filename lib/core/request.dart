import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'constants.dart';

class Request {
  
  final Dio dio = Dio();

  // singleton pattern
  Request._(){
    updateDioInterceptors();
  }
  static final instance = Request._();
  

  void updateAuthorization(String token) {
    dio.options.headers['authorization'] = 'Bearer $token';
  }

  void updateDioInterceptors() {
    dio.options = BaseOptions(
      receiveDataWhenStatusError: true,
      baseUrl: Constants.baseUrl,
      validateStatus: (value) {
        return value! <= 500;
      },
      headers: {
        'Accept': 'application/json',
        'X-API-ACCESS-TOKEN': Constants.apiKey,
      },
    );
    dio.interceptors.add(
        LogInterceptor(
          requestBody: kDebugMode ? true : false,
          responseBody: kDebugMode ? true : false,
          requestHeader: kDebugMode ? true : false,
        ),
      );
  }

  // requests
  Future<Response> get(String path, {Map<String,dynamic>? headers}) async {
    if(headers!=null){
      dio.options.headers.addAll(headers);
    }
    return await dio.get(path);
  }

  Future<Response> post(String path, {Object? data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> patch(String path, {Object? data}) async {
    return await dio.patch(path, data: data);
  }
}