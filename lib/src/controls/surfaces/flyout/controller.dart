import 'package:flutter/foundation.dart';

class FlyoutController extends ChangeNotifier with Diagnosticable {
  bool _open = false;

  bool get isOpen => _open;
  bool get isClosed => !_open;

  void open() {
    _open = true;
    notifyListeners();
  }

  void close() {
    _open = false;
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('open', value: isOpen, ifFalse: 'closed', defaultValue: false,));
  }
}
