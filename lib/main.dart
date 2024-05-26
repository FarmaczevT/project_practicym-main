import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'user/submit_application_page.dart';
import 'ViewApplication.dart';
import 'authorization.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppStart(),
    );
  }
}

class AppStart extends StatefulWidget {
  @override
  _AppStartState createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {
  bool _isLoggedIn = false;
  String token = '';
  int userId = 0;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/user_data.json');

    if (await file.exists()) {
      final String jsonData = await file.readAsString();
      final Map<String, dynamic> userData = jsonDecode(jsonData);

      if (userData["user_id"] != null) {
        setState(() {
          _isLoggedIn = true;
          token = userData["token"];
          userId = userData["user_id"];
        });
      }
    } else {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn
        ? MainScreen(token: token, userId: userId, logout: _logout)
        : LoginPage();
  }
}

class MainScreen extends StatefulWidget {
  final String token;
  final int userId;
  final VoidCallback logout;

  MainScreen({required this.token, required this.userId, required this.logout});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: <Widget>[
          ApplicationsPage(
              token: widget.token, userId: widget.userId, logout: widget.logout),
          SubmitApplicationPage(
              token: widget.token, userId: widget.userId, logout: widget.logout),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Мои заявки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Отправить заявку',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
