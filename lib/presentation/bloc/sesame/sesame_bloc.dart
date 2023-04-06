
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/data/model/sesame/check.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';
import 'package:rudo_app_clone/data/model/sesame/check_type.dart';
import 'package:rudo_app_clone/domain/use_cases/sesame/get_check_info_usecase.dart';
import 'package:rudo_app_clone/domain/use_cases/update_check_info_use_case.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/sesame/sesame_event.dart';
import 'package:rudo_app_clone/presentation/bloc/sesame/sesame_state.dart';

class SesameBloc extends Bloc<SesameEvent,SesameState>{
  
  CheckInfo? checkInfo;
  
  SesameBloc() : super (NoLinked()){
    

    /// used when the user does have the sesame linked, get all the data
    on<InitSesame>( //----------------------------------
      (event, emit) async{
        emit(Loading());

        try{
          checkInfo = await GetCheckInfoUseCase().call();

          emit(Loaded());
        }catch(e){
          emit(Error(e.toString()));
        } 
      },
    );

    on<AddCheck>( //----------------------------------
      (event, emit) async{
        emit(Loading());

        try{
          log('Last status: ${checkInfo!.lastCheck.status}');
          if(checkInfo!.lastCheck.status == CheckType.pause && event.checkType == CheckType.checkIn){
            // deactivate the pause,
            log('Se envia: ${CheckType.pause.value}');
            await CheckInUseCase().call(CheckType.pause);
            await CheckInUseCase().call(CheckType.checkIn);
          }else{
            log('Se envia: ${event.checkType.value}');
            await CheckInUseCase().call(event.checkType);
          }
          checkInfo = await GetCheckInfoUseCase().call();
          emit(Loaded());
        }catch(e){
          emit(Error(e.toString()));
        } 
      },
    );


  }


  



  
}