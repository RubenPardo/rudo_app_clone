import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  const CustomAppBar({super.key,
    required this.appBar,
    required this.title, 
    required this.backgroundColor, 
    required this.canPop});

  final String title;
  final Color backgroundColor;
  final AppBar appBar;
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,style: CustomTextStyles.titleAppbar,),
      elevation: 0,
      backgroundColor: backgroundColor,
      centerTitle: true,
      leading: !canPop ? null : IconButton(icon: Icon(Platform.isAndroid ? Icons.arrow_back: Icons.arrow_back_ios), onPressed: () => Navigator.of(context).pop(),),
      iconTheme: const IconThemeData(color: AppColors.fuchsia,),
    );
  }
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}