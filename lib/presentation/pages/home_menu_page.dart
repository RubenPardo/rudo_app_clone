import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:rudo_app_clone/data/model/user/user_data.dart';
import 'package:rudo_app_clone/presentation/pages/home_page.dart';

class HomeMenuPage extends StatefulWidget {
  final UserData userData;
  const HomeMenuPage({super.key, required this.userData});

  @override
  State<HomeMenuPage> createState() => _HomeMenuPageState();
}

class _HomeMenuPageState extends State<HomeMenuPage> {

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: <Widget>[
        HomePage(userData: widget.userData),
        Center(child: Text('Calendar'),),
        Center(child: Text('Notifiacions'),),

      ][_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar(){
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (newIndex) => setState(() {
        _currentIndex = newIndex;
      }),
      currentIndex: _currentIndex,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month),label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications),label: 'Notification'),
      ],

    );
  }

}