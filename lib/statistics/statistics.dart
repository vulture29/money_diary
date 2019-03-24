import 'package:money_diary/db/db.dart';
import 'package:objectdb/objectdb.dart';
import 'dart:async';

DatabaseHandle dbHandler;
bool updateLock = false;

void initStatisticDbHandler(DatabaseHandle handler) {
  dbHandler = handler;
}

Future<Null> updateBasicDb() async {
  if (updateLock) {
    print("update locked");
    return;
  }
  updateLock = true;
  String dateStr = DateTime.now().toString().split(" ")[0];
  String monthStr = dateStr.split("-")[0] + dateStr.split("-")[1];

  ObjectDB basicDatabase = dbHandler.getBasicDatabase();
  ObjectDB recordDatabase = dbHandler.getRecordDatabse();
  ObjectDB incomeDatabase = dbHandler.getIncomeDatabse();

  List todayRecord = await recordDatabase.find({"date": dateStr});
  var todaySum = todayRecord.fold(0, (a, b) => a + b["amount"]);
  todaySum = double.parse(todaySum.toStringAsFixed(2));

  List thisMonthRecord = await recordDatabase.find({"month": monthStr});
  var thisMonthSum = thisMonthRecord.fold(0, (a, b) => a + b["amount"]);
  thisMonthSum = double.parse(thisMonthSum.toStringAsFixed(2));

  List totalRecord = await recordDatabase.find({});
  var totalSum = totalRecord.fold(0, (a, b) => a + b["amount"]);
  totalSum = double.parse(totalSum.toStringAsFixed(2));

  List thisMonthIncome = await incomeDatabase.find({"month": monthStr});
  var thisMonthSumIncome = thisMonthIncome.fold(0, (a, b) => a + b["amount"]);
  thisMonthSumIncome = double.parse(thisMonthSumIncome.toStringAsFixed(2));

  List totalIncome = await incomeDatabase.find({});
  var totalSumIncome = totalIncome.fold(0, (a, b) => a + b["amount"]);
  totalSumIncome = double.parse(totalSumIncome.toStringAsFixed(2));
  
  List basicRecord = await dbHandler.getBasicDatabase().find({"update_date": dateStr});
  
  if (basicRecord.length == 0) {
    await basicDatabase.insert({
      "update_date": dateStr,
      "total_today": todaySum,
      "total_this_month":thisMonthSum,
      "total":totalSum,
      "income_this_month":thisMonthSumIncome,
      "total_income":totalSumIncome,
    });
  }
  else {
    await basicDatabase.update({"update_date": dateStr},
      {
        "total_today": todaySum,
        "total_this_month":thisMonthSum,
        "total":totalSum,
        "income_this_month":thisMonthSumIncome,
        "total_income":totalSumIncome,
      }
    );
  }
  await basicDatabase.tidy();

  updateLock = false;
}

Future<List> getTodayRecordList() async {
  String dateStr = DateTime.now().toString().split(" ")[0];
  ObjectDB recordDatabase = dbHandler.getRecordDatabse();

  if (recordDatabase == null) {
    return null;
  }
  List todayRecord = await recordDatabase.find({"date": dateStr});
  return todayRecord;
}