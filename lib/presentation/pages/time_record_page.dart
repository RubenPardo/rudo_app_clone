

import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/data/model/sesame/check_info.dart';
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
            const Text('Hoy, Mie. 22 de Jun', style: CustomTextStyles.title1NoBold,),
            const SizedBox(height: 16,),
            // inside a row to expand to the max width of the parent column
            Row( children: [ Expanded(
              child: CustomCard(
                child: _buildTodayWorkTime()
              )
            ),],),

            Row( children: [ Expanded(
              child: CustomCard(
                child: _buildWeekBalance()
              )
            ),],),
            Row( children: [ Expanded(
              child: CustomCard(
                child: _buildMonthBalance()
              )
            ),],),

          ],
        ),
      ),
    );
  }

  Widget _buildWeekBalance(){
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DatePaginatorWidget(
          nextCallback: (startDate, endDate){}, 
          previousCallback: (startDate, endDate){}, 
          startDateTime: DateTime.now(),
          isWeekly: true,
        ),
        const SizedBox(height: 8,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('47:00h', style: CustomTextStyles.title2),
                  const SizedBox(height: 4,),
                  ConstrainedBox(constraints: BoxConstraints(maxWidth: size.width*0.23),child: const Text('Tiempo objetivo', style: CustomTextStyles.bodySmall,textAlign: TextAlign.center,),)
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text('25:00h', style: CustomTextStyles.title2,),
                  const SizedBox(height: 4,),
                  ConstrainedBox(constraints: BoxConstraints(maxWidth: size.width*0.23), child: const Text('Tiempo trabajado', style: CustomTextStyles.bodySmall,textAlign: TextAlign.center,)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text('-24:00h', style: CustomTextStyles.title2.copyWith(color: AppColors.red)),
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

  Widget _buildMonthBalance(){
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DatePaginatorWidget(
          nextCallback: (startDate, endDate){}, 
          previousCallback: (startDate, endDate){}, 
          startDateTime: DateTime.now(),
          isMonthly: true,
        ),
        const SizedBox(height: 8,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('47:00h', style: CustomTextStyles.title2),
                  const SizedBox(height: 4,),
                  ConstrainedBox(constraints: BoxConstraints(maxWidth: size.width*0.23),child: const Text('Tiempo objetivo', style: CustomTextStyles.bodySmall,textAlign: TextAlign.center,),)
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text('25:00h', style: CustomTextStyles.title2,),
                  const SizedBox(height: 4,),
                  ConstrainedBox(constraints: BoxConstraints(maxWidth: size.width*0.23), child: const Text('Tiempo trabajado', style: CustomTextStyles.bodySmall,textAlign: TextAlign.center,)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text('-24:00h', style: CustomTextStyles.title2.copyWith(color: AppColors.red)),
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
      child: Row(
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