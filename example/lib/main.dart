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
        // brightness: Brightness.light,
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

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      header: AppBar(
        title: Text('Fluent UI App Showcase'),
        bottom: Pivot(
          currentIndex: index,
          onChanged: (i) => setState(() => index = i),
          pivots: [
            PivotItem(text: Text('Buttons')),
            PivotItem(text: Text('Surfaces')),
          ],
        ),
      ),
      body: PivotView(
        currentIndex: index,
        pages: <Widget>[
          Column(
            children: [
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
              SizedBox(
                // height: 30,
                width: 70,
                child: Toggle(
                  checked: value,
                  onChange: (v) => setState(() => value = v),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Card(
                child: Text('hahaha'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
