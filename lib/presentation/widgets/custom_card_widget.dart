import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({super.key,required this.child, this.elevation = 0, this.borderColor});

  final Widget child;
  final double elevation;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
  
    return Card(
      elevation: elevation,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side:  borderColor !=null ? BorderSide(color: borderColor!,width: 2): BorderSide.none,
        borderRadius: const BorderRadius.all(Radius.circular(12))),
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