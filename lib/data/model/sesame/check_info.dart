
import 'dart:developer';

import 'package:rudo_app_clone/data/model/sesame/check.dart';


class CheckInfo{
  final List<Check> checks;
  final Check lastCheck;
  final String totalTimeWorked;
  final String status;

  CheckInfo({required this.checks,required this.lastCheck, required this.totalTimeWorked, required this.status});

  factory CheckInfo.fromJson(Map<String, dynamic> json){

    return CheckInfo(
      checks: (json['checks'] as List).map<Check>((raw) => Check.fromJson(raw)).toList(), 
      lastCheck: Check.fromJson(json['last_check']), 
      totalTimeWorked: json['total_time_worked'], 
      status: json['status']
    );

  }

  @override
  String toString() {
    // TODO: implement toString
    return 'Checks: ${checks.toString()}, lastCheck: $lastCheck, totalTimeWorked: $totalTimeWorked, status: $status ]';
  }
}

