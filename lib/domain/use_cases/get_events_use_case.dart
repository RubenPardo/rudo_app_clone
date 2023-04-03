import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/service/rudo_api_service.dart';
import 'package:rudo_app_clone/domain/use_cases/auth/refresh_token_use_case.dart';

class GetUpcomingEventsUseCase{

  /// Returns all the events of an user ordered by date and after the current date
  /// 
  Future<List<Event>> call() async{
    if(await CheckValidTokenUseCase().call()){
      List<Event> events = (await RudoApiService().getGoogleCallendarEvents());
      // order by date
      events.sort((a,b){return a.start.compareTo(b.start);});
      // return only the 
      return events.where((element) => element.start.millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch).toList();
    }else{
      // TODO valorar que hacer
      return [];
    }
  }


}