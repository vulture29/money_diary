import 'package:flutter/material.dart';
import 'package:money_diary/db/db.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:async';

DatabaseHandle dbHandler;
Set showNoteId = new Set();

class DetailPage extends StatefulWidget {
  DetailPage(DatabaseHandle handler) {
    dbHandler = handler;
  }

  @override
  DetailPageState createState() => new DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  List _recordDetail = [];

  void loadRecordFromDb() async {
    if (dbHandler.getRecordDatabse() != null) {
      List recordDetail = await dbHandler.getRecordDatabse().find({});
      
      setState(() {
        _recordDetail = recordDetail;
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
    var body;
    if (_recordDetail.length > 0) {
      body = _buildRecordList();
    }
    else {
      body = Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("详细信息"),
        elevation: 0,
      ),
      body: Container(
        child:RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.pink,
          child: body
        )
      )
      // body: Text(_recordDetail.toString()),
    );
  }

  Future<Null> _refresh() async {
    return;
  }

  Widget _buildRecordList() {
    return Scrollbar(
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        // itemCount: _recordDetail.length * 2 - 1,
        // itemBuilder: (BuildContext _context, int i) {
        //   if (i.isOdd) {
        //     return const Divider();
        //   }
        //   var index = _recordDetail.length - i ~/ 2 - 1;
        //   return DetailRecord(_recordDetail[index]);
        // }
        itemCount: _recordDetail.length,
        itemBuilder: (BuildContext _context, int i) {
          return DetailRecord(_recordDetail[i]);
        }
      )
    );
  }
}

class DetailRecord extends StatefulWidget {
  final Map record;
  DetailRecord(this.record);

  @override
  DetailRecordState createState() => new DetailRecordState(record);
}

class DetailRecordState extends State<DetailRecord> {
  Map record;
  DetailRecordState(this.record);
  String recordId = "";

  @override
  Widget build(BuildContext context) {
    IconData iconData; 
    var category =record["main_category"];
    switch (category) {
      case "餐饮":
        iconData = Icons.restaurant;
        break;
      case "宠物":
        iconData = MdiIcons.cat;
        break;
      case "游玩":
        iconData = Icons.wb_sunny;
        break;
      case "刚需":
        iconData = Icons.gavel;
        break;
      case "美容":
        iconData = Icons.face;
        break;
      case "电子":
        iconData = Icons.computer;
        break;
      case "其他":
        iconData = Icons.local_atm;
        break;
      case "医疗":
        iconData = MdiIcons.medicalBag;
        break;
      default:
    }
    var iconSection = new Icon(iconData);

    recordId =record["_id"];
    var _showNoteId = showNoteId.contains(recordId);
    var titleSection = buildTitleSection(record, _showNoteId);
    
    var amountSection = Text(
      "￥" + record["amount"].toString(),
      style: Theme.of(context).textTheme.headline
    );

    return buildDetailRow(iconSection, titleSection, amountSection, _showNoteId) ;
  }

  Widget buildDetailRow(iconSection, titleSection, amountSection, _showNoteId) {
    return new Slidable(
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: new Container(
        color: Colors.white,
        child: ListTile(
          leading: iconSection,
          title: titleSection,
          trailing: amountSection,
          onTap: () {
            if (recordId.length == 0) {
              return;
            }
            setState(() {
              if (_showNoteId) {
                showNoteId.remove(recordId);
              } else {
                showNoteId.add(recordId);
              }
            });
          },
        )
      ),
      secondaryActions: <Widget>[
        new IconSlideAction(
          caption: '编辑',
          color: Colors.black45,
          icon: Icons.edit,
          onTap: () => print("edit record")
        ),
        new IconSlideAction(
          caption: '删除',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            if (recordId.length == 0) {
              return;
            }
            dbHandler.deleteRecord(recordId);
          }
        ),
      ],
    );
  }

  Widget buildTitleSection(record, showNote) {
    var categoryTitleText = Text(
      record["main_category"] + " - " + record["sub_category"],
      style: Theme.of(context).textTheme.title
    );

    var noteText = Text(
      record["note"],
      style: Theme.of(context).textTheme.caption
    );

    String dateTime = record["date_time"].toString().split(".")[0];
    var dateTimeText = Text(
      dateTime,
      style: Theme.of(context).textTheme.subtitle
    );
    if(showNote) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          categoryTitleText,
          noteText,
          dateTimeText
        ],
      );
    }
    else {
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

}