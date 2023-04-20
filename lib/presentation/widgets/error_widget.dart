
import 'package:flutter/widgets.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/presentation/widgets/primary_button.dart';

class ContentErrorWidget extends StatelessWidget {
  const ContentErrorWidget({super.key, required this.callback});
  final Function() callback;

  @override
  Widget build(BuildContext context) {
    double aspectRatio = MediaQuery.of(context).devicePixelRatio;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 55),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: const EdgeInsets.only(left: 50),child: 
              Image.asset('assets/images/error.png', cacheHeight: (aspectRatio*120).round(),),
            
            ),
            const SizedBox(height: 40,),
            const Text('Algo no funciona',style: CustomTextStyles.titleAppbar,),
            const SizedBox(height: 12,),
            const Text('Estamos trabajando para solucionar el problema. Revisa tu conexión a internet y prueba otra vez.',style: CustomTextStyles.bodySmall,textAlign: TextAlign.center,),
            const SizedBox(height: 24,),
            PrimaryButton(onPressed: (){
              callback.call();
            }, text: 'VOLVER A INTENTAR')
      
          ]
        ),
      ),
    );
  }
}