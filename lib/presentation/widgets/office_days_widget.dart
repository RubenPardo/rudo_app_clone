import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/data/model/location.dart';
import 'package:rudo_app_clone/data/model/office_day.dart';
  /// TODO revisar de como hacerlo mejor
class OfficeDaysWidget extends StatelessWidget {
  final List<OfficeDay> officeDays;
  const OfficeDaysWidget({super.key, required this.officeDays});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children:  officeDays.map(
        (officeDay) {
          var splitDay = officeDay.label.split('.');
          return _cardDay(
            location: officeDay.location,
            size: size,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [ 
                Text(splitDay[0].toUpperCase()),
                Text(splitDay[1],style: CustomTextStyles.title3,),
              ],
            )
          );
        }).toList()
    );
  }


  Widget _cardDay({required Size size,required Widget child, required Location location}){
    return Expanded(
        child: AspectRatio(
          aspectRatio: 1,
          child: Card(
            shape: location == Location.atHome 
              ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.primaryColor,width: 2)
              ) : null,
            color: location == Location.atWork ? AppColors.primaryColor : AppColors.buttonNoMarked,
            elevation: 0,
            child: Container(
              padding:const EdgeInsets.all(8),
              child:child,
            )
        ),
      ),
    );
  }
}