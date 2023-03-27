import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,required this.onPressed,required this.text, this.icon, this.color = AppColors.primaryColor
  });

  final void Function() onPressed;
  final String text;
  final Widget? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: 50,
      child: ElevatedButton( 
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: color,
          textStyle: CustomTextStyles.primaryButton
        ),
        onPressed: onPressed, 
        child:  Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon ?? const SizedBox(),
              SizedBox(width: icon!=null ? 14 : 0,),
              Text(text,style: CustomTextStyles.primaryButton,)
            ],
          ),
      )
    );
  }
}