import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
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
    String d1 = '${f.format(start)}h';
    String d2 = '${f.format(end)}h';
    if(d1 == d2){
      return d1;
    }else{
      return '$d1 - $d2';
    }

  }

  static void showSnakError(String s, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s))
    );
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

  bool isThisMonth() {
    var end = DateTime.now().endOfTheMonth();
    var start = DateTime.now().startOfTheMonth();
    return (isBefore(end) || compareTo(end) == 0) && (isAfter(start) || compareTo(start) == 0);
  }

  bool isThisWeek() {
    var end = DateTime.now().endOfTheWeek();
    var start = DateTime.now().startOfTheWeek();
    return (isBefore(end) || compareTo(end) == 0) && (isAfter(start) || compareTo(start) == 0);
  }

  String toStringHourMinute(){
    return DateFormat('HH:mm').format(this);
  }

  /// format a date time intp a string {Vie. 31 de Mar.}
  String toStringDataNameDayMonth(){
    List months = ['Jan.','Feb.','Mar.','Apr.','May.','Jun.','Jul.','Aug.','Sep.','Oct.','Nov.','Dec.'];
    List days = ['Lun.','Mar.','Mie.','Jue.','Vie.',"Sab.","Dom."];
    return '${days[weekday-1]} $day de ${months[month-1]}';
  }

  String toStringDataNameDayMonthAbreviated(){
    List months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    List days = ['Lun','Mar','Mie','Jue','Vie',"Sab","Dom"];
    return '${days[weekday-1]}, $day ${months[month-1]}';
  }

  // return a string like 'DD-DD Jun 2022'
  String toStringHisWeek(){
    List months = ['Jan.','Feb.','Mar.','Apr.','May.','Jun.','Jul.','Aug.','Sep.','Oct.','Nov.','Dec.'];
    return '${startOfTheWeek().day} - ${endOfTheWeek().day} ${months[month-1]} $year';
  }

  // return a string like 'DD-DD Jun 2022'
  String toStringHisMonth(){
    List months = ['Jan.','Feb.','Mar.','Apr.','May.','Jun.','Jul.','Aug.','Sep.','Oct.','Nov.','Dec.'];
    return '${months[month-1]} $year';
  }


  DateTime startOfTheWeek(){
    DateTime temp = subtract(Duration(days: weekday - 1));
    return DateTime(temp.year, temp.month, temp.day);
  }
  
  DateTime endOfTheWeek(){
    DateTime temp = add(Duration(days: 7 - weekday));
   
    return  DateTime(temp.year, temp.month, temp.day);
  }

  DateTime startOfTheMonth(){
    return DateTime(year, month, 1);
  }

  DateTime startOfThePreviousMonth(){
    return DateTime(year, month, 0);
  }
  
  
  DateTime endOfTheMonth(){
    return DateTime(year, month+1, 0);
  }
   DateTime startOfTheNextMonth(){
    return DateTime(year, month+1, 1);
  }
}


extension DurationExtension on Duration{
  String toStringHoursMinutes() {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    return "${twoDigits(inHours)}:$twoDigitMinutes";
  }
}