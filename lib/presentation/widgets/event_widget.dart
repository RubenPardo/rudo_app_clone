import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/core/utils.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/model/google_response_status.dart';
import 'package:rudo_app_clone/presentation/widgets/image_profile_user_widget.dart';

class EventWidget extends StatefulWidget {
  const EventWidget({super.key, required this.event});

  final Event event;

  @override
  State<EventWidget> createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {

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
        )
        
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
            text: Utils.getTodayOrTomorrow(widget.event.start),
            style: CustomTextStyles.title4,
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Text(widget.event.start.toStringDataNameDayMonthAbv(),style: CustomTextStyles.bodySmall),//Text('Jue. 2 de Jun.',style: CustomTextStyles.bodyMedium,)
              )
            ]
          )
        ),
         
      ],
    );
  }
  /// build a stack of the image photos of the assistants, if theres is no assistants return empty box
  Widget _buildConfirmedAttendees(){
    return widget.event.confirmedAttendees.isEmpty 
        ? const SizedBox()
        : SizedBox(
          height: 25,
          width: 40.0 + (5)* (widget.event.confirmedAttendees.length >= 4 ? 4 : widget.event.confirmedAttendees.length),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.event.confirmedAttendees.length.toString(),),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.event.confirmedAttendees.length > 4 ? 4 :widget.event.confirmedAttendees.length ,
                  itemBuilder: (context, index) {
                    
                    return Align(
                      widthFactor: 0.3,
                      child: SizedBox(width: 25,child: ImageProfileUserWidget(userData:widget.event.confirmedAttendees[index])),
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
          if(widget.event.responseStatus == ResponseStatus.accepted) {
            return 'assets/images/green_check.png';
          } else if(widget.event.responseStatus == ResponseStatus.declined){
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

        Text(Utils.getRangeDates(widget.event.start, widget.event.end),style: CustomTextStyles.bodySmall),
        Text(widget.event.title,
            style: CustomTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,),
    
      ],
    );
  }

 
}