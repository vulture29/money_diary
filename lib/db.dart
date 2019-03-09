import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:objectdb/objectdb.dart';
import 'package:money_diary/statistics.dart';
import 'package:money_diary/network.dart';
import 'dart:async';

class DatabaseHandle {
  ObjectDB basicDatabase;
  ObjectDB categoryDatabase;
  ObjectDB recordDatabase;
  
  Future<Null> loadDatabase() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String basicDbFilePath = [appDocDir.path, 'basic.db'].join('/');
    String categoryDbFilePath = [appDocDir.path, 'category.db'].join('/');
    String recordDbFilePath = [appDocDir.path, 'record.db'].join('/');

    // delete old database file if exists
    // File basicDbFile = File(basicDbFilePath);
    File categoryDbFile = File(categoryDbFilePath);

    // check if database already exists
    // var basicIsNew = !await basicDbFile.exists();
    var categoryIsNew = !await categoryDbFile.exists();

    // initialize and open database
    basicDatabase = ObjectDB(basicDbFilePath);
    categoryDatabase = ObjectDB(categoryDbFilePath);
    recordDatabase = ObjectDB(recordDbFilePath);
    await basicDatabase.open();
    await categoryDatabase.open();
    await recordDatabase.open();

    if (categoryIsNew) {
      print("category is new ====");
      await categoryDatabase.insertMany([
        {
          'name': "餐饮",
          'sub_class': ["餐饮_日常", "餐饮_大餐", "餐饮_零食", "餐饮_水果"],
        },
        {
          'name': "宠物",
          'sub_class': ["宠物_食物", "宠物_玩具", "宠物_医疗", "宠物_其他"],
        },
        {
          'name': "游玩",
          'sub_class': ["游玩_电影", "游玩_娱乐", "游玩_交通", "游玩_住宿"],
        },
        {
          'name': "刚需",
          'sub_class': ["刚需_日用", "刚需_交通", "刚需_通信", "刚需_学习"],
        },
        {
          'name': "美容",
          'sub_class': ["美容_护肤", "美容_美妆", "美容_鞋包服饰"],
        },
        {
          'name': "电子",
          'sub_class': ["电子_数码产品", "电子_家用电器", "电子_配件"],
        },
        {
          'name': "其他",
          'sub_class': ["其他_人情", "其他_玩具"],
        },
        {
          'name': "医疗",
          'sub_class': ["医疗_药品", "医疗_治疗"],
        },
        {
          'name': "收入",
          'sub_class': ["收入_工资"],
        },
      ]);
    }
    await categoryDatabase.update(
      {'name': "刚需",}, 
      {'sub_class': ["刚需_日用", "刚需_交通", "刚需_通信", "刚需_学习"]}
    );

    initStatisticDbHandler(this);
  }

  ObjectDB getBasicDatabase() {
    return basicDatabase;
  }

  ObjectDB getCategoryDatabse() {
    return categoryDatabase;
  }

  ObjectDB getRecordDatabse() {
    return recordDatabase;
  }

  void insertRecord(String amountStr, String note, String categoryStr) async{
    double amount = double.parse(double.parse(amountStr).toStringAsFixed(2));
    String mainCategory = categoryStr.split("_")[0];
    String subCategory = categoryStr.split("_")[1];
    var dateTime = DateTime.now();
    var dateStr = dateTime.toString().split(" ")[0];
    int timestamp = dateTime.millisecondsSinceEpoch;
    
    var record = {
      "year": dateStr.split("-")[0],
      "month": dateStr.split("-")[0] + dateStr.split("-")[1],
      "date": dateStr,
      "date_time": dateTime.toString(),
      "timestamp": timestamp,
      "amount": amount,
      "note": note,
      "main_category": mainCategory,
      "sub_category":subCategory,
    };
    print("Insert Record: " + record.toString());
    String recordId = (await recordDatabase.insert(record)).toString();
    sendRecord(amount, note, categoryStr, timestamp, recordId);
  }

  void deleteRecord(String recordId) {
    print("delete " + recordId);
  }
}