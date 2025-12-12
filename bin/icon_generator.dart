// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:recase/recase.dart';

/// How to update the icons:
/// - Go on `https://uifabricicons.azurewebsites.net/`
/// - Scroll completely down
/// - Start dragging from the bottom right empty corner all the way up to top
///   left to select every single icon
/// - Click on "Get subset"
/// - Open the zip and put the json file on `config/` in the `bin/` folder
/// - Open the fonts folder and get the .woff file
/// - Convert the .woff file into .ttf with any woff to ttf converter,
///   i recommend `https://convertio.co/woff-ttf/` because i already used it and
///   it works fine
/// - Rename the ttf file to `FluentIcons.ttf` and place it on `fonts/`
/// - Run the generator with `dart bin/icon_generator.dart` while being
///   on the `lib/` directory as PWD
/// - Enjoy
void main(List<String> args) async {
  if (Directory.current.path.split(pathSeparator).last == 'bin') {
    print('Run the generator from the lib/ folder');
    return;
  }

  final iconsFile = File('bin/windows_icons/segoeicons.json');
  final iconsString = await iconsFile.readAsString();
  final iconsJson = json.decode(iconsString) as Map<String, dynamic>;
  final glyphs =
      (iconsJson['glyphs'] as List<dynamic>)
          .map<Glyph>(mapToGlyph)
          .toSet()
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  final dartFileBuffer = StringBuffer(fileHeader);
  for (final glyph in glyphs) {
    dartFileBuffer.writeln(
      "  static const IconData ${glyph.name} = IconData(0x${glyph.codepoint}, fontFamily: 'SegoeIcons', fontPackage: 'fluent_ui',);\n",
    );
  }

  // NEW Map of all glyphs (adds iteration capabilities)
  dartFileBuffer.writeln('  static const Map<String, IconData> allIcons = {');
  for (final glyph in glyphs) {
    dartFileBuffer.writeln("    '${glyph.name}': ${glyph.name},");
  }
  dartFileBuffer
    ..writeln('  };')
    ..writeln('}');
  final outputFile = File('lib/src/windows_icons.dart');
  final formatProcess = await Process.start('flutter', [
    'format',
    outputFile.path,
  ], runInShell: true);
  stdout.addStream(formatProcess.stdout);
  await outputFile.writeAsString(dartFileBuffer.toString());
}

Glyph mapToGlyph(dynamic item) {
  final jsonItem = item as Map<String, dynamic>;
  final name = ReCase(jsonItem['name']!).snakeCase;
  final String codepoint = jsonItem['unicode']!.toLowerCase();

  return Glyph(name: sanitizeName(name), codepoint: codepoint);
}

/// This function will need to be updated if any icon with an incompatible
/// name is introduced.
///
/// Such names usually are reserved keyword (like switch here) or
/// names that start with a number
String sanitizeName(String name) {
  switch (name) {
    case 'switch':
      return 'switch_widget';
    case '12_point_star':
      return 'twelve_point_star';
    case '6_point_star':
      return 'six_point_star';
    default:
      return name;
  }
}

String get pathSeparator => Platform.isWindows ? '\\' : '/';

const String fileHeader = """
// GENERATED FILE, DO NOT EDIT

// ignore_for_file: constant_identifier_names, public_member_api_docs

import 'package:flutter/widgets.dart' show IconData;

class WindowsIcons {
  const WindowsIcons._();

""";

class Glyph {
  final String name;
  final String codepoint;

  const Glyph({required this.name, required this.codepoint});

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is Glyph) {
      return name == other.name;
    }
    return false;
  }
}
