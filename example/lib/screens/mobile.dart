import 'package:fluent_ui/fluent_ui.dart';

class Mobile extends StatefulWidget {
  const Mobile({Key? key}) : super(key: key);

  @override
  _MobileState createState() => _MobileState();
}

class _MobileState extends State<Mobile> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: NavigationBody(
        children: [
          ScaffoldPage(header: PageHeader(title: Text('Mobile'))),
          ScaffoldPage(header: PageHeader(title: Text('Android'))),
          ScaffoldPage(header: PageHeader(title: Text('iOS'))),
        ],
        index: _currentIndex,
      ),
      bottomBar: BottomNavigation(
        index: _currentIndex,
        onChanged: (i) => setState(() => _currentIndex = i),
        items: [
          BottomNavigationItem(
            icon: Icon(Icons.two_k),
            selectedIcon: Icon(Icons.two_k_plus),
            title: Text('Both'),
          ),
          BottomNavigationItem(
            icon: Icon(Icons.phone_android_outlined),
            selectedIcon: Icon(Icons.phone_android),
            title: Text('Android'),
          ),
          BottomNavigationItem(
            icon: Icon(Icons.phone_iphone_outlined),
            selectedIcon: Icon(Icons.phone_iphone),
            title: Text('iOS'),
          ),
        ],
      ),
    );
  }
}
