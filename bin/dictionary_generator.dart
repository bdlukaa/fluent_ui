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

const String header = '''
class ResourceDictionary {
''';

void main(List<String> args) async {
  if (Directory.current.path.split(pathSeparator).last == "bin") {
    print("Run the generator from the lib/ folder");
    return;
  }

  final StringBuffer dartFileBuffer = StringBuffer(fileHeader);

  // Generates
  void generateFor(String dictionary, String constructor) {
    dartFileBuffer.writeln('\n  const ResourceDictionary.$constructor({');
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
        '    this.${resourceName.lowercaseFirst()} = const Color(0x$resourceHex),',
      );
    }
    dartFileBuffer.writeln("  });");
  }

  // generates abstract dictionary
  dartFileBuffer.writeln(header);
  for (final resourceLine in defaultResourceDirectionary.split('\n')) {
    if (resourceLine.trim().isEmpty) continue;
    final resourceName = () {
      final split = resourceLine.trim().split('"');
      return split[1];
    }();

    dartFileBuffer.writeln(
      '  final Color ${resourceName.lowercaseFirst()};',
    );
  }

  dartFileBuffer.writeln('\n  const ResourceDictionary.raw({');
  for (final resourceLine in defaultResourceDirectionary.split('\n')) {
    if (resourceLine.trim().isEmpty) continue;
    final resourceName = () {
      final split = resourceLine.trim().split('"');
      return split[1];
    }()
        .lowercaseFirst();

    dartFileBuffer.writeln(
      '    required this.$resourceName,',
    );
  }

  dartFileBuffer.writeln("  });");

  // generate default dictionary
  generateFor(defaultResourceDirectionary, 'dark');

  // generate light resource dictionary
  generateFor(lightResourceDictionary, 'light');

  // generate lerp method
  dartFileBuffer.writeln(
      '\n  static ResourceDictionary lerp(ResourceDictionary a, ResourceDictionary b, double t) {');
  dartFileBuffer.writeln('    return ResourceDictionary.raw(');
  for (final resourceLine in defaultResourceDirectionary.split('\n')) {
    if (resourceLine.trim().isEmpty) continue;
    final resourceName = () {
      final split = resourceLine.trim().split('"');
      return split[1];
    }()
        .lowercaseFirst();

    dartFileBuffer.writeln(
      '      $resourceName: Color.lerp(a.$resourceName, b.$resourceName, t)!,',
    );
  }
  dartFileBuffer.writeln('    );');
  dartFileBuffer.writeln('  }');

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
