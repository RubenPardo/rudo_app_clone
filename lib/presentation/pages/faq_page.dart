import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/presentation/pages/faq_detail_page.dart';
import 'package:rudo_app_clone/presentation/widgets/app_bar.dart';
import 'package:rudo_app_clone/presentation/widgets/custom_card_widget.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});


  static List<String> faqs = ['Contraseñas del Wifi','Cierre de oficinas','Uso Sesame']; // TODO cambiar a un objeto faq si es necesiario

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBar: AppBar(),
        title: 'FAQs',
        canPop: true,
        backgroundColor: AppColors.backgroundColorScaffold,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: faqs.length,
              itemBuilder: (context, index) 
              => _buildProfileItem(faqs[index], Icons.info_outline,
                  () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => FAQDetailsPage(faqs[index]),));
                  },
              ),
            ),
          )
        ),
      ),
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

  PreferredSizeWidget _buildAppBar(BuildContext context){
    return AppBar(
      title: const Text('FAQs',style: CustomTextStyles.titleAppbar,),
      elevation: 0,
      backgroundColor: AppColors.backgroundColorScaffold,
      centerTitle: true,
      leading:  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop(),),
      iconTheme: const IconThemeData(color: AppColors.fuchsia,),
    );
  }
}