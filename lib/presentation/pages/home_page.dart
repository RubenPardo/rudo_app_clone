import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/data/model/office_day.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_event.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_state.dart';
import 'package:rudo_app_clone/presentation/bloc/sesame/sesame_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/sesame/sesame_event.dart';
import 'package:rudo_app_clone/presentation/widgets/custom_card_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/image_profile_user_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/office_days_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/sesame_widget.dart';

class HomePage extends StatefulWidget {
  final UserData userData;
  const HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late bool _isOfficeDaysLoading;


  @override
  void initState() {
    super.initState();
    if(!context.read<HomeBloc>().isAllLoaded){
      context.read<HomeBloc>().add(InitHome(fromMemory: false));
      _isOfficeDaysLoading = true;
    }else{
      context.read<HomeBloc>().add(InitHome(fromMemory:true));
      _isOfficeDaysLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<HomeBloc,HomeState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () {
              setState(() {
                _isOfficeDaysLoading = true;
              });
              context.read<HomeBloc>().add(InitHome(fromMemory: false));
              context.read<SesameBloc>().add(InitSesame(fromMemory: false));
              return Future(() => null);
            },
            child: CustomScrollView(
              slivers: [
                SliverList( // to make a growable content and expand to the bottom
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40,horizontal: 16),
                        child: Column(
                          children: [
                            _name(),
                            const SizedBox(height: 16,),
                            _sesame(size),
                            _buildOfficeDays(size,state is LoadedContent ? state.officeDays : null),
                            _highlightedEvents(),
                            /// 
                          ],
                        ),
                      ),
                    ]
                  ),
                )
                
              ]
              
            ),
          );
        },
        listener: (context, state) {
          if(state is LoadedContent){
            setState(() {
              _isOfficeDaysLoading = false;
            });
          }
        },
    );
  }

  Widget _name(){
    return Row(
      children: [
        ImageProfileUserWidget(userData:widget.userData),
        const SizedBox(width: 15,),
        Text("¡Hola ${widget.userData.firstName!}!",style: CustomTextStyles.title1,)
      ],
    );
  }

  /// return de card section with the content realtionated with sesame
  Widget _sesame(Size size){
    return CustomCard(
      child: SesameWidget(userData: widget.userData),
    );
  }

  /// return de card section with the content realtionated with sesame
  Widget _buildOfficeDays(Size size, List<OfficeDay>?officeDays){
    return CustomCard(
      child: SizedBox(
        width: size.width,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estos son los días que vas a venir a la oficina:',style: CustomTextStyles.title3,),
              const SizedBox(height: 8,),
              _isOfficeDaysLoading ? const Center(child: CircularProgressIndicator(),): OfficeDaysWidget(officeDays: officeDays!),
            ],
          ),
      ),
    );
  }

  ///
  Widget _highlightedEvents(){
    return CustomCard(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Eventos destacados',style: CustomTextStyles.title1,),
            const SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.only(top:16,bottom: 20),
              child: Center(
                  child: Image.asset(
                    'assets/images/empty_events.png',
                    width: 150,
                  ),
                ),
            ),
            const Center(child: Text('El party manager está trabajando en ello ;)',style: CustomTextStyles.bodyMedium,),)
          ],
        ),
    );
  }



 }

