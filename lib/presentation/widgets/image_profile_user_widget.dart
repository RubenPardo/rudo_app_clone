

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';

class ImageProfileUserWidget extends StatelessWidget {
  const ImageProfileUserWidget({
    super.key,
    required this.userData,  this.width = 46, this.useDeptColor = false,
  });

  final UserData userData;
  final double width;
  final bool useDeptColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: width,
        decoration: BoxDecoration(
          color: const Color(0xff7c94b6),
          image: DecorationImage(
            image: NetworkImage(userData.image != null ?  userData.image!.thumbnail ??  "" : ""),
            fit: BoxFit.fill,
          ),
          borderRadius: const BorderRadius.all( Radius.circular(50.0)),
          border: Border.all(
            color: getBorderColor(),
            width: 2.0,
          ),
        ),
      );
  }

  Color getBorderColor(){
    if(useDeptColor){
      // circle color by department
      switch(userData.tech?.name){
        case 'IOS':
          return AppColors.iosColor;
        case 'Android':
          return AppColors.androidColor;
        case 'Ionic':
          return AppColors.ionicColor;
        case 'Flutter':
          return AppColors.flutterColor;
        default:
          return Colors.transparent;
      }
    }else{
      // circle color by sesame status
      return userData.isSesameOk!=null ? userData.isSesameOk! ? AppColors.green: AppColors.red : AppColors.primaryColor;
    }
  }
}