import 'package:rudo_app_clone/data/model/office_day.dart';
import 'package:rudo_app_clone/data/service/rudo_api_service.dart';
import 'package:rudo_app_clone/domain/use_cases/auth/refresh_token_use_case.dart';

class GetOfficeDaysUseCase{
  

  Future<List<OfficeDay>> call() async{
    if(await CheckValidTokenUseCase().call()){
      return RudoApiService().getOfficeDays();
    }else{
      // TODO valorar que hacer en mitad de la app cuando el token no es valido y no se pudo actualizar
      return [];
    }
  }
}