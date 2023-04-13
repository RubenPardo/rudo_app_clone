import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/core/utils.dart';
import 'package:rudo_app_clone/data/model/sesame/check.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';
import 'package:rudo_app_clone/data/model/sesame/check_type.dart';
import 'package:rudo_app_clone/data/model/sesame/day_status.dart';
import 'package:rudo_app_clone/data/service/rudo_api_service.dart';
import 'package:rudo_app_clone/presentation/widgets/app_bar.dart';
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

  late CheckInfo _info;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _info = widget.info;
  }


  void updateCheckInfo(DateTime day)async{
    setState((){
      isLoading = true;
    });
    _info = await RudoApiService().getCheckInfo(day);
    
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBar: AppBar(),
        title: 'Detalle día',
        canPop: true,
        backgroundColor: AppColors.backgroundColorScaffold,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
      
            // dat selector
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 33),
              child: DatePaginatorWidget(
                  callback: (startDate, endDate){
                    // if is Daily start and end date are the same
                    updateCheckInfo(startDate);
                  }, 
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
                      child: _buildTodayWorkTime(_info)
                    )
                  ),],),
                  const SizedBox(height: 16,),
      
                  
      
                  Row( children: [ Expanded(
                    child: CustomCard(
                      child: !isLoading 
                        ? _info.checks.isEmpty ? _buildEmptyChecks(_info.dayStatus) : _buildChecks(_info)
                        : const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(),),)
                    )
                  ),],),
                ],
              ),
            ),
          ],
        ),
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
  Widget _buildChecks(CheckInfo info){
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: info.checks.length,
      itemBuilder: (context, index) {
        String text = '';
        
        Check currentCheck = info.checks[index];
        if(index == info.checks.length-1){
          text = '${currentCheck.date!.toStringHourMinute()} - ';
        }else{
          text = '${currentCheck.date!.toStringHourMinute()} - ${(info.checks[index+1].date!).toStringHourMinute()}';
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

  Widget _buildTodayWorkTime(CheckInfo info){
    return  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Text.rich(
            TextSpan(
              style: CustomTextStyles.title1,
              text: (info.lastCheck.date !=null && info.lastCheck.date!.isToday()) 
                ? '${widget.workingTime}h' 
                : '${info.totalTimeWorked.split(":")[0]}:${info.totalTimeWorked.split(":")[1]}h',
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