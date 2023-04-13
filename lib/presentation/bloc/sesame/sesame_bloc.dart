
import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/core/utils.dart';
import 'package:rudo_app_clone/data/model/sesame/check.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';
import 'package:rudo_app_clone/data/model/sesame/check_type.dart';
import 'package:rudo_app_clone/domain/use_cases/sesame/get_check_info_usecase.dart';
import 'package:rudo_app_clone/domain/use_cases/update_check_info_use_case.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/sesame/sesame_event.dart';
import 'package:rudo_app_clone/presentation/bloc/sesame/sesame_state.dart';
import 'package:rxdart/rxdart.dart';

class SesameBloc extends Bloc<SesameEvent,SesameState>{
  
  CheckInfo? checkInfo;

  final StreamController<String> _timerStreamController = BehaviorSubject<String>();
  /// atributes to control the working timer 
  Timer? workingTimer;
  Duration duration = const Duration();
 String workingTime = '00:00';

  /// atributes to control the pause timer 
  Timer? pauseTimer;
  String _pauseTime = '00:00';
  Duration durationPause = const Duration();

  Stream<String> get timerStream {
    return _timerStreamController.stream;
  } 
  
  SesameBloc() : super (NoLinked()){
    


     /// start a timer of working time or paused time
  void initTimer(CheckInfo info){

    

    if(info.lastCheck.status == CheckType.checkIn){
     
      duration = info.getDurationLastCheck();
      workingTime = '${duration.toString().split(':')[0]}:${duration.toString().split(':')[1]}';
      _timerStreamController.add(workingTime);
      
      // is working
      // pause if possible the two timers
      if(pauseTimer!=null && pauseTimer!.isActive){
        pauseTimer!.cancel();
      }

      if(workingTimer!=null && workingTimer!.isActive){
        workingTimer!.cancel();
      }
      // init the work timer
      workingTimer = Timer.periodic(const Duration(seconds: 30), (timer) { 
          
            duration = duration + const Duration(seconds: 30);
            workingTime = duration.toStringHoursMinutes();
            _timerStreamController.add(workingTime);
        
      });
    }else{
      
    
        duration = info.getDurationLastCheck();
        _pauseTime =  duration.toStringHoursMinutes();
        _timerStreamController.add(_pauseTime);
      
      // is pause
      // pause if possible the two timers
      if(pauseTimer!=null && pauseTimer!.isActive){
        pauseTimer!.cancel();
      }

      if(workingTimer!=null && workingTimer!.isActive){
        workingTimer!.cancel();
      }

      // init the pause timer
      pauseTimer = Timer.periodic(const Duration(seconds: 30), (timer) { 
        
            duration = duration + const Duration(seconds: 30);
            _pauseTime = '${duration.toString().split(':')[0]}:${duration.toString().split(':')[1]}';
            _timerStreamController.add(_pauseTime);
      });
    }

     

  }


    /// used when the user does have the sesame linked, get all the data
    on<InitSesame>( //----------------------------------
      (event, emit) async{
        if(!event.fromMemory){
          emit(Loading());

          try{
            checkInfo = await GetCheckInfoUseCase().call();
            initTimer(checkInfo!);
            emit(Loaded());
          }catch(e){
            emit(Error(e.toString()));
          } 
        }else{
          emit(Loaded());
        }
      },
    );

    on<AddCheck>( //----------------------------------
      (event, emit) async{
        emit(Loading());

        try{
          log('CHECK - Last status: ${checkInfo!.lastCheck.status}');
          log('CHECK - Se envia: ${event.checkType.value}');
          await CheckInUseCase().call(event.checkType);
          /*if(checkInfo!.lastCheck.status == CheckType.pause && event.checkType == CheckType.checkIn){
            // deactivate the pause,
            log('CHECK - Se envia: ${CheckType.pause.value}');
            await CheckInUseCase().call(CheckType.checkIn);
          }else{
            log('CHECK - Se envia: ${event.checkType.value}');
            await CheckInUseCase().call(event.checkType);
          }*/
          checkInfo = await GetCheckInfoUseCase().call();
          emit(Loaded());
        }catch(e){
          emit(Error(e.toString()));
        } 
      },
    );


  }


  



  
}