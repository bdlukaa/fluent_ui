import 'dart:convert';
import 'dart:io';

void main() async {
  // Define the input and output file paths.
  final inputFile = File('segoeicons.md');
  final outputFile = File('segoeicons.json');

  // Check if the input file exists.
  if (!await inputFile.exists()) {
    print('Error: Input file not found at ${inputFile.path}');
    return;
  }

  // Read the content of the markdown file.
  final content = await inputFile.readAsString();

  // This regular expression is the core of the parser.
  // It's designed to be flexible and handle extra whitespace and newlines.
  //
  // Breakdown of the improved regex:
  // - `<tr>\s*`: Matches the opening table row tag, followed by any whitespace.
  // - `<td>\s*<img.*?alt="(.*?)".*?>\s*</td>`: This part captures the glyph name.
  //   - `<td>\s*<img.*?`: Matches the opening tags with optional whitespace.
  //   - `alt="(.*?)"`: Captures the 'alt' attribute's value for the name.
  //   - `.*?>\s*</td>`: Matches the rest of the img tag and the closing td tag, ignoring whitespace.
  // - `\s*`: Matches any whitespace between table cells.
  // - `<td>(.*?)</td>`: Captures the content of the second table data cell (the Unicode).
  // - `\s*`: Matches any whitespace.
  // - `<td>(.*?)</td>`: Captures the content of the third table data cell (the description).
  // - `\s*</tr>`: Matches the closing table row tag, ignoring preceding whitespace.
  final regex = RegExp(
    r'<tr>\s*<td>\s*<img.*?alt="(.*?)".*?>\s*</td>\s*<td>(.*?)</td>\s*<td>(.*?)</td>\s*</tr>',
    multiLine: true,
    dotAll: true,
  );

  // Find all matches in the file content.
  final matches = regex.allMatches(content);

  // Create a list to hold the glyph data.
  final glyphs = <Map<String, String>>[];

  // Iterate over the matches and extract the data.
  for (final match in matches) {
    // Gracefully handle potential nulls from capture groups.
    // The .trim() method removes leading/trailing whitespace from the captured strings.
    final name = match.group(1)?.trim() ?? 'Unknown';
    final unicode = match.group(2)?.trim() ?? 'Unknown';

    // Add the extracted data to our list as a map.
    glyphs.add({'name': name, 'unicode': unicode});
  }

  // Create the final JSON structure.
  final jsonOutput = {'glyphs': glyphs};

  // Use JsonEncoder for a nicely formatted ("pretty-printed") JSON output.
  final encoder = JsonEncoder.withIndent('  ');
  final jsonString = encoder.convert(jsonOutput);

  // Write the JSON string to the output file.
  await outputFile.writeAsString(jsonString);

  // Print a success message to the console.
  print(
    'Successfully parsed ${glyphs.length} glyphs and saved to ${outputFile.path}',
  );
}
