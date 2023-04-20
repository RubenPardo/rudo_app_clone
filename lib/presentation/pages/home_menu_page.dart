import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rudo_app_clone/app/colors.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/presentation/bloc/alerts/alert_bloc.dart';
import 'package:rudo_app_clone/presentation/bloc/alerts/alert_event.dart';
import 'package:rudo_app_clone/presentation/bloc/alerts/alert_state.dart';
import 'package:rudo_app_clone/presentation/pages/alert_page.dart';
import 'package:rudo_app_clone/presentation/pages/events_page.dart';
import 'package:rudo_app_clone/presentation/pages/gallery_page.dart';
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
        const GalleryPage(),
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
        BottomNavigationBarItem(icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(_currentIndex == 1 ?Icons.calendar_month : Icons.calendar_month_outlined),label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(_currentIndex == 2 ? Icons.photo_library : Icons.photo_library_outlined),label: 'Gallery'),
        _buildBottomNotificationItem(),
        BottomNavigationBarItem(icon: Icon(_currentIndex == 4 ? Icons.person : Icons.person_outline),label: 'Profile'),
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
              Icon(_currentIndex == 3 ? Icons.notifications : Icons.notifications_none_outlined),
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