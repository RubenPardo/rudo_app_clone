import 'dart:developer';

import 'package:intl/intl.dart';

class Utils{

  /// format a date time intp a string {Vie. 31 de Mar.}
  static String formatData(DateTime dateTime){
    List months = ['Jan.','Feb.','Mar.','Apr.','May.','Jun.','Jul.','Aug.','Sep.','Oct.','Nov.','Dec.'];
    List days = ['Lun.','Mar.','Mie.','Jue.','Vie.',"Sab.","Dom."];
    return '${days[dateTime.weekday-1]} ${dateTime.day} de ${months[dateTime.month-1]}';
  }

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
}