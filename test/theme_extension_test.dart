import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ThemeExtension on FluentTheme', (tester) async {
    await tester.pumpWidget(
      FluentApp(
        theme: FluentThemeData(
          extensions: [MyColors(success: Colors.green, failure: Colors.red)],
        ),
        builder: (context, child) {
          final ext = FluentTheme.of(context).extension<MyColors>();

          expect(ext, isNotNull);
          expect(ext!.success, Colors.green);
          expect(ext.failure, Colors.red);

          return const SizedBox.shrink();
        },
      ),
    );
  });
}

@immutable
class MyColors extends ThemeExtension<MyColors> {
  //
  const MyColors({required this.success, required this.failure});

  final Color? success;
  final Color? failure;

  @override
  ThemeExtension<MyColors> copyWith({Color? success, Color? failure}) {
    return MyColors(
      success: success ?? this.success,
      failure: failure ?? this.failure,
    );
  }

  @override
  ThemeExtension<MyColors> lerp(ThemeExtension<MyColors>? other, double t) {
    if (other is! MyColors) {
      return this;
    }
    return MyColors(
      success: Color.lerp(success, other.success, t),
      failure: Color.lerp(failure, other.failure, t),
    );
  }

  @override
  String toString() {
    return 'MyColors(success: $success, failure: $failure)';
  }

  static const light = MyColors(
    success: Color(0xFF28A745),
    failure: Color.fromARGB(255, 128, 7, 35),
  );

  static const dark = MyColors(
    success: Color.fromARGB(255, 226, 234, 8),
    failure: Color.fromARGB(255, 205, 127, 18),
  );
}
