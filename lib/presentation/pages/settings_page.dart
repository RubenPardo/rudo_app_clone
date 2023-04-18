import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/core/storage_keys.dart';
import 'package:rudo_app_clone/data/service/storage_service.dart';
import 'package:rudo_app_clone/presentation/bloc/login/login_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/login/login_event.dart';
import 'package:rudo_app_clone/presentation/bloc/login/login_state.dart';
import 'package:rudo_app_clone/presentation/pages/login_page.dart';
import 'package:rudo_app_clone/presentation/widgets/app_bar.dart';
import 'package:rudo_app_clone/presentation/widgets/custom_card_widget.dart';
import 'package:rudo_app_clone/presentation/widgets/custom_dialog_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  
  bool gpsEnabled = false;
  bool notifcationsEnabled = true;

  @override
  void initState(){
    super.initState();
    getStorageValues();
  }
  
  void getStorageValues() async{
    bool val = (await StorageService().readSecureData(StorageKeys.notificationsSetting) ?? 'false').toLowerCase() == 'true';
    setState((){
      notifcationsEnabled = val;
 
    });  
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc,LogInState>(
      builder: (context,state) {
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
                  _buildNotificationsItem(),
                  _buildLocationItem(),
                  _buildSignOutItem(),
                ],
              )
            )
          ),
        );
      },
      listener: (context, state) {
        if(state is LogedOut){
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage(),), (route) => false);
        }
      },
    );
  }

  Widget _buildSignOutItem(){
    return GestureDetector(
      onTap: () {
        showDialog(context: context, builder: (context) {
           return CustomDialog(
            title: '¡Aviso!', 
           content: '¿Estás seguro que quieres cerrar sesión?', 
           cancelText: 'Cancelar', 
           confirmText: 'Cerrar sesión',
           onConfirm: () {
             context.read<LoginBloc>().add(LogOut());
           });
        });
        
      },
      child: CustomCard(
        paddingH: 12,
        paddingV: 22,
        child: Row(
          children: [
            Image.asset('assets/images/person_icon.png',height: 20,), 
            const SizedBox(width: 16,),
            const Text('Cerrar sesión',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500)),
          ]
        )
      ),
    );
  }

  Widget _buildNotificationsItem(){
    return CustomCard(
      paddingH: 12,
      paddingV: 12,
      child: Row(
        children: [
          Image.asset('assets/images/notification_icon.png',height: 20,), 
          const SizedBox(width: 16,),
          const Text('Notificaciones',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500)),
          const Spacer(),
          Switch(value: notifcationsEnabled, onChanged: (value) {
                  setState(() {
                    notifcationsEnabled = !notifcationsEnabled;
                  });
                  StorageService().writeSecureData(StorageKeys.notificationsSetting,notifcationsEnabled.toString());
                  
                }, activeColor: AppColors.green,)
        ],
      )
    );
  }

  Widget _buildLocationItem(){
    return GestureDetector(
      onTap: () {
        showDialog(context: context, builder:(context) {
          return CustomDialog(
            title: '¡Aviso!', 
            content: 'Recuerda que si deshabilitas tu ubicación GPS no podrás hacer checks desde la app.', 
            cancelText: 'Cancelar', 
            confirmText: 'Continuar',
            onConfirm: () {
              AppSettings.openLocationSettings();
            },);
        },);
      },
      child: CustomCard(
        paddingH: 12,
        paddingV: 16,
        child: Row(
          children: [
            Image.asset('assets/images/location_icon.png',height: 20,), 
            const SizedBox(width: 16,),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Ubicación GPS',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500)),
                Text('Ajustes del teléfono',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500)),

              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: AppColors.unselectedIcon,)
          ],
        )
      ),
    );
  }


}