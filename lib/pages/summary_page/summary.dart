import 'package:flutter/material.dart';
import 'package:money_diary/db/db.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_diary/statistics/statistics.dart';
import 'dart:async';


class SummaryPage extends StatefulWidget {
  final DatabaseHandle dbHandler;

  SummaryPage(this.dbHandler);

  @override
  SummaryPageState createState() => new SummaryPageState(dbHandler);
}

class SummaryPageState extends State<SummaryPage> {
  final DatabaseHandle dbHandler;
  double _leftMoney = 0;
  Map _basicInfo = {
    "total_this_month": 0,
    "total_today": 0,
    "income_this_month": 0,
    "total_income": 0,
  };

  SummaryPageState(this.dbHandler);

  // void loadIncomeFromDb() async {
  //   if (dbHandler.getRecordDatabse() != null) {
  //     List incomeDetail = await dbHandler.getIncomeDatabse().find({});
  //     print(incomeDetail.toString());
  //     setState(() {
  //       _incomeDetail = incomeDetail;
  //     });      
  //   }
  // }

  void loadBasicFromDb() async {
    if (dbHandler.getBasicDatabase() != null) {
      String date = DateTime.now().toString().split(" ")[0];
      List basicRecord = await dbHandler.getBasicDatabase().find({"update_date": date});
      
      if(basicRecord.length > 0) {
        Map basicInfo = {
          "total_this_month": basicRecord[0]["total_this_month"],
          "total": basicRecord[0]["total"],
          "income_this_month": basicRecord[0]["income_this_month"],
          "total_income": basicRecord[0]["total_income"],
        };
        setState(() {
          _basicInfo = basicInfo;
          _leftMoney = _basicInfo["total_income"] - _basicInfo["total"];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadBasicFromDb();
    // loadIncomeFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Summary'),
        elevation: 0,
      ),
      body: _buildSummary(),
    );
  }

  Widget _buildSummary() {
    String tipTextStr = "加油~好好理财吧";
    if (_leftMoney < 500) {
      tipTextStr = "额，快破产了 T^T";
    }
    else if (_leftMoney < 2000) {
      tipTextStr = "省着点花！钱不多了";
    }

    var incomeTextSection = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Text(
            "你总共还剩",
            style: Theme.of(context).textTheme.title
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "￥",
                style: Theme.of(context).textTheme.subhead
              ),
              Text(
                _leftMoney.toString(),
                style: Theme.of(context).textTheme.display2
              ),
            ],
          ),
          Text(tipTextStr),
        ]
      )
    );

    var incomeSection = Container(
      alignment: Alignment.center,
      height: 128,
      decoration: BoxDecoration(
        color: Colors.pink[100],
        borderRadius: BorderRadius.all(Radius.circular(16))
      ),
      child: incomeTextSection,
    );

    var summaryContext = Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: incomeSection,
    );


    return Container(
      child: RefreshIndicator(
        onRefresh: ()=>null,
        color: Colors.pink,
        child: summaryContext
      )
    );
  }
}