// ignore_for_file: avoid_print

import 'dart:io';

import 'icon_generator.dart' show pathSeparator;
import 'resource_dictionary.dart';

const String fileHeader = """
// GENERATED FILE, DO NOT EDIT
// This generates the values from https://github.com/microsoft/microsoft-ui-xaml/blob/main/dev/CommonStyles/Common_themeresources_any.xaml

// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart' show Color;

""";

const String defaultHeader = '''
class DefaultResourceDirectionary {
  const DefaultResourceDirectionary._();
''';

const String lightHeader = '''
class LightResourceDirectionary {
  const LightResourceDirectionary._();
''';

void main(List<String> args) async {
  if (Directory.current.path.split(pathSeparator).last == "bin") {
    print("Run the generator from the lib/ folder");
    return;
  }

  final StringBuffer dartFileBuffer = StringBuffer(fileHeader);

  // Generates
  void generateFor(String dictionary) {
    for (final resourceLine in dictionary.split('\n')) {
      if (resourceLine.trim().isEmpty) continue;
      final resourceName = () {
        final split = resourceLine.trim().split('"');
        return split[1];
      }();

      String resourceHex = () {
        final result = resourceLine
            .replaceAll('<Color x:Key="$resourceName">', '')
            .replaceAll('</Color>', '')
            .trim();
        return result;
      }()
          .replaceAll('#', '')
          .toLowerCase();

      if (resourceHex.length == 6) {
        resourceHex = 'FF$resourceHex';
      }

      dartFileBuffer.writeln(
        '  static const Color ${resourceName.lowercaseFirst()} = Color(0x$resourceHex);',
      );
    }
  }

  // generate default dictionary
  dartFileBuffer.writeln(defaultHeader);
  generateFor(defaultResourceDirectionary);
  dartFileBuffer.writeln("}");

  // generate light resource dictionary
  dartFileBuffer.writeln(lightHeader);
  generateFor(lightResourceDictionary);
  dartFileBuffer.writeln("}");

  final outputFile = File("lib/src/styles/color_resources.dart");
  // final formatProcess = await Process.start(
  //   'flutter',
  //   ['format', outputFile.path],
  // );
  // stdout.addStream(formatProcess.stdout);
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
