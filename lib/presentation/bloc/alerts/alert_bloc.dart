

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/data/model/alert.dart';
import 'package:rudo_app_clone/domain/use_cases/alerts/get_alerts_use_case.dart';
import 'package:rudo_app_clone/presentation/bloc/alerts/alert_event.dart';
import 'package:rudo_app_clone/presentation/bloc/alerts/alert_state.dart';

class AlertBloc extends Bloc<AlertEvent,AlertState>{
  
  late List<Alert> _alerts = [];
  bool isAllLoaded = false;

  bool get thereIsSomeAlertNotReaded {
    return _alerts.firstWhereOrNull((element) => !element.isReaded,) != null;
  } 
  
  AlertBloc() : super (InitState()){

    on<InitAlerts>((event, emit) async {
      try{
        if(!event.fromMemory){
          emit(Loading());
          _alerts = await GetAlertsUseCase().call();
          emit(Loaded(alerts: _alerts));
          isAllLoaded = true;
        }else{
          emit(Loading());
          emit(Loaded(alerts: _alerts));
        }
      }catch(e){
        emit(Error(message: 'Error al iniciar las alertas'));
      }
    },);

  }


  



  
}