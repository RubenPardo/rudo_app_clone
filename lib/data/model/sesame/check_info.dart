
import 'package:rudo_app_clone/data/model/sesame/check.dart';
import 'package:rudo_app_clone/data/model/sesame/check_type.dart';


class CheckInfo{
  final List<Check> checks;
  final Check lastCheck;
  final String totalTimeWorked;
  final String status; // if is festivity or working

  CheckInfo({required this.checks,required this.lastCheck, required this.totalTimeWorked, required this.status});

  factory CheckInfo.fromJson(Map<String, dynamic> json){

    return CheckInfo(
      checks: (json['checks'] as List).map<Check>((raw) => Check.fromJson(raw)).toList(), 
      lastCheck: Check.fromJson(json['last_check']), 
      totalTimeWorked: json['total_time_worked'], 
      status: json['status']
    );

  }

  factory CheckInfo.dummyEmpty(){
    return CheckInfo.fromJson({"checks":[],"last_check":{"created":null,"modified":null,"last_check_time":null,"status":"out"},"total_time_worked":"0:00:00","status":"working"});
  }

  factory CheckInfo.dummyCheckIn(){
    return CheckInfo.fromJson({
        "checks": [
            {
                "created": "2023-04-04 08:40:22",
                "modified": "2023-04-04 08:40:22",
                "last_check_time": null,
                "status": "in"
            },
        ],
        "last_check": {
            "created": "2023-04-04 08:40:22",
            "modified": "2023-04-04 08:40:22",
            "last_check_time": "8:40:22",
            "status": "in"
        },
        "total_time_worked": "0:01:54",
        "status": "working"
    });
  }

  factory CheckInfo.dummyPause(){
    return CheckInfo.fromJson({
        "checks": [
            {
                "created": "2023-04-04 08:00:00",
                "modified": "2023-04-04 08:00:00",
                "last_check_time": null,
                "status": "in"
            },

            {
                "created": "2023-04-04 08:47:00",
                "modified": "2023-04-04 08:47:00",
                "last_check_time": null,
                "status": "pause"
            },
        ],
        "last_check": {
                "created": "2023-04-04 08:47:00",
                "modified": "2023-04-04 08:47:00",
                "last_check_time": null,
                "status": "pause"
            },
        "total_time_worked": "00:47:00",
        "status": "working"
    });
  }



  /// get a duration that start from the work/pause time passed
  /// if the status is checkIn return a duration starts from the time of [totalTimeWorked]
  /// if the status is pause return a duration which starts from the difference of his date time created and the date time now
  Duration getDurationLastCheck(){
    if(lastCheck.status == CheckType.checkIn){
      var timeSplited = totalTimeWorked.split(":").map((e) => int.parse(e)).toList(); // --> [hh,mm,ss]
      return Duration(hours: timeSplited[0],minutes: timeSplited[1], seconds: timeSplited[2]);
    }

    if(lastCheck.status == CheckType.pause){
        int milisecondsDiference = DateTime.now().millisecondsSinceEpoch - lastCheck.date!.millisecondsSinceEpoch;
        return Duration(milliseconds: milisecondsDiference);
    }
     return Duration();
  }
  
  CheckType getLastStatus(){
    return lastCheck.status;
  }

  @override
  String toString() {
    return 'Checks: ${checks.toString()}, lastCheck: $lastCheck, totalTimeWorked: $totalTimeWorked, status: $status ]';
  }
}

