import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/presentation/bloc/login/login_bloc.dart';
import 'package:rudo_app_clone/presentation/pages/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginBloc(),)
      ],
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backgroundColorScaffold,
          useMaterial3: true,
          colorSchemeSeed: AppColors.primaryColor,
        ),
        home: const LoginPage(),
      ),
    );
  }
}