
import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/presentation/widgets/custom_card_widget.dart';

class FAQDetailsPage extends StatelessWidget {
  const FAQDetailsPage(this.faq, {super.key});

  final String faq;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(faq,style: CustomTextStyles.title1.copyWith(fontSize: 20),),
              const SizedBox(height: 24,),
              Text('Título',style: CustomTextStyles.title4.copyWith(color: AppColors.greyLabel),),
              const SizedBox(height: 8,),
              const Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam bibendum, lorem vel varius semper, ante ante congue nulla, id consequat purus sapien quis urna. Fusce et velit nec orci viverra elementum. Ut sollicitudin vestibulum rhoncus.\n\nDonec congue felis nec ultricies egestas. Nunc a ex sem. Integer feugiat nisi erat, scelerisque tempus sapien condimentum in. Fusce placerat vel odio vel sagittis. Nullam condimentum ultrices congue. Ut pulvinar viverra lacus ut congue.',),
              
            ],
          )
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context){
    return AppBar(
      title: const Text('Detalle FAQ',style: CustomTextStyles.titleAppbar,),
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      leading:  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop(),),
      iconTheme: const IconThemeData(color: AppColors.fuchsia,),
    );
  }
}