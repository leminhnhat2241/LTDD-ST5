import 'package:flutter/material.dart';
import 'package:leminhnhat_2198/AlarmClockScreen.dart';
import 'package:leminhnhat_2198/InformationScreen.dart';
import 'package:leminhnhat_2198/StopwatchScreen.dart';
import 'package:leminhnhat_2198/TemperatureConverterScreen.dart';
import 'package:leminhnhat_2198/TranslateScreen.dart';
import 'package:leminhnhat_2198/UnitConverterScreen.dart';
import 'package:leminhnhat_2198/YouTubePlayerScreen.dart';
import 'package:leminhnhat_2198/GroupInfoScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    TemperatureConverterScreen(), //giao diện chuyển đổi nhiệt độ
    UnitConverterScreen(), // giao diện chuyển đổi đơn vị
    YouTubePlayerScreen(), //giao diện youtube
    AlarmClockScreen(), // giao diện đồng hồ báo thức
    StopwatchScreen(), //giao diện đồng hồ bấm giờ
    TranslateScreen(), //giao diện dịch thuật
    GroupInfoScreen(), //giao diện thông tin nhóm
    InformationScreen(), //giao diện thông tin cá nhân
  ];

  void _onItemTapped(int index) {
    // hàm chuyển đổi giữa các tab
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ứng dụng đa năng',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.thermostat_outlined, size: 20),
              activeIcon: Icon(Icons.thermostat, size: 20),
              label: 'Nhiệt độ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz_outlined, size: 20),
              activeIcon: Icon(Icons.swap_horiz, size: 20),
              label: 'Đơn vị',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library_outlined, size: 20),
              activeIcon: Icon(Icons.video_library, size: 20),
              label: 'YouTube',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.alarm_outlined, size: 20),
              activeIcon: Icon(Icons.alarm, size: 20),
              label: 'Báo thức',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined, size: 20),
              activeIcon: Icon(Icons.timer, size: 20),
              label: 'Bấm giờ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.translate_outlined, size: 20),
              activeIcon: Icon(Icons.translate, size: 20),
              label: 'Dịch',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined, size: 20),
              activeIcon: Icon(Icons.groups, size: 20),
              label: 'Nhóm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined, size: 20),
              activeIcon: Icon(Icons.person, size: 20),
              label: 'Cá nhân',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue.shade700,
          unselectedItemColor: Colors.grey.shade600,
          selectedFontSize: 9,
          unselectedFontSize: 8,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          iconSize: 20,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
