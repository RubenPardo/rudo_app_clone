
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';
import 'package:rudo_app_clone/domain/use_cases/sesame/get_check_info_usecase.dart';
import 'package:rudo_app_clone/presentation/bloc/sesame/sesame_event.dart';
import 'package:rudo_app_clone/presentation/bloc/sesame/sesame_state.dart';

class SesameBloc extends Bloc<SesameEvent,SesameState>{
  
  
  SesameBloc() : super (NoLinked()){
    

    /// used when the user does have the sesame linked, get all the data
    on<InitSesame>( //----------------------------------
      (event, emit) async{
        emit(Loading());
        CheckInfo checkInfo;

        try{
          checkInfo = await GetCheckInfoUseCase().call();

          emit(Loaded(checkInfo));
        }catch(e){
          emit(Error(e.toString()));
        }

       
        /*if(await LocationService.isServiceEnabled()){
                log('Activado');
                if(await LocationService.handleLocationPermission() == LocationPermission.whileInUse 
                  || await LocationService.handleLocationPermission() == LocationPermission.always ){
                    log((await LocationService.getPosition()).toString());
                  }else{
                    log('????');
                  }
              }else{
                log('Desacvtivado');
              }*/
      },
    );


  }


  



  
}