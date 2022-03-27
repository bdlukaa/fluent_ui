import 'package:flutter/foundation.dart';

class FlyoutController extends ChangeNotifier with Diagnosticable {
  bool _open = false;

  /// Whether the flyout is open
  bool get isOpen => _open;

  /// Whether the flyout is closed
  bool get isClosed => !_open;

  /// Opens the flyout. Has no effect if it's already open
  void open() {
    _open = true;
    notifyListeners();
  }

  /// Closes the flyout. Has no effect if it's already closed
  void close() {
    _open = false;
    notifyListeners();
  }

  /// Toggles the flyout. If it's opened, it'll be closed. Otherwise, it'll be
  /// opened.
  void toggle() {
    if (isOpen) {
      close();
    } else {
      open();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty(
      'open',
      value: isOpen,
      ifFalse: 'closed',
      defaultValue: false,
    ));
  }
}
