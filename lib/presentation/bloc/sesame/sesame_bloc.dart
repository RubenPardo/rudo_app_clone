
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/core/request.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';
import 'package:rudo_app_clone/presentation/bloc/login/login_event.dart';
import 'package:rudo_app_clone/presentation/bloc/sesame/sesame_event.dart';
import 'package:rudo_app_clone/presentation/bloc/sesame/sesame_state.dart';

class SesameBloc extends Bloc<SesameEvent,SesameState>{
  
  
  SesameBloc() : super (NoContent()){
    
    

    /// used when the user does have the sesame linked, get all the data
    on<InitSesame>( //----------------------------------
      (event, emit) async{
        
      },
    );


  }


  



  
}