import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';

class ImageProfileUserWidget extends StatelessWidget {
  const ImageProfileUserWidget({
    super.key,
    required this.userData,
  });

  final UserData userData;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xff7c94b6),
          image: DecorationImage(
            image: NetworkImage(userData.image!.thumbnail!),
            fit: BoxFit.cover,
          ),
          borderRadius: const BorderRadius.all( Radius.circular(50.0)),
          border: Border.all(
            color: userData.isSesameOk! ? AppColors.red: AppColors.green,
            width: 2.0,
          ),
        ),
      );
  }
}