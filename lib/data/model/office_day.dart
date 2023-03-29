import 'package:rudo_app_clone/data/model/location.dart';

class OfficeDay {
  int id;
  String label;
  String fullDate;
  Location location;

  OfficeDay({required this.id,required this.label,required this.fullDate,required this.location});

  factory OfficeDay.fromJson(Map<String, dynamic> json) {
   return OfficeDay(
      id: json['id'] as int,
      label: json['label'],
      fullDate: json['full_date'],
      location: Location.getLocation(json['location'])
   );
  }

  factory OfficeDay.dummy(String label, Location location){
    return OfficeDay(id: 1, label: label, fullDate: "fullDate", location: location);
  }


}

