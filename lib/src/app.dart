import 'package:flutter/material.dart';

/// Add the fluent theme to your application.
/// 
/// Simple usage:
/// ```dart
/// FluentTheme(
///   child: MaterialApp(),
/// )
/// ```
class FluentTheme extends StatelessWidget {
  const FluentTheme({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}