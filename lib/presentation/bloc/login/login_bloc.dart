import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rudo_app_clone/data/model/user/user_auth.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/data/service/auth_service.dart';
import 'package:rudo_app_clone/domain/use_cases/auth/google_sigin_use_case.dart';
import 'package:rudo_app_clone/domain/use_cases/auth/refresh_token_use_case.dart';
import 'package:rudo_app_clone/presentation/bloc/login/login_event.dart';
import 'package:rudo_app_clone/presentation/bloc/login/login_state.dart';

class LoginBloc extends Bloc<LogInEvent,LogInState>{
  
  
  LoginBloc() : super (NoContent()){
    
    //final GoogleLoginUseCase loginUseCase = GoogleSignI();
    
    final GoogleSigInUseCase googleSigInUseCase = GoogleSigInUseCase();
    final CheckValidTokenUseCase checkValidTokenUseCase = CheckValidTokenUseCase();
    ///
    /// evento login
    /// 
    /// llama al caso de uso, si todo va bien devuelve el usuario, sino un error
    /// 
    /// @event.credentials json con username y password
    /// 
    ///
    on<LogIn>( //----------------------------------
      (event, emit) async{
        emit(Loading());
        
        try{
          
          UserData? user = await googleSigInUseCase.call();
          
          if(user!=null){
            emit(Loged(user)); // ------------------------------------- return user
          }
          // canceló la llamada
          else{
            emit(NoContent()); // ------------------------------------- return no content
          }
          

        }catch(e){
          print("ERROR: $e");
          emit(Error("Error inseperado al iniciar sesion")); // ----- return error
        }
        
        
      },
    );


  }


  



  
}