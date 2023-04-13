import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/core/utils.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_bloc.dart';
import 'package:collection/collection.dart';
import 'package:rudo_app_clone/presentation/pages/event_details_page.dart';
import 'package:rudo_app_clone/presentation/widgets/custom_card_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/error_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/event_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/primary_button.dart';

import '../bloc/home/home_event.dart';
import '../bloc/home/home_state.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {


   @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc,HomeState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 48,),
              const Center(child: Text('Eventos',style: CustomTextStyles.titleAppbar,),),
              Flexible(
                child: RefreshIndicator(
                  onRefresh: () {
                    context.read<HomeBloc>().add(InitHome(fromMemory: false));
                    return Future(() => null);
                  },
                  child: state is LoadedContent  
                    ?  state.events.isEmpty ?_emptyEvents() :_buildEventList(state.events)
                    : state is Loading 
                      ? const Center(child: CircularProgressIndicator(),) 
                      : ContentErrorWidget(callback:(){context.read<HomeBloc>().add(InitHome(fromMemory: false));}),
                    
                ),
              ),
            ],
          );
        },
        listener: (context, state) {
        },
    );
  }
  // build a list events separated by date
  Widget _buildEventList(List<Event> events) {

     List<List<Event>> eventsGroupByDate = events.groupListsBy((element) => element.start).values.toList();

     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 8),
       child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: eventsGroupByDate.length,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16,),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8),child: Text(eventsGroupByDate[index][0].start.toStringDataNameDayMonth(),style: CustomTextStyles.title2.copyWith(fontSize: 20),)),
              const SizedBox(height: 12,),
              ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: eventsGroupByDate[index].length,
                itemBuilder: (context, indexEvent) {
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => EventDetailPage(event: eventsGroupByDate[index][indexEvent],),)),
                    child: CustomCard(child: EventWidget(event: eventsGroupByDate[index][indexEvent])),
                  );
                },
              )
            ],
          );
        },
         ),
     );
  }

  Widget _emptyEvents(){
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text('Por el momento parece que no hay eventos...'),
                const SizedBox(height: 20,),
                Image.asset('assets/images/empty_alerts.png',height: 84,)
            ]),
          )
      ],
    );
  }

  Widget _buildErrorEvents(){
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 55),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: const EdgeInsets.only(left: 50),child: Image.asset('assets/images/error.png',),),
            const SizedBox(height: 40,),
            const Text('Algo no funciona',style: CustomTextStyles.titleAppbar,),
            const SizedBox(height: 12,),
            const Text('Estamos trabajando para solucionar el problema. Revisa tu conexión a internet y prueba otra vez.',style: CustomTextStyles.bodySmall,textAlign: TextAlign.center,),
            const SizedBox(height: 24,),
            PrimaryButton(onPressed: (){
              context.read<HomeBloc>().add(InitHome(fromMemory: false));
            }, text: 'VOLVER A INTENTAR')
      
          ]
        ),
      ),
    );
  }



}