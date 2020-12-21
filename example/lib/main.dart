import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Fluent ui app showcase',
      style: Style(
        brightness: Brightness.dark,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      header: AppBar(
        // leading: Icon(Icons.add),
        title: Text('Fluent UI App Showcase'),
        subtitle: Text('sub'),
        // trailing: [Icon(Icons.add), Icon(Icons.add)],
        bottom: Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[70],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('Search', style: TextStyle(color: Colors.white)),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              child: Text('hahaha'),
            ),
            Button(
              text: Text('Next page =>'),
              subtext: Text('Select ingredients'),
              icon: Icon(material.Icons.add),
              trailingIcon: Icon(material.Icons.add),
              onPressed: () {
                print('pressed');
              },
            ),
            Button.action(
              icon: Icon(material.Icons.add),
              text: Text('Action Button'),
              onPressed: () {},
            ),
            Button.icon(
              icon: Icon(material.Icons.add),
              menu: Icon(material.Icons.add),
              onPressed: () {},
            ),
            Checkbox(
              checked: value,
              onChange: (v) => setState(() => value = v),
              // onChange: null,
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
