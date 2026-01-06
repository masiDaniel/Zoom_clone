import 'package:flutter/material.dart';
import 'package:zoom_clone/resources/auth_methods.dart';
import 'package:zoom_clone/screens/hitstory_meeting_screen.dart';
import 'package:zoom_clone/screens/meetings_screen.dart';
import 'package:zoom_clone/utils/colors.dart';
import 'package:zoom_clone/widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  List<Widget> pages = [
    MeetingsScreen(),
    HitstoryMeetingScreen(),
    const Text("contacts"),
    CustomButton(text: "Log out", onPressed: () => AuthMethods().signOut()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meet and chat"),
        centerTitle: true,
        backgroundColor: backgroundColor,
      ),
      body: pages[_page],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: footerColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: onPageChanged,
        currentIndex: _page,
        type: BottomNavigationBarType.fixed,
        unselectedFontSize: 14,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.comment_bank),
            label: "Meet & Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_clock),
            label: "Meetings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Contacts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_sharp),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
