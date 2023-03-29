import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/app/styles.dart';
import 'package:rudo_app_clone/presentation/bloc/login/login_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/login/login_event.dart';
import 'package:rudo_app_clone/presentation/bloc/login/login_state.dart';
import 'package:rudo_app_clone/presentation/pages/home_page.dart';
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
    return BlocConsumer<LoginBloc,LogInState>(
      builder: (context, state) {
        return Stack(
            children: [
              _body(size),
               (state is Loading) ? _loading(size) : const SizedBox(width: 0,),
            ],
        );
      },
      listener: (context, state) {
        if(state is Error){
            print(state.message);
          }else if(state is Loged){
            Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage(userData: state.user),));

            
          }
      },
    );
  }


  Widget _body(Size size){
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: size.height,
        width: size.width,
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
                    style: CustomTextStyles.bodyLarge,),
              ),
              const SizedBox(height: 80,),
              
              PrimaryButton(
                onPressed: () async{
                  //AuthService().loginAuth();
                  context.read<LoginBloc>().add(LogIn());
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

  ///
  /// Devuelve un container con transparencia con un circular progress
  ///
  /// @size para hacer que el expanded ocupe toda la pantalla
  ///
  Widget _loading(Size size){
    return Flex(
      direction: Axis.horizontal,
      children: [
       Expanded(
        child: Container(
          color: const Color(0x33000000),
          width: size.width,
          height: size.height,
          child: const Center(child: CircularProgressIndicator(color: AppColors.primaryColor,)),
        )
      ),
      ]
    );
  }


}

