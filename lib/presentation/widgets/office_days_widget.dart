import 'package:flutter/material.dart';
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
      children:  [
        _cardDay(size: size,child: Column(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: const [ Text('LUN'),Text(("22"))],)),
        _cardDay(size: size,child: Column(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: const [ Text('LUN'),Text(("22"))],)),
        _cardDay(size: size,child: Column(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: const [ Text('LUN'),Text(("22"))])),
        _cardDay(size: size,child: Column(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: const [ Text('MIE'),Text(("30"))],)),
        _cardDay(size: size,child: Column(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: const [ Text('LUN'),Text(("22"))],)),
        
      ],
    );
  }


  Widget _cardDay({required Size size,required Widget child}){
    return Expanded(
        child: AspectRatio(
          aspectRatio: 1,
          child: Card(
          color: Colors.amber,
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