import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/core/utils.dart';
import 'package:rudo_app_clone/data/model/sesame/check.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';
import 'package:rudo_app_clone/data/model/sesame/check_type.dart';
import 'package:rudo_app_clone/data/model/sesame/day_status.dart';
import 'package:rudo_app_clone/presentation/widgets/custom_card_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/date_paginator.dart';

class InfoCheckDayPage extends StatefulWidget {
  const InfoCheckDayPage({super.key, required this.info, required this.workingTime});

  final CheckInfo info;
  final String workingTime;
  @override
  State<InfoCheckDayPage> createState() => _InfoCheckDayPageState();
}

class _InfoCheckDayPageState extends State<InfoCheckDayPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [


          // dat selector
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 33),
            child: DatePaginatorWidget(
                nextCallback: (startDate, endDate){}, 
                previousCallback: (startDate, endDate){}, 
                startDateTime: DateTime.now(),
                
              )
          ),


         
          
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [

                const SizedBox(height: 16,),

                // hours worked today
                Row( children: [ Expanded(
                  child: CustomCard(
                    child: _buildTodayWorkTime()
                  )
                ),],),
                const SizedBox(height: 16,),

                

                Row( children: [ Expanded(
                  child: CustomCard(
                    child: widget.info.checks.isEmpty ? _buildEmptyChecks(widget.info.dayStatus) : _buildChecks()
                  )
                ),],),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChecks(DayStatus dayStatus){
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 20,child: Image.asset(dayStatus.asset,),),
          const SizedBox(width: 4,),
          Text(dayStatus.value)
        ],
      ),
    );
  }

  /// build a list with the diferents checks of the user
  Widget _buildChecks(){
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.info.checks.length,
      itemBuilder: (context, index) {
        String text = '';
        
        Check currentCheck = widget.info.checks[index];
        if(index == widget.info.checks.length-1){
          text = '${currentCheck.date!.toStringHourMinute()} - ';
        }else{
          text = '${currentCheck.date!.toStringHourMinute()} - ${(widget.info.checks[index+1].date!).toStringHourMinute()}';
        }
        return _buildCheckItem(currentCheck, text);
      },
    );
  }

  Widget _buildCheckItem(Check check, String timeRange){

    Icon _icon;
    switch(check.status){
      
      case CheckType.checkIn:
        _icon = const Icon(Icons.arrow_forward, color: AppColors.green,);
        break;
      case CheckType.checkout:
        _icon = const Icon(Icons.arrow_back, color: AppColors.red,);
        break;
      case CheckType.pause:
        _icon = const Icon(Icons.pause, color: AppColors.primaryColor,);
        break;
      case CheckType.noFound:
        _icon = const Icon(Icons.crop_square_sharp,);
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _icon,
          const SizedBox(width: 16,),
          Text(timeRange)
        ],
      ),
    );
  }


  PreferredSizeWidget _buildAppBar(){
    return AppBar(
      title: const Text('Detalle día',style: CustomTextStyles.title2,),
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.backgroundColorScaffold,
      iconTheme: const IconThemeData(color: AppColors.fuchsia),
    );
  }

  Widget _buildTodayWorkTime(){
    return  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Text.rich(
            TextSpan(
              style: CustomTextStyles.title1,
              text: '${widget.workingTime}h',
              children: const [
                TextSpan(
                  text: ' tiempo trabajado',style: CustomTextStyles.bodyMedium)
              ]
            )
          ),
          const Spacer(),
        ],
      
    );
  }

}