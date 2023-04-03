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
    return  SizedBox(
      height: 65,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: officeDays.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          var splitDay = officeDays[index].label.split('.');
          return _cardDay(
            location: officeDays[index].location,
            size: size,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [ 
                Text(splitDay[0].toUpperCase()),
                Text(splitDay[1],style: CustomTextStyles.title4,),
              ],
            )
          );
        }
      ),
    );
  }


  Widget _cardDay({required Size size,required Widget child, required Location location}){
    return  AspectRatio(
      aspectRatio: 1,
      child: Card(
        shape: location == Location.atHome 
          ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.primaryColor,width: 2)
          ) : null,
        color: location == Location.atWork ? AppColors.primaryColor : AppColors.buttonNoMarked,
        elevation: 0,
        child: Padding(
          padding:const EdgeInsets.all(8),
          child:child,
        ) 
      ),
    );
  }
}