import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({super.key, required this.title, required this.content, required this.cancelText, required this.confirmText, this.onConfirm});

  final String title, content, cancelText, confirmText;
  final Function()? onConfirm; 

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

                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16))
                            ),
                            child: Center(
                              child: TextButton(
                                child: Text(cancelText,style: CustomTextStyles.bodyLarge,),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          )
                        ),

                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(16))
                            ),
                            child: Center(
                              child: TextButton(
                                onPressed: (){
                                  onConfirm!.call();
                                  Navigator.of(context).pop();
                                },
                                child: Text(confirmText,style: CustomTextStyles.bodyLarge,),
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