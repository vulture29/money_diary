import 'package:flutter/material.dart';
import 'package:money_diary/db/db.dart';

DatabaseHandle dbHandler;
Entry checkedITem;

class RecordPage extends StatefulWidget {
  RecordPage(handler) {
    dbHandler = handler;
  }
  
  @override
  RecordPageState createState() => new RecordPageState();
}

class RecordPageState extends State<RecordPage> {
  // The entire multilevel list displayed by this app.
  List<Entry> _entryData = <Entry>[];

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  void loadDatabase() async {
    if (dbHandler.getCategoryDatabse() != null) {
      List<Entry> entryData = <Entry>[];
      List categoryRecord = await dbHandler.getCategoryDatabse().find({});
      
      for(var category in categoryRecord) {
        var dataEntry = <Entry>[];
        for (var sub in category['sub_class']) {
          dataEntry.add(Entry(sub));
        }
        entryData.add(
          Entry(category["name"], dataEntry)
        );
      }
      setState(() {
        _entryData = entryData;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // load database
    loadDatabase();
  }

  @override
  Widget build(BuildContext context) {
    Widget titleSection = Container(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
      child: Row(
        children:[
          Text(
            "￥",
            style: Theme.of(context).textTheme.headline,
            ),
          Expanded(
            child: TextField(
              decoration: new InputDecoration.collapsed(hintText: "输入金额"),
              textAlign: TextAlign.end,
              style: new TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
              ),
              controller: amountController,
            )
          ),
        ],
      )
    );

    Widget noteSection = Container(
      padding: const EdgeInsets.fromLTRB(32, 5, 32, 15),
      child: TextField(
          decoration: new InputDecoration.collapsed(hintText: "备注"),
          controller: noteController,
        )
    );

    Widget categorySection = new GestureDetector(
      onTapDown: (detail) {
        // call this method here to hide soft keyboard
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      onTapCancel: () {
        // call this method here to hide soft keyboard
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: new Container(
        height: 450,
        padding: const EdgeInsets.fromLTRB(32, 5, 32, 5),
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) =>
              EntryItem(_entryData[index], this),
          itemCount: _entryData.length,
        ),
      )
    );

    Widget finishButton = new RaisedButton(

      color: Colors.pink[200],
      onPressed: () {
        // TODO: more check
        var amount = amountController.text;
        var note = noteController.text;

        if(double.parse(amount, (e) => null) == null) {
          return;
        }
        if(checkedITem == null) {
          return;
        }
        var category = checkedITem.title;
        dbHandler.insertRecord(amount, note, category);
        
        Navigator.pop(context, "success");
      },
      child: new Text("提交", style: Theme.of(context).textTheme.title),
      // TODO: add style
    );
    Widget finishButtonSection = new Container(
      padding: const EdgeInsets.fromLTRB(32, 15, 32, 0),
      child: ButtonTheme(
        minWidth: 250.0,
        height: 48.0,
        child: finishButton,
      )
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text("添加纪录"),
        elevation: 0,
      ),
      body: Column(
        children: [
          titleSection,
          noteSection,
          categorySection,
          finishButtonSection,
        ],
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}

class EntryItem extends StatefulWidget {
  final Entry entry;
  final RecordPageState state;
  const EntryItem(this.entry, this.state);

  @override
  EntryItemState createState() => new EntryItemState(entry, state);
}

class EntryItemState extends State<StatefulWidget> {
  Entry entry;
  RecordPageState parentState;
  EntryItemState(Entry e, RecordPageState state) {
    this.entry = e;
    this.parentState = state;
  }

  Widget _buildMainTiles(Entry root) {
    if (root.children.isEmpty) return ListTile(title: Text(root.title));
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: Text(root.title),
      children: root.children.map(_buildSubTiles).toList(),
    );
  }

  Widget _buildSubTiles(Entry root) {
    final bool checked = (checkedITem == root);
    String title = root.title.split("_")[1];

    return new ListTile(
      title: new Text(title),
      trailing: new Icon(
        checked ? Icons.check : null,
      ),
      onTap: () {
        if(!checked) {
          parentState.setState(() {
            checkedITem = null;
          });
        }
        setState(() {
          if (checked) {
            checkedITem = null;
          } else {
            checkedITem = root;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainTiles(entry);
  }
}

// One entry in the multilevel list displayed by this app.
class Entry {
  Entry(this.title, [this.children = const <Entry>[]]);

  final String title;
  final List<Entry> children;
}
