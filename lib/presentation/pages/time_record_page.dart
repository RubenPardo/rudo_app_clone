

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/core/utils.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';
import 'package:rudo_app_clone/data/model/sesame/day_status.dart';
import 'package:rudo_app_clone/data/model/sesame/hour_balance.dart';
import 'package:rudo_app_clone/data/service/rudo_api_service.dart';
import 'package:rudo_app_clone/presentation/pages/info_checks_day_page.dart';
import 'package:rudo_app_clone/presentation/widgets/custom_card_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/date_paginator.dart';

class TimeRecordPage extends StatefulWidget {
  const TimeRecordPage({super.key, required this.checkInfo, required this.workingTime});

  final CheckInfo checkInfo;
  final String workingTime;

  @override
  State<TimeRecordPage> createState() => _TimeRecordPageState();
}

class _TimeRecordPageState extends State<TimeRecordPage> {

  HourBalance? monthHourBalance;
  bool isMonthLoading = true;

  HourBalance? weekHourBalance;
  bool isWeekLoading = true;
  

  void updateMonthBalance(DateTime startDate, DateTime endDate)async{
    setState((){
      isMonthLoading = true;
    });
    monthHourBalance = await RudoApiService().getHourBalanceFromTo(startDate, endDate);
    
    setState(() {
      isMonthLoading = false;
    });
  }

  void updateWeekBalance(DateTime startDate, DateTime endDate)async{
    setState((){
      isWeekLoading = true;
    });
    weekHourBalance = await RudoApiService().getHourBalanceFromTo(startDate, endDate);
    
    setState(() {
      isWeekLoading = false;
    });
  }

  @override
  void initState() {
    updateMonthBalance(DateTime.now().startOfTheMonth(), DateTime.now().endOfTheMonth());
    updateWeekBalance(DateTime.now().startOfTheWeek(), DateTime.now().endOfTheWeek());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            
            Text('Hoy, ${DateTime.now().toStringDataNameDayMonth()}', style: CustomTextStyles.title1NoBold,),
            const SizedBox(height: 16,),
            // inside a row to expand to the max width of the parent column
            Row( children: [ Expanded(
              child: CustomCard(
                child: _buildTodayWorkTime()
              )
            ),],),

            Row(
              children: [
                Expanded(child: CustomCard(child: 
                  _buildHourBalance(
                    DatePaginatorWidget(
                      callback: (startDate, endDate)async {
  
                        updateMonthBalance(startDate,endDate);

                      }, 
                     
                      startDateTime: DateTime.now(),
                      isMonthly: true,
                    ),
                    monthHourBalance,
                    isMonthLoading
                  ),
                ))
              ],
            ),

            Row(
              children: [
                Expanded(child: CustomCard(child: 
                  _buildHourBalance(
                    DatePaginatorWidget(
                      callback: (startDate, endDate)async {
  
                        updateWeekBalance(startDate,endDate);

                      }, 
                     
                      startDateTime: DateTime.now(),
                      isWeekly: true,
                    ),
                    weekHourBalance,
                    isWeekLoading
                  ),
                ))
              ],
            )

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

  Widget _buildHourBalance(DatePaginatorWidget datePaginator, HourBalance? hourBalance, bool isLoading){
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        datePaginator,
        const SizedBox(height: 8,),
        isLoading 
          ? const Padding(padding: EdgeInsets.all(16), child:  Center(child: CircularProgressIndicator(),),)
          : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(hourBalance!.theoric, style: CustomTextStyles.title2),
                  const SizedBox(height: 4,),
                  ConstrainedBox(constraints: BoxConstraints(maxWidth: size.width*0.23),child: const Text('Tiempo objetivo', style: CustomTextStyles.bodySmall,textAlign: TextAlign.center,),)
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(hourBalance.worked, style: CustomTextStyles.title2,),
                  const SizedBox(height: 4,),
                  ConstrainedBox(constraints: BoxConstraints(maxWidth: size.width*0.23), child: const Text('Tiempo trabajado', style: CustomTextStyles.bodySmall,textAlign: TextAlign.center,)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(hourBalance.balance, style: CustomTextStyles.title2.copyWith(color: hourBalance.balance.contains("-") ? AppColors.red : AppColors.green)),
                  const SizedBox(height: 4,),
                  ConstrainedBox(constraints: BoxConstraints(maxWidth: size.width*0.23), child: const Text('Balance', style: CustomTextStyles.bodySmall)),
                ],
              ),
            )
          ],
        )
        
      ],
    );
  }

  Widget _buildTodayWorkTime(){
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => InfoCheckDayPage(info: widget.checkInfo, workingTime:widget.workingTime),));
      },
      child: widget.checkInfo.checks.isEmpty 
        ? _buildEmptyChecks(widget.checkInfo.dayStatus)
        : Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const Icon(Icons.arrow_forward_ios, color: AppColors.fuchsia,size: 21,)
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(){
    return AppBar(
      title: const Text('Registro horario',style: CustomTextStyles.title2,),
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.backgroundColorScaffold,
      iconTheme: const IconThemeData(color: AppColors.fuchsia),
    );
  }

}