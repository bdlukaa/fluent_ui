// ignore_for_file: avoid_print

import 'dart:io';

import 'icon_generator.dart' show pathSeparator;
import 'resource_dictionary.dart';

const String fileHeader = """
// GENERATED FILE, DO NOT EDIT
// This generates the values from https://github.com/microsoft/microsoft-ui-xaml/blob/main/dev/CommonStyles/Common_themeresources_any.xaml

// ignore_for_file: constant_identifier_names, public_member_api_docs

import 'package:flutter/widgets.dart' show Color, ColorProperty;
import 'package:flutter/foundation.dart';

""";

const String header = '''
/// A dictionary of colors used by all the components.
/// 
/// Use `ResourceDictionary.dark` or `ResourceDictionary.light` to get colors
/// adapted to dark and light mode, respectively
/// 
/// See also:
/// 
///   * <https://github.com/microsoft/microsoft-ui-xaml/blob/main/dev/CommonStyles/Common_themeresources_any.xaml>
class ResourceDictionary with Diagnosticable {
''';

/// How to generate the resources:
/// - Go on `https://github.com/microsoft/microsoft-ui-xaml/blob/main/src/controls/dev/CommonStyles/Common_themeresources_any.xaml`
/// - Copy the colors under <Default> and paste them on [defaultResourceDirectionary]
/// - Copy the colors under <Light> and paste them on [lightResourceDictionary]
/// - Run the generator with `dart bin/dictionary_generator.dart` while being
///   on the `lib/` directory as PWD
/// - Enjoy
///
/// This only support the <Color> tag
void main(List<String> args) async {
  if (Directory.current.path.split(pathSeparator).last == 'bin') {
    print('Run the generator from the lib/ folder');
    return;
  }

  final dartFileBuffer = StringBuffer(fileHeader);

  // Generates
  void generateFor(String dictionary, String constructor) {
    dartFileBuffer
      ..writeln('\n  // Colors adapted for $constructor mode')
      ..writeln('  const ResourceDictionary.$constructor({');
    for (final resourceLine in dictionary.split('\n')) {
      if (resourceLine.trim().isEmpty) continue;
      final resourceName = () {
        final split = resourceLine.trim().split('"');
        return split[1];
      }();

      var resourceHex = () {
        final result = resourceLine
            .replaceAll('<Color x:Key="$resourceName">', '')
            .replaceAll('</Color>', '')
            .trim();
        return result;
      }().replaceAll('#', '').toLowerCase();

      if (resourceHex.length == 6) {
        resourceHex = 'FF$resourceHex';
      }

      dartFileBuffer.writeln(
        '    this.${resourceName.lowercaseFirst()} = const Color(0x$resourceHex),',
      );
    }
    dartFileBuffer.writeln('  });');
  }

  // generates abstract dictionary
  dartFileBuffer.writeln(header);
  for (final resourceLine in defaultResourceDirectionary.split('\n')) {
    if (resourceLine.trim().isEmpty) continue;
    final resourceName = () {
      final split = resourceLine.trim().split('"');
      return split[1];
    }();

    dartFileBuffer.writeln('  final Color ${resourceName.lowercaseFirst()};');
  }

  dartFileBuffer.writeln('\n  const ResourceDictionary.raw({');
  for (final resourceLine in defaultResourceDirectionary.split('\n')) {
    if (resourceLine.trim().isEmpty) continue;
    final resourceName = () {
      final split = resourceLine.trim().split('"');
      return split[1];
    }().lowercaseFirst();

    dartFileBuffer.writeln('    required this.$resourceName,');
  }

  dartFileBuffer.writeln('  });');

  // generate default dictionary
  generateFor(defaultResourceDirectionary, 'dark');

  // generate light resource dictionary
  generateFor(lightResourceDictionary, 'light');

  // generate lerp method
  dartFileBuffer
    ..writeln(
      '\n  static ResourceDictionary lerp(ResourceDictionary a, ResourceDictionary b, double t,) {',
    )
    ..writeln('    return ResourceDictionary.raw(');
  for (final resourceLine in defaultResourceDirectionary.split('\n')) {
    if (resourceLine.trim().isEmpty) continue;
    final resourceName = () {
      final split = resourceLine.trim().split('"');
      return split[1];
    }().lowercaseFirst();

    dartFileBuffer.writeln(
      '      $resourceName: Color.lerp(a.$resourceName, b.$resourceName, t,)!,',
    );
  }
  dartFileBuffer
    ..writeln('    );')
    ..writeln('  }')
    // generate debugFillProperties method
    ..writeln(
      '\n  @override\n  void debugFillProperties(DiagnosticPropertiesBuilder properties) {',
    )
    ..writeln('    super.debugFillProperties(properties);')
    ..writeln('properties');
  for (final resourceLine in defaultResourceDirectionary.split('\n')) {
    if (resourceLine.trim().isEmpty) continue;
    final resourceName = () {
      final split = resourceLine.trim().split('"');
      return split[1];
    }().lowercaseFirst();

    dartFileBuffer.writeln(
      "    ..add(ColorProperty('${resourceName.lowercaseFirst()}', $resourceName))",
    );
  }
  dartFileBuffer
    ..writeln(';')
    ..writeln('  }')
    ..writeln('}');

  final outputFile = File('lib/src/styles/color_resources.dart');
  final formatProcess = await Process.start('flutter', [
    'format',
    outputFile.path,
  ], runInShell: true);
  stdout.addStream(formatProcess.stdout);
  await outputFile.writeAsString(dartFileBuffer.toString());
}

extension StringExtension on String {
  /// Results this string with the first char uppercased
  ///
  /// January -> january
  String lowercaseFirst() {
    final first = substring(0, 1);
    return first.toLowerCase() + substring(1);
  }
}
