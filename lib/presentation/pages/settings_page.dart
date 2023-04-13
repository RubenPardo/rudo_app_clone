import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/presentation/widgets/app_bar.dart';
import 'package:rudo_app_clone/presentation/widgets/custom_card_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBar: AppBar(),
        title: 'Ajustes',
        canPop: false,
        backgroundColor: AppColors.backgroundColorScaffold,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Column(
            children: [
              _buildProfileItem('Notificaciones', 
                'Ajustes del télefono', 
                Image.asset('assets/images/notification_icon.png',height: 20,), 
                () => null,true),
              _buildProfileItem('Ubicación GPS', 
                'Ajustes del télefono', 
                Image.asset('assets/images/location_icon.png',height: 20,), 
                () => null,true),
              _buildProfileItem('Cerrar sesión',null,
                Image.asset('assets/images/person_icon.png',height: 20,), 
                () => null, false)
            ],
          )
        )
      ),
    );
  }

  Widget _buildProfileItem(String title,String? text, Image icon,Function() onPressed, bool showArrow ){
    return GestureDetector(
      onTap: () => onPressed.call(),
      child: CustomCard(
        paddingH: 12,
        paddingV: 12,
        child: Row(
          children: [
            icon,
            const SizedBox(width: 8,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w500)),
                if(text!=null)
                  const SizedBox(width: 8,),
                if(text!=null)
                  Text(text,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w500),),
                
              ],
            ),
            const Spacer(),
            showArrow
              ? const Icon(Icons.arrow_forward_ios,color: AppColors.unselectedIcon,size: 12,)
              : const SizedBox()
          ],
        )
      )
    );
  }
}