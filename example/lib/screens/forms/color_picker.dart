import 'package:example/widgets/code_snippet_card.dart';
import 'package:example/widgets/page.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({super.key});

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> with PageMixin {
  Color _selectedColor = Colors.blue;
  bool _isMoreButtonVisible = false;
  bool _isColorSliderVisible = true;
  bool _isColorChannelTextInputVisible = true;
  bool _isHexInputVisible = true;
  bool _isAlphaEnabled = false;
  bool _isAlphaSliderVisible = false;
  bool _isAlphaTextInputVisible = false;
  bool _isColorPreviewVisible = true;
  ColorSpectrumShape _spectrumShape = ColorSpectrumShape.box;
  Axis _orientation = Axis.vertical;

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('ColorPicker'),
        commandBar: Button(
          onPressed: () => setState(() {
            _selectedColor = Colors.red;
            _isMoreButtonVisible = false;
            _isColorSliderVisible = true;
            _isColorChannelTextInputVisible = true;
            _isHexInputVisible = true;
            _isAlphaEnabled = false;
            _isAlphaSliderVisible = false;
            _isAlphaTextInputVisible = false;
            _isColorPreviewVisible = true;
            _spectrumShape = ColorSpectrumShape.box;
            _orientation = Axis.vertical;
          }),
          child: const Text('Reset'),
        ),
      ),
      children: [
        const Text(
          'A ColorPicker control lets users select a color using a color spectrum, '
          'sliders, and text input. It includes RGB (Red, Green, Blue) and HSV '
          '(Hue, Saturation, Value) color representations.\n\n'
          'The ColorPicker includes two spectrum shapes (box and ring) and several '
          'optional components that can be shown or hidden.',
        ),
        const SizedBox(height: 20),
        // Options
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spectrum Shape:',
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                RadioButton(
                  checked: _spectrumShape == ColorSpectrumShape.box,
                  onChanged: (final v) {
                    if (v) {
                      setState(() => _spectrumShape = ColorSpectrumShape.box);
                    }
                  },
                  content: const Text('Box'),
                ),
                const SizedBox(width: 20),
                RadioButton(
                  checked: _spectrumShape == ColorSpectrumShape.ring,
                  onChanged: (final v) {
                    if (v) {
                      setState(() => _spectrumShape = ColorSpectrumShape.ring);
                    }
                  },
                  content: const Text('Ring'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Layout:',
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                RadioButton(
                  checked: _orientation == Axis.vertical,
                  onChanged: (final v) {
                    if (v) setState(() => _orientation = Axis.vertical);
                  },
                  content: const Text('Vertical'),
                ),
                const SizedBox(width: 20),
                RadioButton(
                  checked: _orientation == Axis.horizontal,
                  onChanged: (final v) {
                    if (v) setState(() => _orientation = Axis.horizontal);
                  },
                  content: const Text('Horizontal'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Options:',
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Checkbox(
                  checked: _isColorPreviewVisible,
                  onChanged: (final v) =>
                      setState(() => _isColorPreviewVisible = v!),
                  content: const Text('Color Preview'),
                ),
                Checkbox(
                  checked: _isColorSliderVisible,
                  onChanged: (final v) =>
                      setState(() => _isColorSliderVisible = v!),
                  content: const Text('Color Slider'),
                ),
                if (_orientation == Axis.vertical) ...[
                  Checkbox(
                    checked: _isMoreButtonVisible,
                    onChanged: (final v) =>
                        setState(() => _isMoreButtonVisible = v!),
                    content: const Text('More Button'),
                  ),
                ],
                Checkbox(
                  checked: _isColorChannelTextInputVisible,
                  onChanged: (final v) =>
                      setState(() => _isColorChannelTextInputVisible = v!),
                  content: const Text('Channel Text Input'),
                ),
                Checkbox(
                  checked: _isHexInputVisible,
                  onChanged: (final v) =>
                      setState(() => _isHexInputVisible = v!),
                  content: const Text('Hex Input'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Checkbox(
                  checked: _isAlphaEnabled,
                  onChanged: (final v) => setState(() {
                    _isAlphaEnabled = v!;
                    if (!v) {
                      _isAlphaSliderVisible = false;
                      _isAlphaTextInputVisible = false;
                    }
                  }),
                  content: const Text('Alpha Enabled'),
                ),
                if (_isAlphaEnabled) ...[
                  Checkbox(
                    checked: _isAlphaSliderVisible,
                    onChanged: (final v) =>
                        setState(() => _isAlphaSliderVisible = v!),
                    content: const Text('Alpha Slider'),
                  ),
                  Checkbox(
                    checked: _isAlphaTextInputVisible,
                    onChanged: (final v) =>
                        setState(() => _isAlphaTextInputVisible = v!),
                    content: const Text('Alpha Text Input'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Selected Color:',
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            const SizedBox(height: 8),
            Container(color: _selectedColor, width: 200, height: 50),
          ],
        ),
        const SizedBox(height: 20),
        subtitle(content: const Text('ColorPicker Demo')),
        CodeSnippetCard(
          codeSnippet: '''
Color selectedColor = Colors.blue;
ColorSpectrumShape spectrumShape = ColorSpectrumShape.box;

ColorPicker(
  color: selectedColor,
  onChanged: (color) => setState(() => selectedColor = color),
  colorSpectrumShape: spectrumShape,
  isMoreButtonVisible: true,
  isColorSliderVisible: true,
  isColorChannelTextInputVisible: true,
  isHexInputVisible: true,
  isAlphaEnabled: false,
),''',
          child: Row(
            children: [
              ColorPicker(
                color: _selectedColor,
                onChanged: (final color) =>
                    setState(() => _selectedColor = color),
                colorSpectrumShape: _spectrumShape,
                orientation: _orientation,
                isMoreButtonVisible: _isMoreButtonVisible,
                isColorSliderVisible: _isColorSliderVisible,
                isColorChannelTextInputVisible: _isColorChannelTextInputVisible,
                isHexInputVisible: _isHexInputVisible,
                isColorPreviewVisible: _isColorPreviewVisible,
                isAlphaEnabled: _isAlphaEnabled,
                isAlphaSliderVisible: _isAlphaSliderVisible,
                isAlphaTextInputVisible: _isAlphaTextInputVisible,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
