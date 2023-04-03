import 'dart:developer';

import 'package:avatar_stack/positions.dart';
import 'package:flutter/material.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/core/utils.dart';
import 'package:rudo_app_clone/data/model/event.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/presentation/widgets/image_profile_user_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/primary_button.dart';

class EventWidget extends StatefulWidget {
  const EventWidget({super.key, required this.event});

  final Event event; // TODO cambiar a por la info del evento

  @override
  State<EventWidget> createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleDay(),
        const SizedBox(height: 12,),
        _titleEvent(),
        const SizedBox(height: 12,),
        _assistEvent()
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
                child: Text(Utils.formatData(widget.event.start),style: CustomTextStyles.bodySmall),//Text('Jue. 2 de Jun.',style: CustomTextStyles.bodyMedium,)
              )
            ]
          )
        ),
         widget.event.totalAttendees == "0" 
              ? const SizedBox()
              : SizedBox(
                height: 25,
                width: 40.0 + (5)* (widget.event.confirmedAttendees.length >= 4 ? 4 :widget.event.confirmedAttendees.length),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.event.totalAttendees,),
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
              ) /*Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.event.totalAttendees,style: CustomTextStyles.bodySmall),
                  const SizedBox(width: 4,),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: widget.event.confirmedAttendees.length > 4 ? 62 : widget.event.confirmedAttendees.length*25,
                        minWidth: 10,
                        maxHeight: 25
                      ),
                      // TODO como quitar el padding de la derecha
                      child: Stack(
                        children:[
                          for(int i = 0; (i<widget.event.confirmedAttendees.length && i<4); i++)
                            Positioned(
                              right: i*10,
                              child: SizedBox(
                                width: 25,
                                height: 25,
                                child: ImageProfileUserWidget(userData:widget.event.confirmedAttendees[i]),
                              )
                            )
                          
                        ],
                      ),
                    ),
                  )
                ],
              ),
        */
      ],
    );
  }

  Widget _titleEvent(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.event.summary,style: CustomTextStyles.bodySmall),
        widget.event.hasTime 
          ? Text(Utils.getRangeDates(widget.event.start, widget.event.end),style: CustomTextStyles.bodySmall)
          : const SizedBox(),
      ],
    );
  }

  Widget _assistEvent(){
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
            Expanded(child: PrimaryButton(onPressed: (){}, text: 'No', isMarked: false,)),
          ],
        )
      ],
    );
  }
}