import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/model/google_response_status.dart';
import 'package:rudo_app_clone/data/service/rudo_api_service.dart';

class UpdateEventUseCase{


  Future<Event> call(ResponseStatus status, Event event){
    return RudoApiService().updateEventStatus(event, status);
  }


}