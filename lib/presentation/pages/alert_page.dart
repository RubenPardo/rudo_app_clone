

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/core/utils.dart';
import 'package:rudo_app_clone/data/model/alert.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/presentation/bloc/alerts/alert_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/alerts/alert_event.dart';
import 'package:rudo_app_clone/presentation/bloc/alerts/alert_state.dart';
import 'package:rudo_app_clone/presentation/widgets/custom_card_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/error_widget.dart';

import '../../app/styles.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {

  @override
  void initState() {
    super.initState();
    if(!context.read<AlertBloc>().isAllLoaded){
      context.read<AlertBloc>().add(InitAlerts(fromMemory: false));
    }else{
      context.read<AlertBloc>().add(InitAlerts(fromMemory:true));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<AlertBloc,AlertState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 48,),
                const Center(child: Text('Avisos',style: CustomTextStyles.titleAppbar,),),
                const SizedBox(height: 16,),
                Flexible(
                  child: RefreshIndicator(
                    onRefresh: () {
                      context.read<AlertBloc>().add(InitAlerts(fromMemory: false));
                      return Future(() => null);
                    },
                    child: state is Loaded  
                      ?  state.alerts.isEmpty ?_emptyAlerts() :_buildAlertList(state.alerts)
                      : state is Loading 
                        ? const Center(child: CircularProgressIndicator(),) 
                        : ContentErrorWidget(callback:(){context.read<AlertBloc>().add(InitAlerts(fromMemory: false));}),
                      
                  ),
                ),
              ],
            ),
          );
        },
        listener: (context, state) {
        },
    );
  }

  Widget _buildAlertList(List<Alert> alerts){
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        return CustomCard(
          borderColor: alerts[index].isReaded ? null : AppColors.primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(alerts[index].isReaded ? Icons.notifications_none: Icons.notifications,size: 24,),
                  const SizedBox(width: 12,), 
                  Text(alerts[index].title,style: CustomTextStyles.title3.copyWith(fontWeight: FontWeight.w600),)
               ],
              ),
              const SizedBox(height: 8,),
              Text('${alerts[index].date.toStringDataNameDayMonthAbreviated()} ${alerts[index].date.toStringHourMinute()}h',style: CustomTextStyles.bodySmall.copyWith(fontSize: 13),),
              const SizedBox(height: 8,),
              Text(alerts[index].description,style: CustomTextStyles.bodySmall.copyWith(fontSize: 14)),
            ],
          )
        );
      },
    );
  }


  Widget _emptyAlerts(){
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text('Por el momento parece que no hay avisos...',textAlign: TextAlign.center,),
                const SizedBox(height: 20,),
                Image.asset('assets/images/empty_alerts.png',height: 84,)
            ]),
          )
      ],
    );
  }

  Widget _buildErrorAlert(){
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text('Parece que ha ocurrido error, vuelve a intentarlo más tarde.',textAlign: TextAlign.center,),
                const SizedBox(height: 20,),
                Image.asset('assets/images/empty_alerts.png',height: 84,)
            ]),
          )
      ],
    );
  }


}