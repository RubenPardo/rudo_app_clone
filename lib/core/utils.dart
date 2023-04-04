import 'dart:developer';

import 'package:intl/intl.dart';

class Utils{

  
  /// Return if is today, tomorrow or else nothing
  static String getTodayOrTomorrow(DateTime dateTime){

    if(dateTime.isToday()){
      return 'Hoy, ';
    }

    if(dateTime.isTomorrow()){
      return 'Mañana, ';
    }
    return '';


  }

  static String getRangeDates(DateTime start, DateTime end) {
    final f =  DateFormat('hh:mm');
    return '${f.format(start)} - ${f.format(end)}';

  }

  
}

extension DateHelpers on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return now.day == day &&
        now.month == month &&
        now.year == year;
  }

  bool isTomorrow() {
    final tomorow = DateTime.now().add(const Duration(days: 1));
    return tomorow.day == day &&
        tomorow.month == month &&
        tomorow.year == year;
  }

  String toStringHourMinute(){
    return '$hour:$minute';
  }

  /// format a date time intp a string {Vie. 31 de Mar.}
  String toStringDataNameDayMonth(){
    List months = ['Jan.','Feb.','Mar.','Apr.','May.','Jun.','Jul.','Aug.','Sep.','Oct.','Nov.','Dec.'];
    List days = ['Lun.','Mar.','Mie.','Jue.','Vie.',"Sab.","Dom."];
    return '${days[weekday-1]} ${day} de ${months[month-1]}';
  }
}