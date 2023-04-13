import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/core/utils.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/model/google_response_status.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/domain/use_cases/update_event_use_case.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_event.dart';
import 'package:rudo_app_clone/presentation/bloc/home/home_state.dart';
import 'package:rudo_app_clone/presentation/widgets/custom_card_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/image_profile_user_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/primary_button.dart';

import '../../app/colors.dart';
import '../../app/styles.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key,required this.event});

  final Event event;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {

  late Event _eventTmp;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _eventTmp = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: _buildAppBar(),
          backgroundColor: Colors.white,
          body: BlocConsumer<HomeBloc,HomeState>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventTitle(),
                      const SizedBox(height: 16,),
                      _buildEventDate(),
                      const SizedBox(height: 23,),
                      _buildDescription(),
                      const SizedBox(height: 24,),
                      _buildAssistanceButtons(),
                      const SizedBox(height: 24,),
                      _eventTmp.haveImage ? 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.9,
                            height: MediaQuery.of(context).size.height*0.24,
                            child: Center(child: Image.network(_eventTmp.imageUrl!,fit: BoxFit.cover,)),
                          )
                        ,const SizedBox(height: 24,)],) : const SizedBox(),
                      _buildConfirmedAttendees()
                      
                    ],
                  ),
                ),
              );
            },

            listener: (context, state) {
              if(state is EventUpdated){
                setState(() {
                  _isLoading = false;
                  _eventTmp = state.newEvent;
                });
              }
            },
          ),
        ),
        if(_isLoading) _buildLoadingWidget(),
      ],
    );
  }

  Widget _buildConfirmedAttendees(){
    return _eventTmp.confirmedAttendees.isEmpty 
    ? Text('No hay asistentes registrados, ¡apúntate!',style: CustomTextStyles.title4.copyWith(color: AppColors.greyLabel),)
    : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total asistentes: ${_eventTmp.confirmedAttendees.length}',style: CustomTextStyles.title4.copyWith(color: AppColors.greyLabel),),
        const SizedBox(height: 16,),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _eventTmp.confirmedAttendees.length,
          itemBuilder: (context, index) {
            return _buildAttender(_eventTmp.confirmedAttendees[index]);
          },
        )
      ],
    );
  }

  Widget _buildAttender(UserData user){
    return CustomCard(
      elevation: 2,
      child: Row(
        children: [
          ImageProfileUserWidget(userData: user,width:32, useDeptColor: true),
          const SizedBox(width: 12,),
          Text('${user.firstName} ${user.lastName}'),
          const Spacer(),
          Image.network(user.tech?.image?.midsize ?? '',width: 24,errorBuilder: (context, error, stackTrace) => const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(){
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.black.withAlpha(60),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildAssistanceButtons(){
    if(_eventTmp.responseStatus == ResponseStatus.accepted) {
      return _confirmedEvent();
    } else if(_eventTmp.responseStatus == ResponseStatus.declined) {
      return _declinedEvent();
    } else {
      return _needToConfirmEvent();
    }
  }

   Widget _confirmedEvent(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text('¿Vas a venir?',style: CustomTextStyles.title4,),
        const SizedBox(height: 12,),
        Row(
          children: [
            Expanded(child: PrimaryButton(onPressed: (){}, text: 'Sí')),
            const SizedBox(width: 16,),
            Expanded(child: PrimaryButton(onPressed: (){
              _updateEvent(ResponseStatus.declined);
            }, text: 'No', isMarked: false,)),
          ],
        )
      ],
    );
  }

  Widget _needToConfirmEvent(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text('¿Vas a venir?',style: CustomTextStyles.title4,),
        const SizedBox(height: 12,),
        Row(
          children: [
            Expanded(child: PrimaryButton(onPressed: (){
              _updateEvent(ResponseStatus.accepted);
            }, text: 'Sí', isMarked: false,)),
            const SizedBox(width: 16,),
            Expanded(child: PrimaryButton(onPressed: (){
              _updateEvent(ResponseStatus.declined);
            }, text: 'No', isMarked: false,)),
          ],
        )
      ],
    );
  }

  Widget _declinedEvent(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text('¿Vas a venir?',style: CustomTextStyles.title4,),
        const SizedBox(height: 12,),
        Row(
          children: [
            Expanded(child: PrimaryButton(onPressed: (){
              _updateEvent(ResponseStatus.accepted);
            }, text: 'Sí', isMarked: false,)),
            const SizedBox(width: 16,),
            Expanded(child: PrimaryButton(onPressed: (){}, text: 'No',)),
          ],
        )
      ],
    );
  }
  
  void _updateEvent(ResponseStatus status) async{
    setState(() {
      _isLoading = true;
    });
    context.read<HomeBloc>().add(UpdateEvent(event: _eventTmp, status: status));
  }

  Widget _buildDescription(){
    return _eventTmp.description.isEmpty 
    ? const Text('Este evento no tiene descripción, si tienes dudas pregúuntale a Ángel :)',style: CustomTextStyles.bodySmall,)
    : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Descripción', style: CustomTextStyles.title4.copyWith(color: AppColors.greyLabel ),),
        const SizedBox(height: 8,),
        Text(_eventTmp.description,style: CustomTextStyles.bodySmall,)

      ],

    );
  }

  Widget _buildEventTitle(){
    return Text(_eventTmp.title,style: CustomTextStyles.title1,);
  }

  Widget _buildEventDate(){
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // date
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/red_calendar.png'),
            const SizedBox(width: 9,),
            Text(_eventTmp.start.toStringDataNameDayMonthAbreviated())

          ],
        ),
        const Spacer(),
        // hour
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/red_clock.png'),
            const SizedBox(width: 9,),
            Text(Utils.getRangeDates(_eventTmp.start, _eventTmp.end),style: CustomTextStyles.bodySmall),

          ],
        ),
        const Spacer(),

      ],
    );
  }

  PreferredSizeWidget _buildAppBar(){
    return AppBar(
      title: const Text('Detalle Evento',style: CustomTextStyles.titleAppbar,),
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      leading:  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop(),),
      iconTheme: const IconThemeData(color: AppColors.fuchsia,),
    );
  }
}