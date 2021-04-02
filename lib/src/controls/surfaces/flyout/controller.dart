import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class FlyoutController extends ChangeNotifier with Diagnosticable {
  bool _open = false;
  bool get open => _open;
  set open(bool open) {
    _open = open;
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('open', value: open, ifFalse: 'closed'));
  }
}
