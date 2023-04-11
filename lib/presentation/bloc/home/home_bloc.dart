import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/model/office_day.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/domain/use_cases/get_events_use_case.dart';
import 'package:rudo_app_clone/domain/use_cases/get_office_days_use_case.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_event.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent,HomeState>{
  
  bool isAllLoaded = false;
  late List<OfficeDay> _officeDays;
  late List<Event> _events;
  
  HomeBloc() : super (InitState()){
    
  
    on<InitHome>( //----------------------------------
      (event, emit) async{
       if(!event.fromMemory){
          emit(Loading());
          log('INIT HOME');
          
          try{
            
            _officeDays = await GetOfficeDaysUseCase().call();
            emit(LoadedOfficeDays(officeDays: _officeDays));


            _events = await GetUpcomingEventsUseCase().call();
            emit(LoadedEvents(events:_events));

            isAllLoaded = true;
            

          }catch(e){
            log("ERROR: $e");
            emit(Error("Error inseperado al obtner la información")); // ----- return error
          }
        }else{
          emit(LoadedOfficeDays(officeDays:_officeDays));
          emit(LoadedEvents(events:_events));
          isAllLoaded = true;
        }
        
        
      },
    );


  }


  



  
}