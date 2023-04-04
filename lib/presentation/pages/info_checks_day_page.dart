import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/core/utils.dart';
import 'package:rudo_app_clone/data/model/sesame/check.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';
import 'package:rudo_app_clone/data/model/sesame/check_type.dart';
import 'package:rudo_app_clone/presentation/widgets/custom_card_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/date_paginator.dart';

class InfoCheckDayPage extends StatefulWidget {
  const InfoCheckDayPage({super.key, required this.info});

  final CheckInfo info; // TODO este info debe pillarse del bloc del sesame, para cuando entres se actualice la hora?

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
                    child: _buildChecks()
                  )
                ),],),
              ],
            ),
          ),
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
              text: '${widget.info.totalTimeWorked.toString().split(':')[0]}:${widget.info.totalTimeWorked.toString().split(':')[1]}h',
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