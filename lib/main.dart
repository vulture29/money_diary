// Add a new route to hold the favorites.

import 'package:flutter/material.dart';
import 'package:money_diary/db/db.dart';
import 'package:money_diary/pages/dashboard_page/dashboard.dart';
import 'package:money_diary/pages/detail_page/detail.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

DatabaseHandle dbHandler;

void main() async {
  dbHandler = new DatabaseHandle();
  await dbHandler.loadDatabase();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(new MyApp());
    });
} 

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Startup Name Generator',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primaryColor: Colors.pink[100],
      ),   
      home: new MainHome(),
    );
  }
}

class MainHome extends StatefulWidget {
  @override
  MainHomeState createState() => new MainHomeState();
}

class MainHomeState extends State<MainHome> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    Dashboard(dbHandler),
    InfoPageRoute(dbHandler),
    Container(),
    Container(),
  ];

  void onTabTapped(int index) {
   setState(() {
     _currentIndex = index;
   });
 }

 @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: onTabTapped, 
        items: [
         BottomNavigationBarItem(
           icon: new Icon(Icons.home),
           title: new Text('首页'),
         ),
         BottomNavigationBarItem(
           icon: new Icon(MdiIcons.cashUsd),
           title: new Text('明细'),
         ),
         BottomNavigationBarItem(
           icon: Icon(MdiIcons.chartPie),
           title: Text('统计')
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.person),
           title: Text('我的')
         ),
       ],
     ),
    );
  }
}