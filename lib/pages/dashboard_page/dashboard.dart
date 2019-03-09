import 'package:flutter/material.dart';
import 'dart:async';
import 'package:money_diary/pages/insert_record_page/record.dart';
import 'package:money_diary/db/db.dart';
import 'package:money_diary/statistics/statistics.dart';

class Dashboard extends StatefulWidget {
  final DatabaseHandle dbHandler;

  Dashboard(this.dbHandler);

  @override
  DashboardState createState() => new DashboardState(dbHandler);
}

class DashboardState extends State<Dashboard> {
  Map _basicInfo = {
    "total_this_month": 0,
    "total_today": 0,
  };
  Timer dbTimer;
  List _todayRecordInfo = [];

  final DatabaseHandle dbHandler;

  DashboardState(this.dbHandler);

  Future<bool> needUpdateBasicDb() async{
    if (dbHandler.getBasicDatabase() != null) {
      String date = DateTime.now().toString().split(" ")[0];
      List basicRecord = await dbHandler.getBasicDatabase().find({"update_date": date});
      if(basicRecord.length > 0) {
        return false;
      }
    }
    return true;
  }

  void loadBasicFromDb() async {
    if (dbHandler.getBasicDatabase() != null) {
      String date = DateTime.now().toString().split(" ")[0];
      List basicRecord = await dbHandler.getBasicDatabase().find({"update_date": date});
      
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
      }
      else {
        updateBasicDb();
      }
    }
  }

  void loadTodayRecordFromDb() async {
    List todayRecordInfo = await getTodayRecordList();
    if (todayRecordInfo != null) {   
      setState(() {
        _todayRecordInfo = todayRecordInfo;
      });      
    }
  }

  @override
  void initState() {
    super.initState();
    const oneSec = const Duration(milliseconds: 5);
    if (dbTimer != null && dbTimer.isActive) {
      dbTimer.cancel();
    }
    dbTimer = new Timer.periodic(oneSec, (Timer t) async{
      if (await needUpdateBasicDb()) {
        await updateBasicDb();
      }
      loadBasicFromDb();
      loadTodayRecordFromDb();
    });
  }

  @override
  void dispose() {
    if (dbTimer != null && dbTimer.isActive) {
      dbTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Money Diary'),
        elevation: 0,
        actions: <Widget>[
          new IconButton(
            icon: const Icon(Icons.add), 
            onPressed: () {
              Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => RecordPage(dbHandler)),
              ).then( 
                (String result) async {
                  await updateBasicDb();
                  loadBasicFromDb();
                  loadTodayRecordFromDb();
                }
              );
            }
          ),
        ],
      ),
      body: _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    Widget dashBoardSection = Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Container(
        decoration: BoxDecoration(
          // color: Color.fromARGB(0xFF, 0xF4, 0xE4, 0xEC),
          color: Colors.pink[100],
          borderRadius: BorderRadius.all(Radius.circular(16))
        ),
        height: 120,
        child: Column(
          children: <Widget>[
            ListTile(
              trailing: Text(
                "￥" + _basicInfo["total_today"].toString(),
                style: Theme.of(context).textTheme.headline,
              ),
              leading: Text(
                "今天用了",
                style: Theme.of(context).textTheme.headline,
              ),
            ),
            ListTile(
              trailing: Text(
                "￥" + _basicInfo["total_this_month"].toString(),
                style: Theme.of(context).textTheme.headline,
              ),
              leading: Text(
                "这个月用了",
                style: Theme.of(context).textTheme.headline,
              ),
            )
          ],
        )
      )
    );

    var emptyText = Text("今天还没有用钱哦");
    
    var todayDetailSection = new Container(
      padding: const EdgeInsets.all(8),
      child: new Container(
        alignment: Alignment.center,
        height: 460,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.all(Radius.circular(16))
        ),
        child: _todayRecordInfo.length == 0 ? emptyText : ListView.builder(
          physics: ScrollPhysics(),
          itemCount: _todayRecordInfo.length > 0 ? _todayRecordInfo.length * 2 - 1 : 0,
          itemBuilder: (BuildContext context, int i) {
            if (i.isOdd) {
              return const Divider();
              }
              var index = _todayRecordInfo.length - i ~/ 2 - 1;
              Key myKey = new Key(_todayRecordInfo[index]["_id"]);
              return new TodayInfoRecord(myKey, _todayRecordInfo[index]);
            }
        )
      ),
    );

    var dashBoardContext = ListView.builder(
      // padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      itemCount: 2,
      itemBuilder: (BuildContext _context, int index) {
        switch (index) {
          case 0:
            return dashBoardSection;
          case 1:
            return todayDetailSection;
          default:
        }
      }
    );

    return new Container(
      child:RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.pink,
        child: dashBoardContext
      )
    );
  }

  Future<Null> _refresh() async {
    await updateBasicDb();
    loadBasicFromDb();
    loadTodayRecordFromDb();
    return;
  }
}

class TodayInfoRecord extends StatefulWidget {
  final Map record;
  TodayInfoRecord(Key key, this.record) : super(key : key);

  @override
  TodayInfoRecordState createState() => new TodayInfoRecordState(record);
}

class TodayInfoRecordState extends State<TodayInfoRecord> {
  Map record;
  TodayInfoRecordState(this.record);

  @override
  Widget build(BuildContext context) {

    var titleSection = buildTitleSection(record);
    
    var amountSection = Text(
      "￥" + record["amount"].toString(),
      style: Theme.of(context).textTheme.subhead
    );

    return new ListTile(
      title: titleSection,
      trailing: amountSection,
    );
  }

  Widget buildTitleSection(record) {
    var categoryTitleText = Text(
      record["main_category"] + " - " + record["sub_category"],
      style: Theme.of(context).textTheme.subhead
    );

    String dateTime = record["date_time"].toString().split(".")[0];
    var dateTimeText = Text(
      dateTime,
      style: Theme.of(context).textTheme.subtitle
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        categoryTitleText,
        dateTimeText
      ],
    );
  }
}