import 'dart:developer';

import 'package:avatar_stack/positions.dart';
import 'package:flutter/material.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/core/utils.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/model/google_response_status.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/domain/use_cases/update_event_use_case.dart';
import 'package:rudo_app_clone/presentation/widgets/image_profile_user_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/primary_button.dart';

class EventWidget extends StatefulWidget {
  const EventWidget({super.key, required this.event});

  final Event event;

  @override
  State<EventWidget> createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {

  late Event _eventTmp;

  @override
  void initState() {
    super.initState();
    _eventTmp = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //_titleDay(),
        //const SizedBox(height: 12,),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            Flexible(flex: 5,child: _titleEvent(),),
            Flexible(flex: 2,child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildConfirmedAttendees(),
                const SizedBox(width: 8,),
                _buildIfAssist()
              ],
            )),
          ] 
        ),
       // const SizedBox(height: 12,),

        /*if(_eventTmp.responseStatus == ResponseStatus.accepted)
          _confirmedEvent(),
        if(_eventTmp.responseStatus == ResponseStatus.declined)
          _declinedEvent(),
        if(_eventTmp.responseStatus == ResponseStatus.needsAction)
          _needToConfirmEvent()*/
      ],
    );
  }

  /// build the day of the event and the participants
  Widget _titleDay(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:  [
         Text.rich(
          TextSpan(
            text: Utils.getTodayOrTomorrow(_eventTmp.start),
            style: CustomTextStyles.title4,
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Text(_eventTmp.start.toStringDataNameDayMonth(),style: CustomTextStyles.bodySmall),//Text('Jue. 2 de Jun.',style: CustomTextStyles.bodyMedium,)
              )
            ]
          )
        ),
         
      ],
    );
  }
  /// build a stack of the image photos of the assistants, if theres is no assistants return empty box
  Widget _buildConfirmedAttendees(){
    return _eventTmp.confirmedAttendees.isEmpty 
        ? const SizedBox()
        : SizedBox(
          height: 25,
          width: 40.0 + (5)* (_eventTmp.confirmedAttendees.length >= 4 ? 4 : _eventTmp.confirmedAttendees.length),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_eventTmp.confirmedAttendees.length.toString(),),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _eventTmp.confirmedAttendees.length > 4 ? 4 :_eventTmp.confirmedAttendees.length ,
                  itemBuilder: (context, index) {
                    
                    return Align(
                      widthFactor: 0.3,
                      child: SizedBox(width: 25,child: ImageProfileUserWidget(userData:_eventTmp.confirmedAttendees[index])),
                    );
                  },
                ),
              )
            ],
          ),
        );
  }

  /// return an image asset depends if the user assist or not to the event
  Widget _buildIfAssist(){
    
      return  SizedBox(
        width: 20,
        child: Image.asset((){
          if(_eventTmp.responseStatus == ResponseStatus.accepted) {
            return 'assets/images/green_check.png';
          } else if(_eventTmp.responseStatus == ResponseStatus.declined){
            return 'assets/images/red_cross.png';
          }else {
            return 'assets/images/yellow_interrogant.png';
          }
        }(),),
      );
   
  }

  Widget _titleEvent(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(Utils.getRangeDates(_eventTmp.start, _eventTmp.end),style: CustomTextStyles.bodySmall),
        Text(_eventTmp.title,
            style: CustomTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,),
    
      ],
    );
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
              log('declined');
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
    try{
      Event e = await UpdateEventUseCase().call(status,_eventTmp);
      log(e.responseStatus.toString());
      setState(() {
        _eventTmp = e;
      });
    }catch(e){
      Utils.showSnakError('No se pudo actualizar el evento', context);
    }
  }
}