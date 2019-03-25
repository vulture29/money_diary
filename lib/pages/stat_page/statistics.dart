import 'package:flutter/material.dart';
import 'package:money_diary/db/db.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_diary/util/caculator.dart';
import 'dart:async';


class StatisticsPage extends StatefulWidget {
  final DatabaseHandle dbHandler;

  StatisticsPage(this.dbHandler);

  @override
  StatisticsPageState createState() => new StatisticsPageState(dbHandler);
}

class StatisticsPageState extends State<StatisticsPage> {
  final DatabaseHandle dbHandler;
  double _leftMoney = 0;
  Map _basicInfo = {
    "total_this_month": 0,
    "total_today": 0,
    "income_this_month": 0,
    "total_income": 0,
  };

  StatisticsPageState(this.dbHandler);

  Map _categoryStat = {};
  String curMonth = "";

  void loadRecordFromDb() async {
    if (dbHandler.getRecordDatabse() != null) {
      if (curMonth.length == 0) {
        var dateTime = DateTime.now();
        var dateStr = dateTime.toString().split(" ")[0];
        curMonth = dateStr.split("-")[0] + dateStr.split("-")[1];
      }

      Map categoryStat = {};

      List categoryList = await dbHandler.getCategoryDatabse().find({});
      for (var category in categoryList) {
        List categoryDetail = await dbHandler.getRecordDatabse().find(
          {
            "main_category": category["name"],
            "month": curMonth,
          }
        );
        double categorySum = categoryDetail.fold(0, (a, b) => a + b["amount"]);
        categorySum = double.parse(categorySum.toStringAsFixed(2));

        categoryStat[category["name"]] = categorySum;
      }

      setState(() {
        _categoryStat = categoryStat;
      });      
    }
  }

  @override
  void initState() {
    super.initState();
    loadRecordFromDb();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("统计信息"),
        elevation: 0,
      ),
      body: _buildPage(),
    );
  }

  Widget _buildPage() {

    Widget timeSection = new Text(curMonth);
    Widget categoryListSection = Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      height: 640,
      child: _buildCategoryList()
    );

    var pageContext = ListView.builder(
      // padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
      itemCount: 2,
      itemBuilder: (BuildContext _context, int index) {
        switch (index) {
          case 0:
            return timeSection;
          case 1:
            return categoryListSection;
          default:
        }
      }
    );

    return new Container(
      child: pageContext,
    );
  }

  Widget _buildCategoryList() {
    List sortedKeys = _categoryStat.keys.toList(growable:false)
    ..sort((k1, k2) => _categoryStat[k1].compareTo(_categoryStat[k2]));

    return ListView(
      children: sortedKeys.map(_buildTiles).toList(),
    );
  }

  Widget _buildTiles(var key) {
    return new ListTile(
      title: Text(key),
      trailing: Text("￥" + _categoryStat[key].toString()),
    );
  }
}