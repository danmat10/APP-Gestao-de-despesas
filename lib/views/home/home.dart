import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_8/models/user_model.dart';
import 'package:flutter_application_8/views/auth/login_screen.dart';
import 'package:flutter_application_8/views/expense/create_screen.dart';
import 'package:flutter_application_8/views/expense/graph_screen.dart';
import 'package:flutter_application_8/views/expense/view_screen.dart';

class HomePage extends StatefulWidget {
  final UserModel user;

  HomePage({required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  List<Widget> _pageOptions() => [
        ViewExpensePage(user: widget.user),
        CreateExpensePage(user: widget.user),
        GraphPage(user: widget.user),
      ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pageOptions = _pageOptions();

    return Scaffold(
      body: pageOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Adicionar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Resumo',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 3) {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }
          });
        },
      ),
    );
  }
}
