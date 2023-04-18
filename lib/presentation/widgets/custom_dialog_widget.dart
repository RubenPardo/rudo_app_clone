import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({super.key, required this.title, required this.content, required this.cancelText, required this.confirmText, this.onConfirm, 
  this.oneButtonOnly = false});

  final String title, content, cancelText, confirmText;
  final Function()? onConfirm; 
  final bool oneButtonOnly;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          content: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)
              ),
              
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(padding: const EdgeInsets.only(top: 16,bottom: 8),child: Text(title,style: CustomTextStyles.title2.copyWith(fontWeight: FontWeight.bold),),),
                  const Divider(),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 32,vertical: 16),child: Text(content,style: CustomTextStyles.bodyLarge,textAlign: TextAlign.center,),),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [

                        // ----------------- cancel button
                        oneButtonOnly ? const SizedBox() 
                        : Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 48,
                              decoration:const  BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16),),
                              ),
                              child: Center(
                                child:Text(cancelText,style: CustomTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold,),),
                              ),
                            ),
                          ),
                        ),
                        // --------------- confrim button
                         Expanded(
                          child: GestureDetector(
                            onTap: () {
                              onConfirm?.call();
                                    Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.only(bottomRight: const Radius.circular(16),bottomLeft: Radius.circular(oneButtonOnly ? 16 : 0)),
                              ),
                              child: Center(
                                child: Text(confirmText,style: CustomTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),),
                              ),
                            ),
                          )
                        ),

                        
                    ],
                  ),
                  
                ],
              )

              
            ),
        );
  }
}