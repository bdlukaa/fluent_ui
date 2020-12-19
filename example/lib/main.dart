import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons, FloatingActionButton;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Fluent ui app showcase',
      theme: ThemeData(
        brightness: Brightness.light,
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
            Button.compound(
              text: Text('Next page =>'),
              subtext: Text('Select ingredients'),
              onPressed: () {
                print('pressed');
              },
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
