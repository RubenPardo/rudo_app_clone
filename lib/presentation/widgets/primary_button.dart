import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,required this.onPressed,
    required this.text, 
    this.icon, 
    this.color = AppColors.primaryColor,
    this.isMarked = true
  });

  final void Function() onPressed;
  final String text;
  final Widget? icon;
  final Color color;
  final bool isMarked;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton( 
      
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isMarked ? Colors.transparent : color),
        minimumSize: const Size.fromHeight(50),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isMarked ? color : AppColors.buttonNoMarked,
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
    );
  }
}