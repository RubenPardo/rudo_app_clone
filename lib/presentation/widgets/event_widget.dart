import 'package:avatar_stack/positions.dart';
import 'package:flutter/material.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/presentation/widgets/image_profile_user_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/primary_button.dart';

class EventWidget extends StatefulWidget {
  const EventWidget({super.key, required this.userData});

  final UserData userData; // TODO cambiar a por la info del evento

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
        const Text.rich(
          TextSpan(
            text: 'Hoy, ',
            style: CustomTextStyles.title3,
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Text('Jue. 2 de Jun.',style: CustomTextStyles.bodyMedium,)
              )
            ]
          )
        ),
         Row(
            children: [
              const Text('4',style: CustomTextStyles.bodyMedium),
              const SizedBox(width: 4,),
              SizedBox(
                height: 25,
                width: 55,
                child: WidgetStack(
                  positions: RestrictedPositions(
                    maxCoverage: 0.6,
                    minCoverage: 0.1,
                    laying: StackLaying.first
                  ),
                  stackedWidgets: [
                    for (var n = 0; n < 4; n++)
                      ImageProfileUserWidget(userData:widget.userData),
                  ],
                  buildInfoWidget: (surplus) {
                    return const SizedBox();
                  },
                ),
              )
            ],
          ),
        
      ],
    );
  }

  Widget _titleEvent(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Cañas en equipo: Android',style: CustomTextStyles.bodyMedium),
        Text('17:15 - 19:45',style: CustomTextStyles.bodyMedium),
      ],
    );
  }

  Widget _assistEvent(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text('¿Vas a venir?',style: CustomTextStyles.title3,),
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