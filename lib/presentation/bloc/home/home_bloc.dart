import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/model/office_day.dart';
import 'package:rudo_app_clone/domain/use_cases/get_events_use_case.dart';
import 'package:rudo_app_clone/domain/use_cases/get_office_days_use_case.dart';
import 'package:rudo_app_clone/domain/use_cases/update_event_use_case.dart';
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
            _events = await GetUpcomingEventsUseCase().call();
            emit(LoadedContent(officeDays: _officeDays, events: _events));

            isAllLoaded = true;
            

          }catch(e){
            log("ERROR: $e");
            emit(Error("Error inseperado al obtner la información")); // ----- return error
          }
        }else{
          emit(LoadedContent(officeDays: _officeDays, events: _events));
          isAllLoaded = true;
        }
        
        
      },
    );

    on<UpdateEvent>( //----------------------------------
      (event, emit) async{
        try{
          Event oldEvent = event.event;
          Event newEvent = await UpdateEventUseCase().call(event.status,oldEvent);

          int oldIndex = _events.indexOf(oldEvent);
          _events.remove(oldEvent);
          _events.insert(oldIndex, newEvent);
          emit(EventUpdated(newEvent: newEvent));
          emit(LoadedContent(events: _events,officeDays: _officeDays));
        }catch(e){
          log("ERROR: $e");
          emit(Error("Error inseperado al actualizar el evento")); // ----- return error
          emit(LoadedContent(officeDays: _officeDays, events: _events));
        }
      },
    );


  }


  



  
}