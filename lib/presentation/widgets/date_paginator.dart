import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/core/utils.dart';

class DatePaginatorWidget extends StatefulWidget {
  const DatePaginatorWidget({super.key, required this.callback, required this.startDateTime, this.isWeekly = false, this.isMonthly = false, this.isDaily = true});
  
  final Function(DateTime start, DateTime end) callback;
  final DateTime startDateTime;
  final bool isWeekly;
  final bool isMonthly;
  final bool isDaily;

  @override
  State<DatePaginatorWidget> createState() => _DatePaginatorWidgetState();
}

class _DatePaginatorWidgetState extends State<DatePaginatorWidget> {


  late DateTime _currentDate;

  @override
  void initState() {
    if(widget.isWeekly){
      _currentDate = widget.startDateTime.startOfTheWeek();
    }else if(widget.isMonthly){
       _currentDate = widget.startDateTime.startOfTheMonth();
    }else{
      _currentDate = widget.startDateTime;
    }

    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.isWeekly){
      return _weeklySelector();
    }else if(widget.isMonthly){
      return _monthlySelector();
    }else if(widget.isDaily){
      return _dailySelector();
    }

    return const SizedBox();
  }


  Widget _dailySelector(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
               _currentDate = _currentDate.subtract(const Duration(days: 1));        
              widget.callback(_currentDate,_currentDate);
            });
          },
          child: const Icon(Icons.arrow_back_ios, color: AppColors.fuchsia,size: 21,),
        ),
        Text(((){
          if(_currentDate.isToday()){
            return 'Hoy';
          }
          return _currentDate.toStringDataNameDayMonth();
        }()),style: CustomTextStyles.title2,),
       _currentDate.isToday() 
        ? const SizedBox() : 
        GestureDetector(
          onTap: () {
            setState(() {

              _currentDate = _currentDate.add(const Duration(days: 1));
              widget.callback(_currentDate,_currentDate);
            });
          },
          child: const Icon(Icons.arrow_forward_ios, color: AppColors.fuchsia,size: 21,)
        )
      ],
    );
  }

  Widget _weeklySelector(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
               _currentDate = _currentDate.subtract(const Duration(days: 7));        
              widget.callback(_currentDate.startOfTheWeek(),_currentDate.endOfTheWeek());
            });
          },
          child: const Icon(Icons.arrow_back_ios, color: AppColors.fuchsia,size: 21,),
        ),
        Text(((){
          if(_currentDate.isThisWeek()){
            return 'Esta semana, ${_currentDate.toStringHisWeek()}';
          }
          return _currentDate.toStringHisWeek();
        }()),style: CustomTextStyles.title2,),
       _currentDate.isThisWeek() 
        ? const SizedBox() : 
        GestureDetector(
          onTap: () {
            setState(() {

              _currentDate = _currentDate.add(const Duration(days: 7));
              widget.callback(_currentDate.startOfTheWeek(),_currentDate.endOfTheWeek());
            });
          },
          child: const Icon(Icons.arrow_forward_ios, color: AppColors.fuchsia,size: 21,)
        )
      ],
    );
  }

  Widget _monthlySelector(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              // back
              _currentDate = _currentDate.startOfThePreviousMonth();     
              widget.callback(_currentDate.startOfTheMonth(),_currentDate.endOfTheMonth());
            });
          },
          child: const Icon(Icons.arrow_back_ios, color: AppColors.fuchsia,size: 21,),
        ),
        Text(((){
          if(_currentDate.isThisMonth()){
            return 'Este mes, ${_currentDate.toStringHisMonth()}';
          }
          return _currentDate.toStringHisMonth();
        }()),style: CustomTextStyles.title2,),
       _currentDate.isThisMonth() 
        ? const SizedBox() : 
        GestureDetector(
          onTap: () {
            setState(() {
              // add
              _currentDate = _currentDate.startOfTheNextMonth();
              widget.callback(_currentDate.startOfTheMonth(),_currentDate.endOfTheMonth());
            });
          },
          child: const Icon(Icons.arrow_forward_ios, color: AppColors.fuchsia,size: 21,)
        )
      ],
    );
  }

}