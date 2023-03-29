import 'package:flutter/material.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/data/model/office_day.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/presentation/widgets/event_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/image_profile_user_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/office_days_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/primary_button.dart';

class HomePage extends StatefulWidget {
  final UserData userData;
  const HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40,horizontal: 16),
          child: Column(
            children: [
              _name(),
              const SizedBox(height: 16,),
              _sesame(),
              _officeDays(),
              _nextEvents(),
              /// 
            ],
          ),
        ),
      ),
    );
  }

  Widget _name(){
    return Row(
      children: [
        ImageProfileUserWidget(userData:widget.userData),
        const SizedBox(width: 15,),
        Text("¡Hola ${widget.userData.firstName!}!",style: CustomTextStyles.title1,)
      ],
    );
  }

  /// return de card section with the content realtionated with sesame
  Widget _sesame(){
    return _cardBody(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Introduce la contraseña para empezar',style: CustomTextStyles.title2,),
            const SizedBox(height: 8,),
            PrimaryButton(onPressed: (){}, text: 'Vincular Sesame')
          ],
        ),
    );
  }

  /// return de card section with the content realtionated with sesame
  Widget _officeDays(){
    return _cardBody(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estos son los días que vas a venir a la oficina:',style: CustomTextStyles.title2,),
            const SizedBox(height: 8,),
            OfficeDaysWidget(officeDays:[OfficeDay('LUN'),OfficeDay('MAR')]),
          ],
        ),
    );
  }

  ///
  Widget _nextEvents(){
    return _cardBody(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Próximos eventos',style: CustomTextStyles.title1,),
            const SizedBox(height: 8,),
             ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (context, index) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _cardBody(elevation:2,child:  EventWidget(userData:widget.userData)),),
              ),
          ],
        ),
    );
  }


  
  Widget _cardBody({required Widget child, double elevation = 0}){
    return Card(
      elevation: elevation,
      color: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child
        )
      );
  }

}

