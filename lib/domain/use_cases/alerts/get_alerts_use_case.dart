import 'package:rudo_app_clone/data/model/alert.dart';
import 'package:rudo_app_clone/data/service/rudo_api_service.dart';
import 'package:rudo_app_clone/domain/use_cases/auth/refresh_token_use_case.dart';

class GetAlertsUseCase{


  Future<List<Alert>> call() async{
    if(await CheckValidTokenUseCase().call()){
      List<Alert> alerts = (await RudoApiService().getAlerts());
      return alerts;
    }else{
      // TODO valorar que hacer
      return [];
    }
  }

}