// Add a new route to hold the favorites.

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:money_diary/record.dart';
import 'package:money_diary/info.dart';
import 'package:money_diary/db.dart';
import 'package:money_diary/statistics.dart';
import 'package:flutter/services.dart';

DatabaseHandle dbHandler;
bool finishLoadDb = false;


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
      home: new Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  DashboardState createState() => new DashboardState();
}

class DashboardState extends State<Dashboard> {
  Map _basicInfo = {
    "total_this_month": 0,
    "total_today": 0,
  };
  Timer dbTimer;

  void loadBasicFromDb() async {
    if (dbHandler.getBasicDatabase() != null) {
      String date = DateTime.now().toString().split(" ")[0];
      List basicRecord = await dbHandler.getBasicDatabase().find({"update_date": date});
      print("Load: " + basicRecord.toString());
      
      if(basicRecord.length > 0) {
        Map basicInfo = {
          "total_this_month": basicRecord[0]["total_this_month"],
          "total_today": basicRecord[0]["total_today"],
        };
        
        setState(() {
          _basicInfo = basicInfo;
        });
        if(dbTimer.isActive) {
          dbTimer.cancel();
        }
        finishLoadDb = true;
      }
      else {
        updateBasicDb();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    print("init");
    const oneSec = const Duration(seconds: 1);
    dbTimer = new Timer.periodic(oneSec, (Timer t) {
      updateBasicDb();
      loadBasicFromDb();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Money Diary'),
        actions: <Widget>[
          new IconButton(
            icon: const Icon(Icons.add), 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecordPage(dbHandler)),
              );
            }
          ),
        ],
      ),
      body: _buildDashboard(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.info),
        backgroundColor: Colors.pink[200],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InfoPageRoute(dbHandler)),
          ).then( (var result) {
            print("back");
            print(result.toString());
          });
        },
      ),
    );
  }

  Widget _buildDashboard() {
    return new Container(
      child:RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.pink,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: 3,
          itemBuilder: (BuildContext _context, int index) {
            switch (index) {
              case 0:
                return ListTile(
                  trailing: Text(
                    "￥" + _basicInfo["total_today"].toString(),
                    style: Theme.of(context).textTheme.headline,
                  ),
                  leading: Text(
                    "今天用了",
                    style: Theme.of(context).textTheme.headline,
                  ),
                );
                break;
              case 1:
                return ListTile(
                  trailing: Text(
                    "￥" + _basicInfo["total_this_month"].toString(),
                    style: Theme.of(context).textTheme.headline,
                  ),
                  leading: Text(
                    "这个月用了",
                    style: Theme.of(context).textTheme.headline,
                  ),
                );
                break;
              default:
            }
          } 
        ),
      )
    );
  }

  Future<Null> _refresh() async {
    await updateBasicDb();
    loadBasicFromDb();
    return;
  }
}
