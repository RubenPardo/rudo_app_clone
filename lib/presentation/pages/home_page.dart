import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/model/office_day.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_event.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_state.dart';
import 'package:rudo_app_clone/presentation/widgets/event_widget.dart';
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


  List<OfficeDay> _officeDays = [];
  late bool _isOfficeDaysLoading;
  List<Event> _events = []; // todo pasar a bloc
  late bool _isEventsLoading;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(InitHome());
    _isOfficeDaysLoading = true;
    _isEventsLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: BlocConsumer<HomeBloc,HomeState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40,horizontal: 16),
              child: Column(
                children: [
                  _name(),
                  const SizedBox(height: 16,),
                  _sesame(size),
                  _buildOfficeDays(size),
                  _nextEvents(),
                  /// 
                ],
              ),
            ),
          );
        },
        listener: (context, state) {
          if(state is LoadedOfficeDays){
            setState(() {
              _isOfficeDaysLoading = false;
              _officeDays = state.officeDays;
            });
          }else if(state is LoadedEvents){
            setState(() {
              _isEventsLoading = false;
              _events = state.events;
            });
          }
        },
      ),
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
    return _cardBody(
      child: SesameWidget(userData: widget.userData),
    );
  }

  /// return de card section with the content realtionated with sesame
  Widget _buildOfficeDays(Size size){
    return _cardBody(
      child: SizedBox(
        width: size.width,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estos son los días que vas a venir a la oficina:',style: CustomTextStyles.title3,),
              const SizedBox(height: 8,),
              _isOfficeDaysLoading ? const Center(child: CircularProgressIndicator(),): OfficeDaysWidget(officeDays: _officeDays),
            ],
          ),
      ),
    );
  }

  ///
  Widget _nextEvents(){
    return _cardBody(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Próximos eventos',style: CustomTextStyles.title1,),
            const SizedBox(height: 8,),
            _isEventsLoading 
              ? const SizedBox(height: 100,child: Center(child: CircularProgressIndicator(),),)
              : ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _events.length,
                itemBuilder: (context, index) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _cardBody(elevation:3,child: EventWidget(event:_events[index])),),
              ),
          ],
        ),
    );
  }

  Widget _cardBody({required Widget child, double elevation = 0}){
    return Card(
      elevation: elevation,
      color: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Container(
        decoration: const  BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child
          ),
      )
      );
  }

 }

