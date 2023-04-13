import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/presentation/bloc/alerts/alert_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/alerts/alert_event.dart';
import 'package:rudo_app_clone/presentation/bloc/alerts/alert_state.dart';
import 'package:rudo_app_clone/presentation/pages/alert_page.dart';
import 'package:rudo_app_clone/presentation/pages/events_page.dart';
import 'package:rudo_app_clone/presentation/pages/home_page.dart';
import 'package:rudo_app_clone/presentation/pages/profile_page.dart';

class HomeMenuPage extends StatefulWidget {
  final UserData userData;
  const HomeMenuPage({super.key, required this.userData});

  @override
  State<HomeMenuPage> createState() => _HomeMenuPageState();
}

class _HomeMenuPageState extends State<HomeMenuPage> {

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<AlertBloc>().add(InitAlerts(fromMemory: false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: <Widget>[
        HomePage(userData: widget.userData),
        const EventsPage(),
        const AlertPage(),
        ProfilePage(userData: widget.userData),

      ][_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar(){
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: AppColors.unselectedIcon,
      showSelectedLabels: false,
      showUnselectedLabels: false,

      onTap: (newIndex) => setState(() {
        _currentIndex = newIndex;
      }),
      currentIndex: _currentIndex,
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.calendar_month),label: 'Calendar'),
        _buildBottomNotificationItem(),
        const BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Profile'),
      ],

    );
  }

  BottomNavigationBarItem _buildBottomNotificationItem(){
    return BottomNavigationBarItem( 
      label: 'Notification',
      icon: BlocConsumer<AlertBloc,AlertState>(
        builder: (context, state) {
          return Stack(
            children: <Widget>[
              const Icon(Icons.notifications),
              context.read<AlertBloc>().thereIsSomeAlertNotReaded 
              ? const Positioned(  // draw a red marble
                  top: 0.0,
                  right: 0.0,
                  child:  Icon(Icons.brightness_1, size: 8.0, 
                    color: Colors.redAccent),
                )
              : const SizedBox()
              ]
            );
        }, listener: (context, state) {
          
        },)
    );
  }

}