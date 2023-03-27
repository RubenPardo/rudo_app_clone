import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/data/service/auth_service.dart';
import 'package:rudo_app_clone/presentation/widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    Size size =MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        height: size.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo-rudo.png', width: size.width*0.648,),
              const SizedBox(height: 80,),
              SizedBox(
                width: size.width*0.735,
                child: const Text('¡Bienvenido/a a nuestra app! 😎\n\nAccede con tu cuenta de Rudo i no te pierdas nada.',
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.body,),
              ),
              const SizedBox(height: 80,),
              // TODO se hace asi o se pone el estilo en otra pagina o otra parte como en el app.dart
              PrimaryButton(
                onPressed: (){
                  AuthService().sigInWithGoogle();
                }, 
                icon: Image.asset('assets/images/ic-google.png',height: 16,),
                text: 'Log in con Google',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

