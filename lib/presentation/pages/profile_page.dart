

import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/core/utils.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/presentation/pages/faq_page.dart';
import 'package:rudo_app_clone/presentation/widgets/custom_card_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/image_profile_user_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.userData});

  final UserData userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40,),
                const Text('Perfil',style: CustomTextStyles.titleAppbar,),
                const SizedBox(height: 16,),
                _buildImage(context),
                const SizedBox(height: 16,),
                Text('${userData.firstName} ${userData.lastName}',style: CustomTextStyles.title1,),
                const SizedBox(height: 16,),
                Text(userData.rank?.name ?? '',style: CustomTextStyles.title4.copyWith(fontSize: 16),),
                const SizedBox(height: 8,),
                Column(
                  children: [
                    Text('${userData.joinDate?.getStringYearDiference()} en RUDO',style: CustomTextStyles.bodyMedium),
                    Text(userData.joinDate?.toStringSimple() ?? '',style: CustomTextStyles.bodyMedium),
                  ],
                ),
      
                const SizedBox(height: 24,),
      
                _buildProfileItem('Comunicaciones', Icons.message,
                  () {
                  
                },),
                const SizedBox(height: 8,),
                 _buildProfileItem('FAQs', Icons.info_outline,
                  () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FAQPage(),));
                },),
                const SizedBox(height: 8,),
                 _buildProfileItem('Ajustes',Icons.settings_outlined,
                  () {
                  
                },)
      
              ],
            ),
          )
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context){
    return Stack(
      children: [
        ImageProfileUserWidget(userData: userData,width: MediaQuery.of(context).size.width*0.44,isBig:true),
        Positioned(
          bottom: 0,
          right: 0,
          child: Image.network(userData.rank?.image?.thumbnail ?? '',scale: 2.1,),
        )
      ],
    );
  }

  Widget _buildProfileItem(String text, IconData icon,Function() onPressed){
    return GestureDetector(
      onTap: () => onPressed.call(),
      child: CustomCard(
        child: Row(
          children: [
            Icon(icon, size: 20,),
            const SizedBox(width: 8,),
            Text(text,style: CustomTextStyles.title3,),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,color: AppColors.unselectedIcon,size: 12,),
          ],
        )
      )
    );
  }
}